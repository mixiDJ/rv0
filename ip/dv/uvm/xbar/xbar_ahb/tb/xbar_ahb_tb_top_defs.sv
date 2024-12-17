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
// Name: xbar_ahb_tb_top_defs.sv
// Auth: Nikola Lukić
// Date: 29.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef XBAR_AHB_TB_TOP_DEFS_SV
`define XBAR_AHB_TB_TOP_DEFS_SV

`ifndef ADDR_WIDTH
`define ADDR_WIDTH 32
`endif // ADDR_WIDTH

`ifndef DATA_WIDTH
`define DATA_WIDTH 32
`endif // DATA_WIDTH

`ifndef HBURST_WIDTH
`define HBURST_WIDTH 4
`endif // HBURST_WIDTH

`ifndef HPORT_WIDTH
`define HPROT_WIDTH 4
`endif // HPROT_WIDTH

`ifndef HMASTER_WIDTH
`define HMASTER_WIDTH 1
`endif // HMASTER_WIDTH

`ifndef USER_REQ_WIDTH
`define USER_REQ_WIDTH 1
`endif // USER_REQ_WIDTH

`ifndef USER_DATA_WIDTH
`define USER_DATA_WIDTH 1
`endif // USER_DATA_WIDTH

`ifndef USER_RESP_WIDTH
`define USER_RESP_WIDTH 1
`endif // USER_RESP_WIDTH

`ifndef XBAR_REQUESTER_CNT
`define XBAR_REQUESTER_CNT 8
`endif // XBAR_REQUESTER_CNT

`ifndef XBAR_COMPLETER_CNT
`define XBAR_COMPLETER_CNT 8
`endif // XBAR_COMPLETER_CNT

`ifndef XBAR_ADDR_BASE
`define XBAR_ADDR_BASE      \
    {                       \
        32'h0000_0000,      \
        32'h0001_0000,      \
        32'h0010_0000,      \
        32'h0100_0000,      \
        32'h0200_0000,      \
        32'h0300_0000,      \
        32'h0800_0000,      \
        32'h8000_0000       \
    }
`endif // XBAR_ADDR_BASE

`ifndef XBAR_ADDR_MASK
`define XBAR_ADDR_MASK      \
    {                       \
        32'hffff_f000,      \
        32'hffff_0000,      \
        32'hfff0_0000,      \
        32'hfe00_0000,      \
        32'hfe00_0000,      \
        32'hfe00_0000,      \
        32'hf800_0000,      \
        32'h8000_0000       \
    }
`endif // XBAR_ADDR_MASK

`endif // XBAR_AHB_TB_TOP_DEFS_SV
