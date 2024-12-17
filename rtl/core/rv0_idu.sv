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

    // integer register write-back signals
    input  logic [4:0]                  rfi_waddr_i,
    input  logic [XLEN-1:0]             rfi_wdata_i,
    input  logic                        rfi_we_i,

    // floating point register write-back signals
    input  logic [4:0]                  rff_waddr_i,
    input  logic [FLEN-1:0]             rff_wdata_i,
    input  logic                        rff_we_i,

    // pipeline buffer interfaces
    rv_sbuf_if.sink                     ipu_sbuf_if,
    rv_sbuf_if.source                   idu_ei_sbuf_if,
    rv_sbuf_if.source                   idu_em_sbuf_if,
    rv_sbuf_if.source                   idu_ef_sbuf_if,
    rv_sbuf_if.source                   idu_ma_sbuf_if

);

    localparam int unsigned REG_CNT = RVI ? 32 : 16;

    logic [31:0]        ei_sbuf_insn;
    logic [XLEN-1:0]    ei_sbuf_addr;
    logic [XLEN-1:0]    ei_sbuf_idata1;
    logic [XLEN-1:0]    ei_sbuf_idata2;
    logic               ei_sbuf_rdy;
    logic               ei_sbuf_ack;

    logic [31:0]        ma_sbuf_insn;
    logic [XLEN-1:0]    ma_sbuf_addr;
    logic [XLEN-1:0]    ma_sbuf_idata1;
    logic [XLEN-1:0]    ma_sbuf_idata2;
    logic               ma_sbuf_rdy;
    logic               ma_sbuf_ack;

    /*
     * EXECUTION UNIT RESERVATION LOGIC
     */

    typedef enum logic [3:0] {
        EX_I  = 4'b0001,
        EX_M  = 4'b0010,
        EX_F  = 4'b0100,
        EX_MA = 4'b1000
    } ures_e;

    ures_e ures;

    always_comb begin
        case(ipu_sbuf_if.opcode)
            LUI:        ures = EX_I;
            AUIPC:      ures = EX_I;
            JAL:        ures = EX_I;
            JALR:       ures = EX_I;
            BRANCH:     ures = EX_I;
            LOAD:       ures = EX_MA;
            STORE:      ures = EX_MA;
            OP_IMM:     ures = EX_I;
            OP:         ures = EX_I;
            OP_IMM_32:  ures = EX_I;
            OP_32:      ures = EX_I;
        endcase
    end

    /*
     * REGISTER RESERVATION LOGIC
     */

    logic [5:0] rres;

    always_comb begin
        logic [6:0] opcode;
        case(ures)
            EX_I:  opcode = idu_ei_sbuf_if.opcode;
            EX_MA: opcode = idu_ma_sbuf_if.opcode;
        endcase
        case(opcode)
            LUI:        rres = 6'b000_001;
            AUIPC:      rres = 6'b000_001;
            JAL:        rres = 6'b000_001;
            JALR:       rres = 6'b000_011;
            BRANCH:     rres = 6'b000_110;
            LOAD:       rres = 6'b000_011;
            STORE:      rres = 6'b000_110;
            OP_IMM:     rres = 6'b000_011;
            OP:         rres = 6'b000_111;
            OP_IMM_32:  rres = 6'b000_011;
            OP_32:      rres = 6'b000_111;
            // TODO
            LOAD_FP:    rres = 6'bxxx_xxx;
            STORE_FP:   rres = 6'bxxx_xxx;
            MADD:       rres = 6'bxxx_xxx;
            MSUB:       rres = 6'bxxx_xxx;
            NMSUB:      rres = 6'bxxx_xxx;
            NMADD:      rres = 6'bxxx_xxx;
            OP_FP:      rres = 6'bxxx_xxx;
            AMO:        rres = 6'bxxx_xxx;
            MISC_MEM:   rres = 6'bxxx_xxx;
            SYSTEM:     rres = 6'bxxx_xxx;
            default:    rres = 6'bxxx_xxx;
        endcase
    end

    /*
     * INTEGER REGISTER RESERVATION LOGIC
     */

    logic [3:0] ires_cnt_q [1:REG_CNT-1];
    logic [3:0] ires_cnt_d [1:REG_CNT-1];

    for(genvar i = 1; i < REG_CNT; ++i) begin

        always_comb begin
            ires_cnt_d[i] = ires_cnt_q[i];

            if(rres[0] == 1'b1 && idu_ei_sbuf_if.rd == i && idu_ei_sbuf_if.rdy == 1'b1 && idu_ei_sbuf_if.ack == 1'b1) begin
                ires_cnt_d[i] = ires_cnt_d[i] + 4'h1;
            end

            if(rres[0] == 1'b1 && idu_ma_sbuf_if.rd == i && idu_ma_sbuf_if.rdy == 1'b1 && idu_ma_sbuf_if.ack == 1'b1) begin
                ires_cnt_d[i] = ires_cnt_d[i] + 4'h1;
            end

            if(rfi_waddr_i == i && rfi_we_i == 1'b1) begin
                ires_cnt_d[i] = ires_cnt_d[i] - 4'h1;
            end
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) ires_cnt_q[i] <= 4'h0;
            else ires_cnt_q[i] <= ires_cnt_d[i];
        end

    end

    /*
     * INTEGER REGISTER FILE
     */

    logic [XLEN-1:0]    rfi_rdata1;
    logic [XLEN-1:0]    rfi_rdata2;

    rv0_rf_i #(`RV0_CORE_PARAMS)
    u_rfi (
        .clk_i              (clk_i              ),
        .rst_ni             (rst_ni             ),

        .raddr1_i           (ipu_sbuf_if.rs1    ),
        .rdata1_o           (rfi_rdata1         ),

        .raddr2_i           (ipu_sbuf_if.rs2    ),
        .rdata2_o           (rfi_rdata2         ),

        .waddr_i            (rfi_waddr_i        ),
        .wdata_i            (rfi_wdata_i        ),
        .we_i               (rfi_we_i           )
    );

if(RVF == 1'b1) begin : rff_genblk

    /*
     * FLOATING POINT REGISTER RESERVATION LOGIC
     */

    logic [3:0] fres_cnt_q [0:31];

    /*
     * FLOATING POINT REGISTER FILE
     */

    rv0_rf_f #()
    u_rff ();

end // rff_genblk

    /*
     * IMMEDIATE VALUE MUX
     */

    logic [XLEN-1:0] imm;

    always_comb begin : imm_mux_blk
        imm = {XLEN{1'b0}};
        case(ipu_sbuf_if.opcode)
            LUI:    imm = {{XLEN-32{ipu_sbuf_if.insn[31]}}, ipu_sbuf_if.insn[31:12], 12'h0};
            AUIPC:  imm = {{XLEN-32{ipu_sbuf_if.insn[31]}}, ipu_sbuf_if.insn[31:12], 12'h0};
            JAL:    imm = {{XLEN-21{ipu_sbuf_if.insn[31]}}, ipu_sbuf_if.insn[31], ipu_sbuf_if.insn[19:12], ipu_sbuf_if.insn[20], ipu_sbuf_if.insn[30:21], 1'b0};
            JALR:   imm = 0;
            BRANCH: imm = {{XLEN-13{ipu_sbuf_if.insn[31]}}, ipu_sbuf_if.insn[7], ipu_sbuf_if.insn[30:25], ipu_sbuf_if.insn[11:8], 1'b0};
            LOAD:   imm = {{XLEN-12{ipu_sbuf_if.insn[31]}}, ipu_sbuf_if.insn[31:20]};
            STORE:  imm = {{XLEN-12{ipu_sbuf_if.insn[31]}}, ipu_sbuf_if.insn[31:25], ipu_sbuf_if.insn[11:7]};
            OP_IMM: imm = {{XLEN-12{ipu_sbuf_if.insn[31]}}, ipu_sbuf_if.insn[31:20]};
        endcase
    end // imm_mux_blk

    /*
     * INTEGER OPERAND VALUE MUX
     */

    logic [1:0] s_op_mux;

    always_comb begin
        unique case(ipu_sbuf_if.opcode)
            LUI:        s_op_mux = 6'b00;
            AUIPC:      s_op_mux = 6'b00;
            JAL:        s_op_mux = 6'b00;
            JALR:       s_op_mux = 6'b01;
            BRANCH:     s_op_mux = 6'b11;
            LOAD:       s_op_mux = 6'b01;
            STORE:      s_op_mux = 6'b11;
            OP_IMM:     s_op_mux = 6'b01;
            OP:         s_op_mux = 6'b11;
            OP_IMM_32:  s_op_mux = 6'b01;
            OP_32:      s_op_mux = 6'b11;
            // TODO
            LOAD_FP:    s_op_mux = 6'bxx;
            STORE_FP:   s_op_mux = 6'bxx;
            MADD:       s_op_mux = 6'bxx;
            MSUB:       s_op_mux = 6'bxx;
            NMSUB:      s_op_mux = 6'bxx;
            NMADD:      s_op_mux = 6'bxx;
            OP_FP:      s_op_mux = 6'bxx;
            AMO:        s_op_mux = 6'bxx;
            MISC_MEM:   s_op_mux = 6'bxx;
            SYSTEM:     s_op_mux = 6'bxx;
            default:    s_op_mux = 6'bxx;
        endcase
    end

    logic [XLEN-1:0] i_rdata1;
    logic [XLEN-1:0] i_rdata2;

    assign i_rdata1 = s_op_mux[0] == 1'b1 ? rfi_rdata1 : ipu_sbuf_if.addr;
    assign i_rdata2 = s_op_mux[1] == 1'b1 ? rfi_rdata2 : imm;

    /*
     * INTEGER EXECUTION UNIT SKID BUFER LOGIC
     */

    assign ei_sbuf_insn   = ipu_sbuf_if.insn;
    assign ei_sbuf_addr   = ipu_sbuf_if.addr;
    assign ei_sbuf_idata1 = i_rdata1;
    assign ei_sbuf_idata2 = i_rdata2;

    always_comb begin
        ei_sbuf_rdy = ures == EX_I && ipu_sbuf_if.rdy == 1'b1;

        // reservation count
        if(ires_cnt_q[ipu_sbuf_if.rs1] != 5'h0 && rres[1] == 1'b1) begin
            ei_sbuf_rdy = 1'b0;
        end

        if(ires_cnt_q[ipu_sbuf_if.rs2] != 5'h0 && rres[2] == 1'b1) begin
            ei_sbuf_rdy = 1'b0;
        end

        // current instruction rd
        if(idu_ei_sbuf_if.rd == ipu_sbuf_if.rs1 && rres[1] == 1'b1 && idu_ei_sbuf_if.rdy == 1'b1) begin
            ei_sbuf_rdy = 1'b0;
        end

        if(idu_ma_sbuf_if.rd == ipu_sbuf_if.rs1 && rres[1] == 1'b1 && idu_ma_sbuf_if.rdy == 1'b1) begin
            ei_sbuf_rdy = 1'b0;
        end

        if(idu_ei_sbuf_if.rd == ipu_sbuf_if.rs2 && rres[2] == 1'b1 && idu_ei_sbuf_if.rdy == 1'b1) begin
            ei_sbuf_rdy = 1'b0;
        end

        if(idu_ma_sbuf_if.rd == ipu_sbuf_if.rs2 && rres[2] == 1'b1 && idu_ma_sbuf_if.rdy == 1'b1) begin
            ei_sbuf_rdy = 1'b0;
        end
    end

    rv0_sbuf #(XLEN, FLEN)
    u_ei_sbuf (
        .clk_i      (clk_i              ),
        .rst_ni     (rst_ni             ),
        .flush_i    (idu_flush_i        ),

        .insn_i     (ei_sbuf_insn       ),
        .addr_i     (ei_sbuf_addr       ),
        .idata1_i   (ei_sbuf_idata1     ),
        .idata2_i   (ei_sbuf_idata2     ),
        .rdy_i      (ei_sbuf_rdy        ),
        .ack_o      (ei_sbuf_ack        ),

        .sbuf_if    (idu_ei_sbuf_if     )
    );

if(RVM == 1'b1) begin : imsbuf_genblk

    /*
     * INTEGER MULTIPLY EXECUTION UNIT SKID BUFFER LOGIC
     */

end // imsbuf_genblk

if(RVF == 1'b1) begin : fsbuf_genblk

    /*
     * FLOATING POINT EXECUTION UNIT SKID BUFFER LOGIC
     */

end // fsbuf_genblk

    /*
     * MEMORY ACCESS EXECUTION UNIT SKID BUFFER LOGIC
     */

    assign ma_sbuf_insn   = ipu_sbuf_if.insn;
    assign ma_sbuf_addr   = ipu_sbuf_if.addr;
    assign ma_sbuf_idata1 = i_rdata1;
    assign ma_sbuf_idata2 = i_rdata2;

    always_comb begin
        ma_sbuf_rdy = ures == EX_MA && ipu_sbuf_if.rdy == 1'b1;

        if(ires_cnt_q[ipu_sbuf_if.rs1] != 5'h0 && rres[1] == 1'b1) begin
            ma_sbuf_rdy = 1'b0;
        end

        if(ires_cnt_q[ipu_sbuf_if.rs2] != 5'h0 && rres[2] == 1'b1) begin
            ma_sbuf_rdy = 1'b0;
        end

        if(idu_ei_sbuf_if.rd == ipu_sbuf_if.rs1 && rres[1] == 1'b1 && idu_ei_sbuf_if.rdy == 1'b1) begin
            ma_sbuf_rdy = 1'b0;
        end

        if(idu_ma_sbuf_if.rd == ipu_sbuf_if.rs1 && rres[1] == 1'b1 && idu_ma_sbuf_if.rdy == 1'b1) begin
            ma_sbuf_rdy = 1'b0;
        end

        if(idu_ei_sbuf_if.rd == ipu_sbuf_if.rs2 && rres[2] == 1'b1 && idu_ei_sbuf_if.rdy == 1'b1) begin
            ma_sbuf_rdy = 1'b0;
        end

        if(idu_ma_sbuf_if.rd == ipu_sbuf_if.rs2 && rres[2] == 1'b1 && idu_ma_sbuf_if.rdy == 1'b1) begin
            ma_sbuf_rdy = 1'b0;
        end
    end

    rv0_sbuf #(XLEN, FLEN)
    u_ma_sbuf (
        .clk_i      (clk_i              ),
        .rst_ni     (rst_ni             ),
        .flush_i    (idu_flush_i        ),

        .insn_i     (ma_sbuf_insn       ),
        .addr_i     (ma_sbuf_addr       ),
        .idata1_i   (ma_sbuf_idata1     ),
        .idata2_i   (ma_sbuf_idata2     ),
        .rdy_i      (ma_sbuf_rdy        ),
        .ack_o      (ma_sbuf_ack        ),

        .sbuf_if    (idu_ma_sbuf_if     )
    );

    /*
     * PRE-DECODE RESPONSE LOGIC
     */

    always_comb begin
        ipu_sbuf_if.ack = 1'b1;

        if(ipu_sbuf_if.rdy == 1'b1) begin
            unique case(ipu_sbuf_if.opcode)
                LUI:        ipu_sbuf_if.ack = ei_sbuf_rdy == 1'b1 && ei_sbuf_ack == 1'b1;
                AUIPC:      ipu_sbuf_if.ack = ei_sbuf_rdy == 1'b1 && ei_sbuf_ack == 1'b1;
                JAL:        ipu_sbuf_if.ack = ei_sbuf_rdy == 1'b1 && ei_sbuf_ack == 1'b1;
                JALR:       ipu_sbuf_if.ack = ei_sbuf_rdy == 1'b1 && ei_sbuf_ack == 1'b1;
                BRANCH:     ipu_sbuf_if.ack = ei_sbuf_rdy == 1'b1 && ei_sbuf_ack == 1'b1;
                LOAD:       ipu_sbuf_if.ack = ma_sbuf_rdy == 1'b1 && ma_sbuf_ack == 1'b1;
                STORE:      ipu_sbuf_if.ack = ma_sbuf_rdy == 1'b1 && ma_sbuf_ack == 1'b1;
                OP_IMM:     ipu_sbuf_if.ack = ei_sbuf_rdy == 1'b1 && ei_sbuf_ack == 1'b1;
                OP:         ipu_sbuf_if.ack = ei_sbuf_rdy == 1'b1 && ei_sbuf_ack == 1'b1;
            endcase
        end

    end

endmodule : rv0_idu
