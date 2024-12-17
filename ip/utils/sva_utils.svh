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
// Name: sva_utils.svh
// Auth: Nikola Lukić (luk)
// Date: 21.08.2024.
// Desc: ***
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef SVA_UTILS_SVH
`define SVA_UTILS_SVH

`ifndef ASSERT_DEFAULT_CLK
`define ASSERT_DEFAULT_CLK  clk_i
`endif // ASSERT_DEFAULT_CLK

`ifndef ASSERT_DEFAULT_RST
`define ASSERT_DEFAULT_RST  rst_ni
`endif // ASSERT_DEFAULT_RST

`ifdef YOSYS
`include "sva_utils_yosys.svh"
`endif // YOSYS

`include "sva_utils_generic.svh"

`endif // SVA_UTILS_SVH
