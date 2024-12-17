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
// Name: apb_uvc_common.sv
// Auth: Nikola Lukić
// Date: 16.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef APB_UVC_COMMON_SV
`define APB_UVC_COMMON_SV

`ifndef APB_UVC_PARAM_LST
`define APB_UVC_PARAM_LST                                                   \
    parameter  int unsigned ADDR_WIDTH          = 32,                       \
    parameter  int unsigned DATA_WIDTH          = 32,                       \
    parameter  int unsigned USER_REQ_WIDTH      = 0,                        \
    parameter  int unsigned USER_DATA_WIDTH     = 0,                        \
    parameter  int unsigned USER_RESP_WIDTH     = 0,                        \
    localparam int unsigned STRB_WIDTH          = DATA_WIDTH/8,             \
    localparam int unsigned ADDR_CHK_WIDTH      = $ceil(ADDR_WIDTH/8),      \
    localparam int unsigned DATA_CHK_WIDTH      = $ceil(DATA_WIDTH/8),      \
    localparam int unsigned USER_REQ_CHK_WIDTH  = $ceil(USER_REQ_WIDTH/8),  \
    localparam int unsigned USER_DATA_CHK_WIDTH = $ceil(USER_DATA_WIDTH/8), \
    localparam int unsigned USER_RESP_CHK_WIDTH = $ceil(USER_RESP_WIDTH/8)
`endif // APB_UVC_PARAMS

`ifndef APB_UVC_PARAMS
`define APB_UVC_PARAMS                          \
    .ADDR_WIDTH         (ADDR_WIDTH         ),  \
    .DATA_WIDTH         (DATA_WIDTH         ),  \
    .USER_REQ_WIDTH     (USER_REQ_WIDTH     ),  \
    .USER_DATA_WIDTH    (USER_DATA_WIDTH    ),  \
    .USER_RESP_WIDTH    (USER_RESP_WIDTH    )
`endif // APB_UVC_PARAM_LST

`endif // APB_UVC_COMMON_SV
