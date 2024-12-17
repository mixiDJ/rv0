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
// Name: apb_uvc_example_env.sv
// Auth: Nikola Lukić
// Date: 14.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef APB_UVC_EXAMPLE_ENV_SV
`define APB_UVC_EXAMPLE_ENV_SV

class apb_uvc_example_env extends uvm_env;

    typedef apb_uvc_env#(.DATA_WIDTH(64))                   apb_env_t;
    typedef apb_uvc_example_vsequencer#(.DATA_WIDTH(64))    vsequencer_t;
    typedef apb_uvc_example_cfg                             cfg_t;

    /* ENVIRONMENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* ENVIRONMENT COMPONENTS */
    apb_env_t       m_apb_env;
    vsequencer_t    m_vsequencer;

    /* REGISTRATION MACRO */
    `uvm_component_utils(apb_uvc_example_env)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : apb_uvc_example_env

function void apb_uvc_example_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get top environment config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // print top environment configuration
    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    // create APB environment component
    m_apb_env = apb_env_t::type_id::create("m_apb_env", this);

    // set APB environment configuration
    `uvm_config_db_set(apb_uvc_cfg, this, "m_apb_env", "m_cfg", m_cfg.apb_env_cfg)

    // create virtual sequencer component
    m_vsequencer = vsequencer_t::type_id::create("m_vsequencer", this);

    // set virtual sequencer configuration
    `uvm_config_db_set(cfg_t, this, "m_vsequencer", "m_cfg", m_cfg)

endfunction : build_phase

function void apb_uvc_example_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(m_cfg.apb_env_cfg.has_master_agent && m_cfg.apb_env_cfg.master_agent_cfg.agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_apb_master_seqr = m_apb_env.m_master_agent.m_sequencer;
    end

    if(m_cfg.apb_env_cfg.has_slave_agent && m_cfg.apb_env_cfg.slave_agent_cfg.agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_apb_slave_seqr = m_apb_env.m_slave_agent.m_sequencer;
    end

endfunction : connect_phase

`endif // APB_UVC_EXAMPLE_ENV_SV
