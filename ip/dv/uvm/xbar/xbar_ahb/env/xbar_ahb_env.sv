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
// Name: xbar_ahb_env.sv
// Auth: Nikola Lukić
// Date: 27.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef XBAR_AHB_ENV_SV
`define XBAR_AHB_ENV_SV

class xbar_ahb_env #(`XBAR_AHB_PARAMS) extends uvm_env;

    typedef clk_uvc_env                                 clk_env_t;
    typedef clk_uvc_cfg                                 clk_cfg_t;
    typedef ahb_uvc_env#(`AHB_UVC_PARAM_LST)            ahb_env_t;
    typedef ahb_uvc_cfg                                 ahb_cfg_t;
    typedef xbar_ahb_scoreboard#(`XBAR_AHB_PARAM_LST)   scoreboard_t;
    typedef xbar_ahb_vsequencer#(`XBAR_AHB_PARAM_LST)   vsequencer_t;
    typedef xbar_ahb_cfg#(`XBAR_AHB_PARAM_LST)          cfg_t;

    /* ENVIRONMENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* ENVIRONMENT COMPONENTS */
    clk_env_t       m_clk_env;
    ahb_env_t       m_ahb_master_env [0:XBAR_REQUESTER_CNT-1];
    ahb_env_t       m_ahb_slave_env  [0:XBAR_COMPLETER_CNT-1];

    scoreboard_t    m_scoreboard;
    vsequencer_t    m_vsequencer;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(xbar_ahb_env#(`XBAR_AHB_PARAM_LST))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : xbar_ahb_env

function void xbar_ahb_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    m_clk_env = clk_env_t::type_id::create("m_clk_env", this);

    `uvm_config_db_set(clk_cfg_t, this, "m_clk_env", "m_cfg", m_cfg.clk_env_cfg)

    for(uint i = 0; i < XBAR_REQUESTER_CNT; ++i) begin
        string ahb_env_id = $sformatf("m_ahb_master_env_%0d", i);

        m_ahb_master_env[i] = ahb_env_t::type_id::create(ahb_env_id, this);

        `uvm_config_db_set(ahb_cfg_t, this, ahb_env_id, "m_cfg", m_cfg.ahb_master_env_cfg[i])

    end

    for(uint i = 0; i < XBAR_COMPLETER_CNT; ++i) begin
        string ahb_env_id = $sformatf("m_ahb_slave_env_%0d", i);

        m_ahb_slave_env[i] = ahb_env_t::type_id::create(ahb_env_id, this);

        `uvm_config_db_set(ahb_cfg_t, this, ahb_env_id, "m_cfg", m_cfg.ahb_slave_env_cfg[i])

    end

    m_vsequencer = vsequencer_t::type_id::create("m_vsequencer", this);

    `uvm_config_db_set(cfg_t, this, "m_vsequencer", "m_cfg", m_cfg)

endfunction : build_phase

function void xbar_ahb_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    for(uint i = 0; i < XBAR_REQUESTER_CNT; ++i) begin
        m_vsequencer.m_ahb_master_seqr[i] = m_ahb_master_env[i].m_master_agent.m_sequencer;
        if(m_ahb_master_env[i].m_master_agent.m_sequencer == null) begin
            `uvm_warning(`gtn, $sformatf("master_seqr_%0d is null", i))
        end
    end

    for(uint i = 0; i < XBAR_COMPLETER_CNT; ++i) begin
        m_vsequencer.m_ahb_slave_seqr[i] = m_ahb_slave_env[i].m_slave_agent.m_sequencer;
        if(m_ahb_slave_env[i].m_slave_agent.m_sequencer == null) begin
            `uvm_warning(`gtn, $sformatf("slave_seqr_%0d is null", i))
        end
    end

endfunction : connect_phase

`endif // XBAR_AHB_ENV_SV
