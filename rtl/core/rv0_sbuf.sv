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
// Name: rv0_sbuf.sv
// Auth: Nikola Lukić
// Date: 24.11.2024.
// Desc: Pipeline skid buffer
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rv0_sbuf #(
    parameter int unsigned XLEN = 32,
    parameter int unsigned FLEN = 32
) (

    input  logic                    clk_i,
    input  logic                    rst_ni,

    input  logic                    flush_i,

    input  logic [XLEN-1:0]         addr_i,
    input  logic [31:0]             insn_i,

    input  logic [XLEN-1:0]         idata1_i,
    input  logic [XLEN-1:0]         idata2_i,

    input  logic [FLEN-1:0]         fdata1_i,
    input  logic [FLEN-1:0]         fdata2_i,

    input  logic [TLEN-1:0]         tags_i,

    input  logic                    rdy_i,
    output logic                    ack_o,

    rv_sbuf_if.source               sbuf_if

);

    localparam int unsigned SBUF_WIDTH = 32 + 3*XLEN + 2*FLEN + TLEN;

    logic [SBUF_WIDTH-1:0]  sbuf_d;
    logic [SBUF_WIDTH-1:0]  sbuf_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) begin
            sbuf_if.insn   <= 32'h13;
            sbuf_if.addr   <= {XLEN{1'b0}};
            sbuf_if.idata1 <= {XLEN{1'b0}};
            sbuf_if.idata2 <= {XLEN{1'b0}};
            sbuf_if.fdata1 <= {XLEN{1'b0}};
            sbuf_if.fdata2 <= {XLEN{1'b0}};
            sbuf_if.tags   <= {XLEN{1'b0}};

            sbuf_if.rdy <= 1'b0;
        end
        else begin

            if(rdy_i == 1'b1 && sbuf_if.ack == 1'b1) begin
                sbuf_if.addr   <= addr_i;
                sbuf_if.insn   <= insn_i;
                sbuf_if.idata1 <= idata1_i;
                sbuf_if.idata2 <= idata2_i;
                sbuf_if.fdata1 <= fdata1_i;
                sbuf_if.fdata2 <= fdata2_i;
                sbuf_if.tags   <= tags_i;
            end

            sbuf_if.rdy <= rdy_i || (sbuf_if.rdy && !sbuf_if.ack);

            if(flush_i == 1'b1) begin
                sbuf_if.rdy <= 1'b0;
            end

        end
    end

    assign ack_o = sbuf_if.ack;

endmodule : rv0_sbuf
