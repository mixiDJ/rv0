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
// Name: rv_layering_uvc_common.sv
// Auth: Nikola Lukić
// Date: 16.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_LAYERING_UVC_COMMON_SV
`define RV_LAYERING_UVC_COMMON_SV

`define RV_LAYERING_UVC_PARAM_LST                                           \
    `RV_UVC_PARAM_LST,                                                      \
    parameter type IF_ITEM_T   = uvm_sequence_item,                         \
    parameter type IF_SEQR_T   = uvm_sequencer#(IF_ITEM_T)

`define RV_LAYERING_UVC_PARAMS                                              \
    `RV_UVC_PARAMS,                                                         \
    .IF_ITEM_T  (IF_ITEM_T  ),                                              \
    .IF_SEQR_T  (IF_SEQR_T  )

`endif // RV_LAYERING_UVC_COMMON_SV
