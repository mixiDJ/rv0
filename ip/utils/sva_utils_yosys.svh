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
// Name: sva_utils_yosys.svh
// Auth: Nikola Lukić (luk)
// Date: 28.08.2024.
// Desc: ***
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef SVA_UTILS_YOSYS_SVH
`define SVA_UTILS_YOSYS_SVH

`define ASSERT(__name, __prop, __clk=`ASSERT_DEFAULT_CLK, __rst=`ASSERT_DEFAULT_RST)                \
    always @(posedge __clk) begin                                                                   \
        if((!(__rst !== 'b1))) __name : assert((__prop));                                           \
    end

`define ASSERT_I(__name, __prop)                                                                    \
    always_comb begin                                                                               \
        __name : assert((__prop));                                                                  \
    end

`define ASSERT_INIT(__name, __prop)                                                                 \
    initial begin                                                                                   \
        __name : assert((__prop));                                                                  \
    end

`define ASSUME(__name, __prop, __clk=`ASSERT_DEFAULT_CLK, __rst=`ASSERT_DEFAULT_RST)                \
    always @(posedge __clk) begin                                                                   \
        if((!(__rst !== 'b1))) __name : assume((__prop));                                           \
    end

`define ASSUME_I(__name, __prop)                                                                    \
    always_comb begin                                                                               \
        __name : assume((__prop));                                                                  \
    end

`define ASSUME_INIT(__name, __prop)                                                                 \
    initial begin                                                                                   \
        __name : assume((__prop));                                                                  \
    end

`define COVER(__name, __prop, __clk=`ASSERT_DEFAULT_CLK, __rst=`ASSERT_DEFAULT_RST)                 \
    always @(posedge __clk) begin                                                                   \
        if((!(__rst !== 'b1))) __name : cover((__prop));                                            \
    end

`endif // SVA_UTILS_YOSYS_SVH
