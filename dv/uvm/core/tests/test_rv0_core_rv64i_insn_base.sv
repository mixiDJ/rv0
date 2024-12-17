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
// Name: test_rv0_core_rv64i_insn_base.sv
// Auth: Nikola Lukić
// Date: 03.12.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef TEST_RV0_CORE_RV64I_INSN_BASE_SV
`define TEST_RV0_CORE_RV64I_INSN_BASE_SV

class test_rv0_core_rv64i_insn_base #(`RV0_CORE_ENV_PARAM_LST) extends test_rv0_core_insn_base#(`RV0_CORE_ENV_PARAMS);

    /* REGISTRATION MACRO */
    `uvm_component_registry(test_rv0_core_rv64i_insn_base#(`RV0_CORE_ENV_PARAMS), "test_rv0_core_rv64i_insn_base")
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

endclass : test_rv0_core_rv64i_insn_base

function void test_rv0_core_rv64i_insn_base::build_phase(uvm_phase phase);
    super.build_phase(phase);

    chk_test_cfg_xlen64 : assert(XLEN == 64)
    else begin
        `uvm_fatal(`gtn, "UNSUPPORTED ISA CONFIGURATION")
    end

endfunction : build_phase

task test_rv0_core_rv64i_insn_base::run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask : run_phase

`endif // TEST_RV0_CORE_RV64I_INSN_BASE_SV
