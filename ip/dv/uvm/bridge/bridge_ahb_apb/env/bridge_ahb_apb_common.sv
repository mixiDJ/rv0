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
// Name: bridge_ahb_apb_common.sv
// Auth: Nikola Lukić
// Date: 01.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef BRIDGE_AHB_APB_COMMON_SV
`define BRIDGE_AHB_APB_COMMON_SV

`ifndef AHB_ENV_ADDR_WIDTH
`define AHB_ENV_ADDR_WIDTH 32
`endif // AHB_ENV_ADDR_WIDTH

`ifndef AHB_ENV_DATA_WIDTH
`define AHB_ENV_DATA_WIDTH 32
`endif // AHB_ENV_DATA_WIDTH

`ifndef AHB_ENV_HBURST_WIDTH
`define AHB_ENV_HBURST_WIDTH 4
`endif // AHB_ENV_HBURST_WIDTH

`ifndef AHB_ENV_HPROT_WIDTH
`define AHB_ENV_HPROT_WIDTH 4
`endif // AHB_ENV_HPROT_WIDTH

`ifndef AHB_ENV_HMASTER_WIDTH
`define AHB_ENV_HMASTER_WIDTH 1
`endif // AHB_ENV_HMASTER_WIDTH

`ifndef AHB_ENV_USER_REQ_WIDTH
`define AHB_ENV_USER_REQ_WIDTH 0
`endif // AHB_ENV_USER_REQ_WIDTH

`ifndef AHB_ENV_USER_DATA_WIDTH
`define AHB_ENV_USER_DATA_WIDTH 0
`endif // AHB_ENV_USER_DATA_WIDTH

`ifndef AHB_ENV_USER_RESP_WIDTH
`define AHB_ENV_USER_RESP_WIDTH 0
`endif // AHB_ENV_USER_RESP_WIDTH

`ifndef AHB_ENV_PARAM_LST
`define AHB_ENV_PARAM_LST                                   \
    .ADDR_WIDTH         (`AHB_ENV_ADDR_WIDTH        ),      \
    .DATA_WIDTH         (`AHB_ENV_DATA_WIDTH        ),      \
    .HBURST_WIDTH       (`AHB_ENV_HBURST_WIDTH      ),      \
    .HPROT_WIDTH        (`AHB_ENV_HPROT_WIDTH       ),      \
    .HMASTER_WIDTH      (`AHB_ENV_HMASTER_WIDTH     ),      \
    .USER_REQ_WIDTH     (`AHB_ENV_USER_REQ_WIDTH    ),      \
    .USER_DATA_WIDTH    (`AHB_ENV_USER_DATA_WIDTH   ),      \
    .USER_RESP_WIDTH    (`AHB_ENV_USER_RESP_WIDTH   )
`endif // AHB_ENV_PARAM_LST

`ifndef BRIDGE_AHB_APB_PARAMS
`define BRIDGE_AHB_APB_PARAMS                               \
    parameter  int unsigned ADDR_WIDTH      = 32,           \
    parameter  int unsigned DATA_WIDTH      = 32,           \
    parameter  int unsigned HBURST_WIDTH    = 4,            \
    parameter  int unsigned HPROT_WIDTH     = 4,            \
    parameter  int unsigned HMASTER_WIDTH   = 1,            \
    parameter  int unsigned USER_REQ_WIDTH  = 0,            \
    parameter  int unsigned USER_DATA_WIDTH = 0,            \
    parameter  int unsigned USER_RESP_WIDTH = 0,            \
    localparam int unsigned STRB_WIDTH = DATA_WIDTH / 8
`endif // BRIDGE_AHB_APB_PARAMS

`ifndef BRIDGE_AHB_APB_PARAM_LST
`define BRIDGE_AHB_APB_PARAM_LST                \
    .ADDR_WIDTH         (ADDR_WIDTH         ),  \
    .DATA_WIDTH         (DATA_WIDTH         ),  \
    .HBURST_WIDTH       (HBURST_WIDTH       ),  \
    .HPROT_WIDTH        (HPROT_WIDTH        ),  \
    .HMASTER_WIDTH      (HMASTER_WIDTH      ),  \
    .USER_REQ_WIDTH     (USER_REQ_WIDTH     ),  \
    .USER_DATA_WIDTH    (USER_DATA_WIDTH    ),  \
    .USER_RESP_WIDTH    (USER_RESP_WIDTH    )
`endif // BRIDGE_AHB_APB_PARAM_LST

`uvm_analysis_imp_decl(_ahb)
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_clk_ahb)
`uvm_analysis_imp_decl(_clk_apb)

`endif // BRIDGE_AHB_APB_COMMON_SV
