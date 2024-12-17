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
// Name: test_rv0_core_base.sv
// Auth: Nikola Lukić
// Date: 13.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef TEST_RV0_CORE_BASE_SV
`define TEST_RV0_CORE_BASE_SV

class test_rv0_core_base #(`RV0_CORE_ENV_PARAM_LST) extends uvm_test;

    typedef rv0_core_cfg                            cfg_t;
    typedef rv0_core_env#(`RV0_CORE_ENV_PARAMS)     env_t;

    /* BASE TEST CONFIG OBJECT */
    cfg_t m_cfg;

    /* BASE TEST COMPONENTS */
    env_t m_env;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(test_rv0_core_base#(`RV0_CORE_ENV_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);

    /* METHODS */
    extern virtual function void set_test_override_cfg();
    extern virtual function void set_test_build_cfg();
    extern virtual function void set_test_run_cfg();

endclass : test_rv0_core_base

function void test_rv0_core_base::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // set test type override config
    set_test_override_cfg();

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

function void test_rv0_core_base::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    set_test_run_cfg();
endfunction : start_of_simulation_phase

function void test_rv0_core_base::set_test_override_cfg();

    set_type_override_by_type(
        rv_layering_uvc_seq_base#(`RV_LAYERING_UVC_PARAMS)::get_type(),
        rv_layering_ahb_uvc_seq_base#(`RV_LAYERING_UVC_PARAMS)::get_type()
    );

endfunction : set_test_override_cfg

function void test_rv0_core_base::set_test_build_cfg();

    m_cfg.clk_env_cfg.agent_cnt = 1;

    m_cfg.imem_env_cfg.has_master_agent = 0;
    m_cfg.imem_env_cfg.has_slave_agent  = 1;

    m_cfg.dmem_env_cfg.has_master_agent = 0;
    m_cfg.dmem_env_cfg.has_slave_agent  = 1;

endfunction : set_test_build_cfg

function void test_rv0_core_base::set_test_run_cfg();

    m_cfg.clk_env_cfg.agent_cfg[0].rst_init = 1;

    m_env.m_imem_env.set_report_verbosity_level_hier(UVM_LOW);
    m_env.m_rv_env.set_report_verbosity_level_hier(UVM_LOW);
    m_env.m_iret_env.set_report_verbosity_level_hier(UVM_LOW);

endfunction : set_test_run_cfg

`endif // TEST_RV0_CORE_BASE_SV
