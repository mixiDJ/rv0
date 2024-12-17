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
// Name: sva_utils_generic.svh
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

`ifndef SVA_UTILS_GENERIC_SVH
`define SVA_UTILS_GENERIC_SVH

`ifndef ASSERT
`define ASSERT(__name, __prop, __clk=`ASSERT_DEFAULT_CLK, __rst=`ASSERT_DEFAULT_RST)                \
    __name : assert property(@(posedge __clk) disable iff (__rst) (__prop));
`endif // ASSERT

`ifndef ASSERT_I
`define ASSERT_I(__name, __prop)                                                                    \
    __name : assert(__prop);
`endif // ASSERT_I

`ifndef ASSERT_INIT
`ifdef FORMAL
`define ASSERT_INIT(__name, __prop)                                                                 \
    initial begin                                                                                   \
        __name : assert(__prop);                                                                    \
    end
`else
`define ASSERT_INIT(__name, __prop)                                                                 \
    initial begin                                                                                   \
        __name : assert(__prop);                                                                    \
    end
`endif // FORMAL
`endif // ASSERT_INIT

`ifndef ASSERT_KNOWN
`define ASSERT_KNOWN(__name, __sig, __clk=`ASSERT_DEFAULT_CLK, __rst=`ASSERT_DEFAULT_RST)           \
    __name : assert property(@(posedge __clk) disable iff (__rst) (!$isunknown(__sig)));
`endif // ASSERT_KNOWN

`ifndef ASSUME
`define ASSUME(__name, __prop, __clk=`ASSERT_DEFAULT_CLK, __rst=`ASSERT_DEFAULT_RST)                \
    ___name : assume property(@(posedge __clk) disable iff (!__rst) (__prop));
`endif // ASSUME

`endif // SVA_UTILS_GENERIC_SVH
