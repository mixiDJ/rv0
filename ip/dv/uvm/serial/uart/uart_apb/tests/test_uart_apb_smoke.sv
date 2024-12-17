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
// Name: test_uart_apb_smoke.sv
// Auth: Nikola Lukić
// Date: 24.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef TEST_UART_APB_SMOKE_SV
`define TEST_UART_APB_SMOKE_SV

class test_uart_apb_smoke extends test_uart_apb_base;

    typedef uart_apb_vseq_smoke vseq_smoke_t;

    /* REGISTRATION MACRO */
    `uvm_component_utils(test_uart_apb_smoke)
    `uvm_component_new

    /* TEST SEQUENCES */
    vseq_smoke_t m_vseq_smoke;

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

endclass : test_uart_apb_smoke

function void test_uart_apb_smoke::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase

function void test_uart_apb_smoke::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase

task test_uart_apb_smoke::run_phase(uvm_phase phase);
    super.run_phase(phase);

    uvm_test_done.raise_objection(this, `gtn);
    `uvm_info(`gtn, "TEST STARTED", UVM_LOW)

    `uvm_start_on(
        m_vseq_smoke,
        m_env.m_vsequencer
    )

    #5ms;

    phase.drop_objection(this);
    `uvm_info(`gtn, "TEST FINISHED", UVM_LOW)

endtask : run_phase

`endif // TEST_UART_APB_SMOKE_SV
