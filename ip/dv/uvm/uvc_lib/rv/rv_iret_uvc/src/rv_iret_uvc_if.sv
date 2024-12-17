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
// Source location: svn://lukic.sytes.net/ip
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: rv_iret_uvc_if.sv
// Auth: Nikola Lukić
// Date: 03.12.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_IRET_UVC_IF_SV
`define RV_IRET_UVC_IF_SV

interface rv_iret_uvc_if #(`RV_IRET_UVC_PARAM_LST) (
    input logic clk,
    input logic rst_n
);

    /* INTERFACE SIGNALS */
    logic [XLEN-1:0]    addr;
    logic [31:0]        insn;
    logic [XLEN-1:0]    ires;
    logic [FLEN-1:0]    fres;
    logic               iret;

endinterface : rv_iret_uvc_if

`endif // RV_IRET_UVC_IF_SV
