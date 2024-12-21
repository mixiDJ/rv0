////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2024  Nikola Lukić <lukicn@protonmail.com>
// This source describes Open Hardware and is licensed under the CERN-OHL-S v2
//
// You may redistribute and modify this documentation and make products
// using it under the terms of the CERN-OHL-S v2 (https:/cern.ch/cern-ohl).
// This documentation is distributed WITHOUT ANY EXPRESS OR IMPLIED
// WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY
// AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-S v2
// for applicable conditions.
//
// Source location: svn://lukic.sytes.net/rv0
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: rv0_idu.sv
// Auth: Nikola Lukić
// Date: 10.11.2024.
// Desc: Instruction decode unit
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rv0_idu #(`RV0_CORE_PARAM_LST) (

    input  logic                        clk_i,
    input  logic                        rst_ni,

    // instruction decode unit flush
    input  logic                        idu_flush_i,

    // integer register write-back interface
    rv_rwb_if.sink                      rfi_if,

    // floating point register write-back signals
    rv_rwb_if.sink                      rff_if,

    // pipeline buffer interfaces
    rv_sbuf_if.sink                     ipu_sbuf_if,
    rv_sbuf_if.source                   idu_sbuf_if [0:EXU_CNT-1]

);

    localparam int unsigned REG_CNT = RVI ? 32 : 16;

    logic [6:0] opcode;
    logic [6:0] funct7;

    assign opcode = ipu_sbuf_if.insn[6:0];
    assign funct7 = ipu_sbuf_if.insn[31:25];

    /*
     * EXECUTION UNIT RESERVATION LOGIC
     */

    exu_type_e r_exu;

    always_comb begin
        case(opcode)
            LUI:    r_exu = EXU_I;
            AUIPC:  r_exu = EXU_I;
            JAL:    r_exu = EXU_B;
            JALR:   r_exu = EXU_B;
            BRANCH: r_exu = EXU_B;
            LOAD:   r_exu = LSU;
            STORE:  r_exu = LSU;
            OP_IMM: r_exu = EXU_I;
            OP: begin
                r_exu = EXU_I;
                if(funct7 == MULDIV && RVM == 1'b1) begin
                    r_exu = EXU_M;
                end
            end
            OP_IMM_32: begin
                r_exu = EXU_I;
            end
            OP_32: begin
                r_exu = EXU_I;
            end
            default: r_exu = EXU_I;
        endcase
    end

    /*
     * REGISTER RESERVATION LOGIC
     */

    // bit 0 - int rd  reservation
    // bit 1 - int rs1 reservation
    // bit 2 - int rs2 reservation
    // bit 3 - fp  rd  reservation
    // bit 4 - fp  rs1 reservation
    // bit 5 - fp  rs2 reservation

    logic [5:0] r_reg;

    always_comb begin
        case(opcode)
            LUI:        r_reg = 6'b000_001;
            AUIPC:      r_reg = 6'b000_001;
            JAL:        r_reg = 6'b000_001;
            JALR:       r_reg = 6'b000_011;
            BRANCH:     r_reg = 6'b000_110;
            LOAD:       r_reg = 6'b000_011;
            STORE:      r_reg = 6'b000_110;
            OP_IMM:     r_reg = 6'b000_011;
            OP:         r_reg = 6'b000_111;
            OP_IMM_32:  r_reg = 6'b000_011;
            OP_32:      r_reg = 6'b000_111;
            default:    r_reg = 6'b000_000;
        endcase
    end

    /*
     * INTEGER REGISTER RESERVATION COUNT LOGIC
     */

    logic [7:0] ireg_res_cnt_q [1:REG_CNT-1];
    logic [7:0] ireg_res_cnt_d [1:REG_CNT-1];

    for(genvar i = 1; i < REG_CNT; ++i) begin

        always_comb begin
            ireg_res_cnt_d[i] = ireg_res_cnt_q[i];
            if(r_reg[0] == 1'b1 && ipu_sbuf_if.rd == i && ipu_sbuf_if.rdy == 1'b1 && ipu_sbuf_if.ack == 1'b1) begin
                ireg_res_cnt_d[i] = ireg_res_cnt_d[i] + 8'h1;
            end
            if(rfi_if.waddr == i && rfi_if.we == 1'b1) begin
                ireg_res_cnt_d[i] = ireg_res_cnt_d[i] - 8'h1;
            end
            if(idu_flush_i == 1'b1) begin
                ireg_res_cnt_d[i] = 8'h0;
            end
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) ireg_res_cnt_q[i] <= 8'h0;
            else ireg_res_cnt_q[i] <= ireg_res_cnt_d[i];
        end

    end

    /*
     * FLOATING-POINT REGISTER RESERVATION COUNT LOGIC
     */

    logic [7:0] freg_res_cnt_q [0:31];
    logic [7:0] freg_res_cnt_d [0:31];

    // TODO

    /*
     * INTEGER REGISTER FILE
     */

    logic [XLEN-1:0] rfi_rdata1;
    logic [XLEN-1:0] rfi_rdata2;

    rv0_rf_i #(`RV0_CORE_PARAMS)
    u_rfi (
        .clk_i              (clk_i              ),
        .rst_ni             (rst_ni             ),

        .raddr1_i           (ipu_sbuf_if.rs1    ),
        .rdata1_o           (rfi_rdata1         ),

        .raddr2_i           (ipu_sbuf_if.rs2    ),
        .rdata2_o           (rfi_rdata2         ),

        .waddr_i            (rfi_if.waddr       ),
        .wdata_i            (rfi_if.wdata       ),
        .we_i               (rfi_if.we          )
    );

    /*
     * INTEGER IMMEDIATE LOGIC
     */

    logic [XLEN-1:0] imm;

    always_comb begin
        case(opcode)
            LUI:    imm = {{XLEN-32{ipu_sbuf_if.insn[31]}}, ipu_sbuf_if.insn[31:12], 12'h0};
            AUIPC:  imm = {{XLEN-32{ipu_sbuf_if.insn[31]}}, ipu_sbuf_if.insn[31:12], 12'h0};
            OP_IMM: imm = {{XLEN-12{ipu_sbuf_if.insn[31]}}, ipu_sbuf_if.insn[31:20]};
        endcase
    end

    logic [XLEN-1:0] irdata1;
    logic [XLEN-1:0] irdata2;

    assign irdata1 = r_reg[1] ? rfi_rdata1 : 'h0;
    assign irdata2 = r_reg[2] ? rfi_rdata2 : imm;

    /*
     * FLOATING POINT REGISTER FILE
     */

    logic [FLEN-1:0] rff_rdata1;
    logic [FLEN-1:0] rff_rdata2;

    if(RVF == 1'b1) begin : rff_genblk

        rv0_rf_f #(`RV0_CORE_PARAMS)
        u_rff (
            .clk_i              (clk_i              ),
            .rst_ni             (rst_ni             ),

            .raddr1_i           (ipu_sbuf_if.rs1    ),
            .rdata1_o           (rff_rdata1         ),

            .raddr2_i           (ipu_sbuf_if.rs2    ),
            .rdata2_o           (rff_rdata2         ),

            .waddr_i            (rff_if.waddr       ),
            .wdata_i            (rff_if.wdata       ),
            .we_i               (rff_if.we          )
        );

    end // rff_genblk

    /*
     * EXECUTION UNIT SKID BUFFERS
     */

    logic idu_sbuf_rdy [0:EXU_CNT-1];
    logic idu_sbuf_ack [0:EXU_CNT-1];

    for(genvar i = 0; i < EXU_CNT; ++i) begin : idu_sbuf_genblk

        rv0_sbuf #(XLEN, FLEN)
        u_idu_sbuf (
            .clk_i      (clk_i              ),
            .rst_ni     (rst_ni             ),
            .flush_i    (idu_flush_i        ),

            .addr_i     (ipu_sbuf_if.addr   ),
            .insn_i     (ipu_sbuf_if.insn   ),
            .idata1_i   (irdata1            ),
            .idata2_i   (irdata2            ),
            .fdata1_i   (rff_rdata1         ),
            .fdata2_i   (rff_rdata2         ),
            .tags_i     (                   ),

            .rdy_i      (idu_sbuf_rdy[i]    ),
            .ack_o      (idu_sbuf_ack[i]    ),

            .sbuf_if    (idu_sbuf_if[i]     )
        );

    end // idu_sbuf_genblk

    int idx_cur;
    int idx;
    bit iss;

    always_comb begin
        idx_cur = 0;
        iss = 1'b0;
        for(int i = 0; i < EXU_CNT; ++i) begin
            if((r_exu & EXU_TYPE[i]) != 'b0) begin
                idx_cur = i;
                iss = 1'b1;
            end

            if(ireg_res_cnt_q[ipu_sbuf_if.rs1] != 8'h0 && r_reg[1] == 1'b1) begin
                idx_cur = idx;
                iss = 1'b0;
            end

            if(ireg_res_cnt_q[ipu_sbuf_if.rs2] != 8'h0 && r_reg[2] == 1'b1) begin
                idx_cur = idx;
                iss = 1'b0;
            end

            idx = idx_cur;
        end
    end

    always_comb begin
        idu_sbuf_rdy = '{default: 1'b0};
        if(ipu_sbuf_if.rdy == 1'b1 && iss == 1'b1) begin
            idu_sbuf_rdy[idx] = 1'b1;
        end
    end

    always_comb begin
        ipu_sbuf_if.ack = idu_sbuf_ack[idx];
        if(iss == 1'b0) begin
            ipu_sbuf_if.ack = 1'b0;
        end
        if(ipu_sbuf_if.rdy == 1'b0) begin
            ipu_sbuf_if.ack = 1'b1;
        end
    end

endmodule : rv0_idu
