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
// Name: uvm_utils.svh
// Auth: Nikola Lukić (luk)
// Date: 21.08.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
// 29.09.2024.  Lukić   added uvm_config_db macros
////////////////////////////////////////////////////////////////////////////////////////////////////

//`ifndef UVM_UTILS_SVH
//`define UVM_UTILS_SVH

`include "sva_utils.svh"

`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef gtn
`define gtn get_type_name()
`endif // gtn

`ifndef gfn
`define gfn get_full_name()
`endif // gfn

`ifndef uvm_object_new
`define uvm_object_new                                                          \
    function new(string name="");                                               \
        super.new(name);                                                        \
    endfunction : new
`endif // uvm_object_new

`ifndef uvm_component_new
`define uvm_component_new                                                       \
    function new(string name, uvm_component parent);                            \
        super.new(name, parent);                                                \
    endfunction : new
`endif // uvm_component_new

`ifndef uvm_start_on
`define uvm_start_on(__seq, __seqr)                                             \
    __seq = new(`"__seq`");                                                     \
    if(!__seq.randomize()) begin                                                \
        `uvm_fatal(`gtn, "Failed to randomize!")                                \
    end                                                                         \
    __seq.start(__seqr);
`endif // uvm_start_on

`ifndef uvm_start_on_with
`define uvm_start_on_with(__seq, __seqr, __cons)                                \
    __seq = new(`"__seq`");                                                     \
    if(!__seq.randomize() with __cons) begin                                    \
        `uvm_fatal(`gtn, "Failed to randomize!")                                \
    end                                                                         \
    __seq.start(__seqr);
`endif // uvm_start_on_with

`ifndef uvm_config_db_get
`define uvm_config_db_get(__type, __cntxt, __inst, __field, __val)              \
    if(!uvm_config_db#(__type)::get(__cntxt, __inst, __field, __val)) begin     \
        `uvm_fatal(`gtn, {"Failed to get ", __field, " from config DB!"})       \
    end
`endif // uvm_config_db_get

`ifndef uvm_config_db_set
`define uvm_config_db_set(__type, __cntxt, __inst, __field, __val)              \
    uvm_config_db#(__type)::set(__cntxt, __inst, __field, __val);
`endif // uvm_config_db_set

`include "dly_utils.svh"

typedef uvm_active_passive_enum uvm_agent_type_e;

//`endif // UVM_UTILS_SVH
