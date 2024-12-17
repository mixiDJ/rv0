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
// Name: dly_utils.svh
// Auth: Nikola Lukić (luk)
// Date: 05.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

//`ifndef DLY_UTILS_SVH
//`define DLY_UTILS_SVH

typedef enum int {
    DLY_ZERO,
    DLY_MIN,
    DLY_MED,
    DLY_LNG,
    DLY_MAX
} delay_type_e;

typedef delay_type_e dly_typ_e;

`define DLY_RANGE_ZERO  {[ 0: 0]}
`define DLY_RANGE_MIN   {[ 1: 5]}
`define DLY_RANGE_MED   {[ 5:10]}
`define DLY_RANGE_LNG   {[10:30]}
`define DLY_RANGE_MAX   {[30:50]}

`define DELAY_RANGE_CONSTRAINT(__dly, __dly_type)                           \
    solve __dly_type before __dly;                                          \
    (__dly_type == DLY_ZERO) -> __dly inside `DLY_RANGE_ZERO;               \
    (__dly_type == DLY_MIN)  -> __dly inside `DLY_RANGE_MIN;                \
    (__dly_type == DLY_MED)  -> __dly inside `DLY_RANGE_MED;                \
    (__dly_type == DLY_LNG)  -> __dly inside `DLY_RANGE_LNG;                \
    (__dly_type == DLY_MAX)  -> __dly inside `DLY_RANGE_MAX;                \

//`endif // DLY_UTILS_SVH
