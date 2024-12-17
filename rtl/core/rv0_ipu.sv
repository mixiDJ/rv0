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
// Source location:
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: rv0_ipu.sv
// Auth: Nikola Lukić
// Date: 24.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module rv0_ipu #(`RV0_CORE_PARAM_LST) (

    input  logic        clk_i,
    input  logic        rst_ni,

    input  logic        ipu_flush_i,

    rv_sbuf_if.sink     ifu_sbuf_if,
    rv_sbuf_if.source   ipu_sbuf_if

);

if(RVC == 1'b1) begin
    // TODO
end
else begin

    // bypass pre-decode unit if compressed
    // instruction support is disabled
    assign ipu_sbuf_if.insn = ifu_sbuf_if.insn;
    assign ipu_sbuf_if.addr = ifu_sbuf_if.addr;
    assign ipu_sbuf_if.rdy  = ifu_sbuf_if.rdy;
    assign ifu_sbuf_if.ack  = ipu_sbuf_if.ack;

end

endmodule : rv0_ipu
