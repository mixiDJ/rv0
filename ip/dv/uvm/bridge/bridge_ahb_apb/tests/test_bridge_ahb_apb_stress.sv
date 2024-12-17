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
// Name: test_bridge_ahb_apb_stress.sv
// Auth: Nikola Lukić
// Date: 18.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef TEST_BRIDGE_AHB_APB_STRESS_SV
`define TEST_BRIDGE_AHB_APB_STRESS_SV

class test_bridge_ahb_apb_stress extends test_bridge_ahb_apb_base;

    typedef bridge_ahb_apb_vseq_stress#(`BRIDGE_AHB_APB_PARAM_LST) vseq_stress_t;

    /* REGISTRATION MACRO */
    `uvm_component_utils(test_bridge_ahb_apb_stress)
    `uvm_component_new

    /* TEST SEQUENCES */
    vseq_stress_t m_vseq_stress;

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

endclass : test_bridge_ahb_apb_stress

function void test_bridge_ahb_apb_stress::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase

function void test_bridge_ahb_apb_stress::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase

task test_bridge_ahb_apb_stress::run_phase(uvm_phase phase);
    super.run_phase(phase);

    uvm_test_done.raise_objection(this, `gtn);

    `uvm_start_on(m_vseq_stress, m_env.m_vsequencer)
    #2000ns;

    phase.drop_objection(this);

endtask : run_phase

`endif // TEST_BRIDGE_AHB_APB_STRESS_SV
