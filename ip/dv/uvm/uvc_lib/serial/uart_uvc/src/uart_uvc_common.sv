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
// Name: uart_uvc_common.sv
// Auth: Nikola Lukić
// Date: 11.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_UVC_COMMON_SV
`define UART_UVC_COMMON_SV

typedef enum bit {
    PAR_TYP_EVEN,
    PAR_TYP_ODD
} par_typ_e;

`ifndef UART_BIT_TIME
`define UART_BIT_TIME(__baud_rate) (1s/(__baud_rate))
`endif // UART_BIT_TIME

`ifndef UART_FRAME_SIZE
`define UART_FRAME_SIZE(__cfg) (1 + __cfg.data_bits + __cfg.par_bit + __cfg.stop_bits)
`endif // UART_FRAME_SIZE

`endif // UART_UVC_COMMON_SV
