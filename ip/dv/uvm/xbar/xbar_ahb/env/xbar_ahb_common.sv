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
// Name: xbar_ahb_common.sv
// Auth: Nikola Lukić
// Date: 27.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef XBAR_AHB_COMMON_SV
`define XBAR_AHB_COMMON_SV

`ifndef XBAR_AHB_PARAMS
`define XBAR_AHB_PARAMS                                                                            \
    `AHB_UVC_PARAMS,                                                                               \
    parameter int unsigned          XBAR_REQUESTER_CNT                      = 4,                   \
    parameter int unsigned          XBAR_COMPLETER_CNT                      = 4,                   \
    parameter bit [ADDR_WIDTH-1:0]  XBAR_ADDR_BASE [0:XBAR_COMPLETER_CNT-1] = '{default: 'h0},     \
    parameter bit [ADDR_WIDTH-1:0]  XBAR_ADDR_MASK [0:XBAR_COMPLETER_CNT-1] = '{default: 'h0}
`endif // XBAR_AHB_PARAMS

`ifndef XBAR_AHB_PARAM_LST
`define XBAR_AHB_PARAM_LST                         \
    `AHB_UVC_PARAM_LST,                            \
    .XBAR_REQUESTER_CNT (XBAR_REQUESTER_CNT),      \
    .XBAR_COMPLETER_CNT (XBAR_COMPLETER_CNT),      \
    .XBAR_ADDR_BASE     (XBAR_ADDR_BASE    ),      \
    .XBAR_ADDR_MASK     (XBAR_ADDR_MASK    )
`endif // XBAR_AHB_PARAM_LST

`uvm_analysis_imp_decl(_clk)
`uvm_analysis_imp_decl(_ahb_master_req)
`uvm_analysis_imp_decl(_ahb_master_rsp)
`uvm_analysis_imp_decl(_ahb_slave_req)
`uvm_analysis_imp_decl(_ahb_slave_rsp)

`endif // XBAR_AHB_COMMON_SV
