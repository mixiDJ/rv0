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
// Name: test_bridge_ahb_apb_base.sv
// Auth: Nikola Lukić
// Date: 02.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef TEST_BRIDGE_AHB_APB_BASE_SV
`define TEST_BRIDGE_AHB_APB_BASE_SV

class test_bridge_ahb_apb_base extends uvm_test;

    localparam int unsigned ADDR_WIDTH      = 32;
    localparam int unsigned DATA_WIDTH      = 32;
    localparam int unsigned HBURST_WIDTH    = 4;
    localparam int unsigned HPROT_WIDTH     = 4;
    localparam int unsigned HMASTER_WIDTH   = 1;
    localparam int unsigned USER_REQ_WIDTH  = 4;
    localparam int unsigned USER_DATA_WIDTH = 4;
    localparam int unsigned USER_RESP_WIDTH = 4;

    typedef bridge_ahb_apb_cfg                              cfg_t;
    typedef bridge_ahb_apb_env#(`BRIDGE_AHB_APB_PARAM_LST)  env_t;

    /* BASE TEST CONFIG OBJECT */
    cfg_t m_cfg;

    /* BASE TEST COMPONENTS */
    env_t m_env;

    /* REGISTRATION MACRO */
    `uvm_component_utils(test_bridge_ahb_apb_base)
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

endclass : test_bridge_ahb_apb_base

function void test_bridge_ahb_apb_base::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // create top environment component
    m_env = env_t::type_id::create("m_env", this);

    // create top config object
    m_cfg = cfg_t::type_id::create("m_cfg", this);

    // set test build config
    set_test_build_cfg();

    // set top environment config
    `uvm_config_db_set(cfg_t, this, "m_env", "m_cfg", m_cfg)

    // set recording detail
    set_config_int("*", "recording_detail", 1);

endfunction : build_phase

function void test_bridge_ahb_apb_base::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction : connect_phase

function void test_bridge_ahb_apb_base::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
endfunction : end_of_elaboration_phase

function void test_bridge_ahb_apb_base::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    set_test_run_cfg();
endfunction : start_of_simulation_phase

task test_bridge_ahb_apb_base::run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask : run_phase

function void test_bridge_ahb_apb_base::extract_phase(uvm_phase phase);
    super.extract_phase(phase);
endfunction : extract_phase

function void test_bridge_ahb_apb_base::check_phase(uvm_phase phase);
    super.check_phase(phase);
endfunction : check_phase

function void test_bridge_ahb_apb_base::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction : report_phase

function void test_bridge_ahb_apb_base::final_phase(uvm_phase phase);
    super.final_phase(phase);
endfunction : final_phase

task test_bridge_ahb_apb_base::pre_reset_phase(uvm_phase phase);
    super.pre_reset_phase(phase);
endtask : pre_reset_phase

task test_bridge_ahb_apb_base::reset_phase(uvm_phase phase);
    super.reset_phase(phase);
endtask : reset_phase

task test_bridge_ahb_apb_base::post_reset_phase(uvm_phase phase);
    super.post_reset_phase(phase);
endtask : post_reset_phase

task test_bridge_ahb_apb_base::pre_configure_phase(uvm_phase phase);
    super.pre_configure_phase(phase);
endtask : pre_configure_phase

task test_bridge_ahb_apb_base::configure_phase(uvm_phase phase);
    super.configure_phase(phase);
endtask : configure_phase

task test_bridge_ahb_apb_base::post_configure_phase(uvm_phase phase);
    super.post_configure_phase(phase);
endtask : post_configure_phase

task test_bridge_ahb_apb_base::pre_main_phase(uvm_phase phase);
    super.pre_main_phase(phase);
endtask : pre_main_phase

task test_bridge_ahb_apb_base::main_phase(uvm_phase phase);
    super.main_phase(phase);
endtask : main_phase

task test_bridge_ahb_apb_base::post_main_phase(uvm_phase phase);
    super.post_main_phase(phase);
endtask : post_main_phase

task test_bridge_ahb_apb_base::pre_shutdown_phase(uvm_phase phase);
    super.pre_shutdown_phase(phase);
endtask : pre_shutdown_phase

task test_bridge_ahb_apb_base::shutdown_phase(uvm_phase phase);
    super.shutdown_phase(phase);
endtask : shutdown_phase

task test_bridge_ahb_apb_base::post_shutdown_phase(uvm_phase phase);
    super.post_shutdown_phase(phase);
endtask : post_shutdown_phase

function void test_bridge_ahb_apb_base::set_test_build_cfg();

    m_cfg.ahb_env_cfg.has_master_agent = 1;
    m_cfg.ahb_env_cfg.has_slave_agent  = 0;

    m_cfg.apb_env_cfg.has_master_agent = 0;
    m_cfg.apb_env_cfg.has_slave_agent  = 1;

    m_cfg.clk_env_cfg.agent_cnt = 2;

endfunction : set_test_build_cfg

function void test_bridge_ahb_apb_base::set_test_run_cfg();

    m_cfg.clk_env_cfg.agent_cfg[0].clk_period = 5ns;
    m_cfg.clk_env_cfg.agent_cfg[0].clk_phase  = 0.0;
    m_cfg.clk_env_cfg.agent_cfg[1].clk_period = 20ns;
    m_cfg.clk_env_cfg.agent_cfg[1].clk_phase  = 30.0;

    m_cfg.clk_env_cfg.agent_cfg[0].rst_init = 1;
    m_cfg.clk_env_cfg.agent_cfg[1].rst_init = 1;

endfunction : set_test_run_cfg

`endif // TEST_BRIDGE_AHB_APB_BASE_SV
