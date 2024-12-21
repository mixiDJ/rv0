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
// Name: rv0_exu_ib.sv
// Auth: Nikola Lukić
// Date: 20.12.2024.
// Desc: Integer/branch execute unit
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

    // execute unit flush signals
    input  logic                        exu_flush_i,

    // pipeline buffer interfaces
    rv_sbuf_if.sink                     idu_sbuf_if,
    rv_sbuf_if.source                   exu_sbuf_if

);

    localparam int unsigned EXU_BUF_WIDTH = 3*XLEN + 32;

    logic                       exu_buf_we;
    logic [EXU_BUF_WIDTH-1:0]   exu_buf_wdata;
    logic                       exu_buf_full;
    logic                       exu_buf_re;
    logic [EXU_BUF_WIDTH-1:0]   exu_buf_rdata;
    logic                       exu_buf_empty;

    logic [31:0]                exu_buf_insn;
    logic [XLEN-1:0]            exu_buf_addr;
    logic [XLEN-1:0]            exu_buf_idata1;
    logic [XLEN-1:0]            exu_buf_idata2;

    rv_opcode_e                 exu_sbuf_opcode;
    logic [31:0]                exu_sbuf_insn;
    logic [XLEN-1:0]            exu_sbuf_addr;
    logic [XLEN-1:0]            exu_sbuf_idata1;
    logic [XLEN-1:0]            exu_sbuf_idata2;
    logic [TLEN-1:0]            exu_sbuf_tags;
    logic                       exu_sbuf_rdy;
    logic                       exu_sbuf_ack;

    logic [XLEN-1:0]            alu_wdata;
    logic [XLEN-1:0]            alu_ct_wdata;
    logic [XLEN-1:0]            alu_ct_target;
    logic                       alu_ct_trans;

    assign exu_buf_we = idu_sbuf_if.rdy == 1'b1 && idu_sbuf_if.ack == 1'b1 && exu_buf_full  == 1'b0;
    assign exu_buf_re = exu_sbuf_rdy == 1'b1 && exu_sbuf_ack == 1'b1 && exu_buf_empty == 1'b0;

    assign exu_buf_wdata = {
        idu_sbuf_if.insn,
        idu_sbuf_if.addr,
        idu_sbuf_if.idata1,
        idu_sbuf_if.idata2
    };

    assign idu_sbuf_if.ack = exu_buf_full == 1'b0;

    assign {
        exu_buf_insn,
        exu_buf_addr,
        exu_buf_idata1,
        exu_buf_idata2
    } = exu_buf_rdata;

    assign exu_sbuf_opcode = rv_opcode_e'(exu_buf_insn[6:0]);
    assign exu_sbuf_insn   = exu_buf_insn;
    assign exu_sbuf_addr   = exu_buf_addr;
    assign exu_sbuf_idata2 = alu_ct_target;
    assign exu_sbuf_tags   = {
        30'b0,
        alu_ct_trans,
        1'b0
    };
    assign exu_sbuf_rdy    = exu_buf_empty == 1'b0;

    always_comb begin
        case(exu_sbuf_opcode)
            JAL:  exu_sbuf_idata1 = alu_ct_wdata;
            JALR: exu_sbuf_idata1 = alu_ct_wdata;
            default: exu_sbuf_idata1 = alu_wdata;
        endcase
    end

    fifo_sync #(.DATA_WIDTH(EXU_BUF_WIDTH))
    u_exu_buf (
        .clk_i              (clk_i              ),
        .rst_ni             (rst_ni             ),
        .clr_i              (exu_flush_i        ),
        .we_i               (exu_buf_we         ),
        .wdata_i            (exu_buf_wdata      ),
        .full_o             (exu_buf_full       ),
        .re_i               (exu_buf_re         ),
        .rdata_o            (exu_buf_rdata      ),
        .empty_o            (exu_buf_empty      )
    );

    rv0_alu_i #(`RV0_CORE_PARAMS)
    u_alu_i (
        .alu_insn_i         (exu_buf_insn       ),
        .alu_addr_i         (exu_buf_addr       ),
        .alu_rdata1_i       (exu_buf_idata1     ),
        .alu_rdata2_i       (exu_buf_idata2     ),
        .alu_wdata_o        (alu_wdata          )
    );

    rv0_alu_b #(`RV0_CORE_PARAMS)
    u_alu_b (
        .alu_insn_i         (exu_buf_insn       ),
        .alu_addr_i         (exu_buf_addr       ),
        .alu_rdata1_i       (exu_buf_idata1     ),
        .alu_rdata2_i       (exu_buf_idata2     ),
        .alu_ct_wdata_o     (alu_ct_wdata       ),
        .alu_ct_target_o    (alu_ct_target      ),
        .alu_ct_trans_o     (alu_ct_trans       )
    );

    rv0_sbuf #(XLEN, FLEN)
    u_exu_sbuf (
        .clk_i              (clk_i              ),
        .rst_ni             (rst_ni             ),
        .flush_i            (exu_flush_i        ),

        .insn_i             (exu_sbuf_insn      ),
        .addr_i             (exu_sbuf_addr      ),
        .idata1_i           (exu_sbuf_idata1    ),
        .idata2_i           (exu_sbuf_idata2    ),
        .tags_i             (exu_sbuf_tags      ),

        .rdy_i              (exu_sbuf_rdy       ),
        .ack_o              (exu_sbuf_ack       ),

        .sbuf_if            (exu_sbuf_if        )
    );

endmodule : rv0_exu_ib
