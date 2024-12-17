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
// Name: rv0_core_common.sv
// Auth: Nikola Lukić
// Date: 31.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV0_CORE_COMMON_SV
`define RV0_CORE_COMMON_SV

`define RV0_CORE_ENV_PARAM_LST                                                                      \
    `RV_LAYERING_UVC_PARAM_LST,                                                                     \
    parameter  bit [XLEN-1:0]       PC_RST_VAL      = 'h0010_0000,                                  \
    parameter  bit [XLEN-1:0]       VENDOR_ID       = 'h0,                                          \
    parameter  bit [XLEN-1:0]       ARCH_ID         = 'h0,                                          \
    parameter  bit [XLEN-1:0]       IMP_ID          = 'h0,                                          \
    parameter  bit [XLEN-1:0]       HART_ID         = 'h0,                                          \
    parameter  bit                  ROB_ENA         = 1'b0,                                         \
    parameter  bit                  MMU_ENA         = 1'b0,                                         \
    parameter  bit                  PMP_ENA         = 1'b0,                                         \
    `AHB_UVC_PARAM_LST

`define RV0_CORE_ENV_PARAMS                                                                         \
    `RV_LAYERING_UVC_PARAMS,                                                                        \
    .PC_RST_VAL         (PC_RST_VAL         ),                                                      \
    .VENDOR_ID          (VENDOR_ID          ),                                                      \
    .ARCH_ID            (ARCH_ID            ),                                                      \
    .IMP_ID             (IMP_ID             ),                                                      \
    .HART_ID            (HART_ID            ),                                                      \
    .ROB_ENA            (ROB_ENA            ),                                                      \
    .MMU_ENA            (MMU_ENA            ),                                                      \
    .PMP_ENA            (PMP_ENA            ),                                                      \
    `AHB_UVC_PARAMS

typedef enum int {
    REG_ZERO,
    REG_RAND,
    REG_UNKN
} reg_init_type_e;

`endif // RV0_CORE_COMMON_SV
