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
// Name: test_clk_uvc_example.sv
// Auth: Nikola Lukić
// Date: 04.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef TEST_CLK_UVC_EXAMPLE_SV
`define TEST_CLK_UVC_EXAMPLE_SV

class test_clk_uvc_example extends uvm_test;

    typedef clk_uvc_example_cfg     cfg_t;
    typedef clk_uvc_example_env     env_t;

    /* BASE TEST CONFIG OBJECT */
    cfg_t m_cfg;

    /* BASE TEST COMPONENTS */
    env_t m_env;

    /* REGISTRATION MACRO */
    `uvm_component_utils(test_clk_uvc_example)
    `uvm_component_new

    /* UVM METHODS */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual function void extract_phase(uvm_phase phase);
    extern virtual function void check_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
    extern virtual function void final_phase(uvm_phase phase);

    /* UVM RUNTIME PHASES */
    extern virtual task pre_reset_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task post_reset_phase(uvm_phase phase);
    extern virtual task pre_configure_phase(uvm_phase phase);
    extern virtual task configure_phase(uvm_phase phase);
    extern virtual task post_configure_phase(uvm_phase phase);
    extern virtual task pre_main_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    extern virtual task post_main_phase(uvm_phase phase);
    extern virtual task pre_shutdown_phase(uvm_phase phase);
    extern virtual task shutdown_phase(uvm_phase phase);
    extern virtual task post_shutdown_phase(uvm_phase phase);

    /* METHODS */
    extern virtual function void set_test_build_cfg();
    extern virtual function void set_test_run_cfg();

endclass : test_clk_uvc_example

function void test_clk_uvc_example::build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_env = env_t::type_id::create("m_env", this);

    m_cfg = cfg_t::type_id::create("m_cfg", this);
    set_test_build_cfg();

    `uvm_config_db_set(cfg_t, this, "m_env", "m_cfg", m_cfg)

    set_config_int("*", "recording_detail", 1);

endfunction : build_phase

function void test_clk_uvc_example::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase

function void test_clk_uvc_example::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

function void test_clk_uvc_example::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);

    set_test_run_cfg();

    // raise test done objection
    uvm_test_done.raise_objection(this, `gtn);
    `uvm_info(`gtn, "TEST STARTED", UVM_LOW)

endfunction : start_of_simulation_phase

task test_clk_uvc_example::run_phase(uvm_phase phase);
    super.run_phase(phase);

    uvm_test_done.raise_objection(this, `gtn);
    #5_000ns;
    m_cfg.clk_env_cfg.agent_cfg[0].clk_period = 50ns;
    #10_000ns;
    uvm_test_done.drop_objection(this);

endtask : run_phase

function void test_clk_uvc_example::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    `uvm_info(`gtn, "TEST_FINISHED", UVM_LOW)
endfunction : extract_phase

function void test_clk_uvc_example::check_phase(uvm_phase phase);
    super.check_phase(phase);
endfunction : check_phase

function void test_clk_uvc_example::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction : report_phase

function void test_clk_uvc_example::final_phase(uvm_phase phase);
    super.final_phase(phase);
endfunction : final_phase

task test_clk_uvc_example::pre_reset_phase(uvm_phase phase);
    super.pre_reset_phase(phase);
endtask : pre_reset_phase

task test_clk_uvc_example::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask : reset_phase

task test_clk_uvc_example::post_reset_phase(uvm_phase phase);
    super.post_reset_phase(phase);
endtask : post_reset_phase

task test_clk_uvc_example::pre_configure_phase(uvm_phase phase);
    super.pre_configure_phase(phase);
endtask : pre_configure_phase

task test_clk_uvc_example::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask : configure_phase

task test_clk_uvc_example::post_configure_phase(uvm_phase phase);
    super.post_configure_phase(phase);
endtask : post_configure_phase

task test_clk_uvc_example::pre_main_phase(uvm_phase phase);
    super.pre_main_phase(phase);
endtask : pre_main_phase

task test_clk_uvc_example::main_phase(uvm_phase phase);
    super.main_phase(phase);
endtask : main_phase

task test_clk_uvc_example::post_main_phase(uvm_phase phase);
    super.post_main_phase(phase);
endtask : post_main_phase

task test_clk_uvc_example::pre_shutdown_phase(uvm_phase phase);
    super.pre_shutdown_phase(phase);
endtask : pre_shutdown_phase

task test_clk_uvc_example::shutdown_phase(uvm_phase phase);
    super.shutdown_phase(phase);
endtask : shutdown_phase

task test_clk_uvc_example::post_shutdown_phase(uvm_phase phase);
    super.post_shutdown_phase(phase);
    uvm_test_done.drop_objection(this);
endtask : post_shutdown_phase

function void test_clk_uvc_example::set_test_build_cfg();
    m_cfg.clk_env_cfg.agent_cnt = 4;
endfunction : set_test_build_cfg

function void test_clk_uvc_example::set_test_run_cfg();
    m_cfg.clk_env_cfg.agent_cfg[0].clk_period = 20ns;
    m_cfg.clk_env_cfg.agent_cfg[0].clk_phase  = 0.0;
    m_cfg.clk_env_cfg.agent_cfg[1].clk_period = 20ns;
    m_cfg.clk_env_cfg.agent_cfg[1].clk_phase  = 90.0;
    m_cfg.clk_env_cfg.agent_cfg[2].clk_period = 20ns;
    m_cfg.clk_env_cfg.agent_cfg[2].clk_phase  = 180.0;
    m_cfg.clk_env_cfg.agent_cfg[3].clk_period = 20ns;
    m_cfg.clk_env_cfg.agent_cfg[3].clk_phase  = 270.0;
endfunction : set_test_run_cfg

`endif // TEST_CLK_UVC_EXAMPLE_SV
