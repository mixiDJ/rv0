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
// Name: bridge_ahb_apb_env.sv
// Auth: Nikola Lukić
// Date: 01.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef BRIDGE_AHB_APB_ENV_SV
`define BRIDGE_AHB_APB_ENV_SV

class bridge_ahb_apb_env #(`BRIDGE_AHB_APB_PARAMS) extends uvm_env;

    typedef bridge_ahb_apb_cfg                                      cfg_t;
    typedef clk_uvc_cfg                                             clk_cfg_t;
    typedef clk_uvc_env                                             clk_env_t;
    typedef ahb_uvc_cfg                                             ahb_cfg_t;
    typedef ahb_uvc_env#(`AHB_UVC_PARAM_LST)                        ahb_env_t;
    typedef apb_uvc_cfg                                             apb_cfg_t;
    typedef apb_uvc_env#(`APB_UVC_PARAM_LST)                        apb_env_t;
    typedef bridge_ahb_apb_scoreboard#(`BRIDGE_AHB_APB_PARAM_LST)   scoreboard_t;
    typedef bridge_ahb_apb_vsequencer#(`BRIDGE_AHB_APB_PARAM_LST)   vsequencer_t;
    typedef bridge_ahb_apb_cov_ahb#(`AHB_UVC_PARAM_LST)             cov_ahb_t;
    typedef bridge_ahb_apb_cov_apb#(`APB_UVC_PARAM_LST)             cov_apb_t;

    /* ENVIRONMENT ANALYSIS PORTS */

    /* ENVIRONMENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* ENVIRONMENT COMPONENTS */
    clk_env_t       m_clk_env;
    ahb_env_t       m_ahb_env;
    apb_env_t       m_apb_env;

    scoreboard_t    m_scoreboard;
    vsequencer_t    m_vsequencer;

    cov_ahb_t       m_cov_ahb;
    cov_apb_t       m_cov_apb;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(bridge_ahb_apb_env#(`BRIDGE_AHB_APB_PARAM_LST))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : bridge_ahb_apb_env

function void bridge_ahb_apb_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get environment config object
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // print environment config
    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    // create AHB environment component
    m_ahb_env = ahb_env_t::type_id::create("m_ahb_env", this);

    // set AHB environment config
    `uvm_config_db_set(ahb_cfg_t, this, "m_ahb_env", "m_cfg", m_cfg.ahb_env_cfg)

    // create APB environment component
    m_apb_env = apb_env_t::type_id::create("m_apb_env", this);

    // set APB environment config
    `uvm_config_db_set(apb_cfg_t, this, "m_apb_env", "m_cfg", m_cfg.apb_env_cfg)

    // set clock environment config
    m_clk_env = clk_env_t::type_id::create("m_clk_env", this);

    // create clock environment component
    `uvm_config_db_set(clk_cfg_t, this, "m_clk_env", "m_cfg", m_cfg.clk_env_cfg)

    // create scoreboard component
    m_scoreboard = scoreboard_t::type_id::create("m_scoreboard", this);

    // set scoreboard config
    `uvm_config_db_set(cfg_t, this, "m_scoreboard", "m_cfg", m_cfg)

    // create virtual sequencer component
    m_vsequencer = vsequencer_t::type_id::create("m_vsequencer", this);

    // set virtual sequencer config
    `uvm_config_db_set(cfg_t, this, "m_vsequencer", "m_cfg", m_cfg)

    // create AHB subscriber
    m_cov_ahb = cov_ahb_t::type_id::create("m_cov_ahb", this);

    // create APB subscriber
    m_cov_apb = cov_apb_t::type_id::create("m_cov_apb", this);

endfunction : build_phase

function void bridge_ahb_apb_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // set virtual sequencer handles
    if(m_cfg.ahb_env_cfg.has_master_agent && m_cfg.ahb_env_cfg.master_agent_cfg.agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_ahb_master_seqr = m_ahb_env.m_master_agent.m_sequencer;
    end

    if(m_cfg.apb_env_cfg.has_slave_agent && m_cfg.apb_env_cfg.slave_agent_cfg.agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_apb_slave_seqr = m_apb_env.m_slave_agent.m_sequencer;
    end

    m_vsequencer.m_clk_seqr = new[m_cfg.clk_env_cfg.agent_cnt];

    for(int i = 0; i < m_cfg.clk_env_cfg.agent_cnt; ++i) begin
        if(m_cfg.clk_env_cfg.agent_cfg[i].agent_type == UVM_ACTIVE) begin
            m_vsequencer.m_clk_seqr[i] = m_clk_env.m_agent[i].m_sequencer;
        end
    end

    // connect scoreboard analysis ports
    m_ahb_env.m_master_rsp_aport.connect(m_scoreboard.m_ahb_master_rsp_imp);
    m_apb_env.m_slave_rsp_aport.connect(m_scoreboard.m_apb_slave_rsp_imp);
    m_clk_env.m_aport[0].connect(m_scoreboard.m_clk_imp_0);
    m_clk_env.m_aport[1].connect(m_scoreboard.m_clk_imp_1);

    // connect subscriber analysis ports
    m_ahb_env.m_master_rsp_aport.connect(m_cov_ahb.m_ahb_master_rsp_imp);
    m_apb_env.m_slave_rsp_aport.connect(m_cov_apb.m_apb_slave_rsp_imp);

endfunction : connect_phase

`endif // BRIDGE_AHB_APB_ENV_SV
