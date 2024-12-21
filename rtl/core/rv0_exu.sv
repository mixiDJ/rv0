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
// Name: rv0_exu.sv
// Auth: Nikola Lukić
// Date: 10.11.2024.
// Desc: Instruction execute unit
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rv0_exu_ib #(`RV0_CORE_PARAM_LST) (

    input  logic                        clk_i,
    input  logic                        rst_ni,

    output logic [XLEN-1:0]             ifu_fc_target_o,
    output logic                        ifu_fc_trans_o,

    // pipeline buffer interfaces
    rv_sbuf_if.sink                     idu_sbuf_if,
    rv_sbuf_if.source                   exu_sbuf_if

);

    logic [XLEN-1:0]    sbuf_idata1;
    logic               sbuf_rdy;
    logic               sbuf_ack;

    logic [XLEN-1:0]    alu_i_wdata;

    rv0_alu_i #(`RV0_CORE_PARAMS)
    u_alu_i (
        .clk_i              (clk_i                  ),
        .rst_ni             (rst_ni                 ),
        .alu_insn_i         (idu_sbuf_if.insn       ),
        .alu_rdata1_i       (idu_sbuf_if.idata1     ),
        .alu_rdata2_i       (idu_sbuf_if.idata2     ),
        .alu_wdata_o        (alu_i_wdata            )
    );

    assign sbuf_rdy = idu_sbuf_if.rdy;

    rv0_sbuf #(XLEN, FLEN)
    u_exu_sbuf (
        .clk_i      (clk_i                  ),
        .rst_ni     (rst_ni                 ),

        .insn_i     (idu_sbuf_if.insn       ),
        .addr_i     (idu_sbuf_if.addr       ),
        .idata1_i   (sbuf_idata1            ),
        .rdy_i      (sbuf_rdy               ),
        .ack_o      (sbuf_ack               ),

        .sbuf_if    (exu_sbuf_if            )
    );

    assign idu_sbuf_if.ack = sbuf_ack;

    logic [XLEN-1:0] jal_fc_target_offs;
    logic [XLEN-1:0] jalr_fc_target_offs;
    logic [XLEN-1:0] branch_fc_target_offs;

    assign jal_fc_target_offs    = {
        {XLEN-21{idu_sbuf_if.insn[31]}},
        idu_sbuf_if.insn[31],
        idu_sbuf_if.insn[19:12],
        idu_sbuf_if.insn[20],
        idu_sbuf_if.insn[30:21],
        1'b0
    };
    assign jalr_fc_target_offs   = {
        {XLEN-12{idu_sbuf_if.insn[31]}},
        idu_sbuf_if.insn[31:20]
    };
    assign branch_fc_target_offs = {
        {XLEN-13{idu_sbuf_if.insn[31]}},
        idu_sbuf_if.insn[31],
        idu_sbuf_if.insn[7],
        idu_sbuf_if.insn[30:25],
        idu_sbuf_if.insn[11:8],
        1'b0
    };

    always_comb begin
        ifu_fc_target_o = idu_sbuf_if.addr;
        ifu_fc_trans_o  = 1'b0;

        case(idu_sbuf_if.opcode)

            JAL: begin
                ifu_fc_target_o = (idu_sbuf_if.addr + jal_fc_target_offs);
                ifu_fc_trans_o  = 1'b1;
            end

            JALR: begin
                ifu_fc_target_o = (idu_sbuf_if.idata1 + jalr_fc_target_offs) & {{XLEN-1{1'b1}}, 1'b0};
                ifu_fc_trans_o  = 1'b1;
            end

            BRANCH: begin
                ifu_fc_target_o = idu_sbuf_if.addr + branch_fc_target_offs;
                case(idu_sbuf_if.funct3)
                    BEQ:  ifu_fc_trans_o = idu_sbuf_if.idata1 == idu_sbuf_if.idata2;
                    BNE:  ifu_fc_trans_o = idu_sbuf_if.idata1 != idu_sbuf_if.idata2;
                    BLT:  ifu_fc_trans_o = $signed(idu_sbuf_if.idata1) < $signed(idu_sbuf_if.idata2);
                    BGE:  ifu_fc_trans_o = $signed(idu_sbuf_if.idata1) >= $signed(idu_sbuf_if.idata2);
                    BLTU: ifu_fc_trans_o = idu_sbuf_if.idata1 < idu_sbuf_if.idata2;
                    BGEU: ifu_fc_trans_o = idu_sbuf_if.idata1 >= idu_sbuf_if.idata2;
                endcase
            end

        endcase

        if(idu_sbuf_if.rdy == 1'b0) ifu_fc_trans_o = 1'b0;

    end

    always_comb begin
        case(idu_sbuf_if.opcode)
            LUI:     sbuf_idata1 = idu_sbuf_if.idata2;
            JAL:     sbuf_idata1 = idu_sbuf_if.addr + 'h4;
            JALR:    sbuf_idata1 = idu_sbuf_if.addr + 'h4;
            default: sbuf_idata1 = alu_i_wdata;
        endcase
    end

endmodule : rv0_exu_ib
