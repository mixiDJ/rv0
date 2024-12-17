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
// Name: clk_uvc_env.sv
// Auth: Nikola Lukić
// Date: 03.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef CLK_UVC_ENV_SV
`define CLK_UVC_ENV_SV

class clk_uvc_env extends uvm_env;

    typedef clk_uvc_agent       agent_t;
    typedef clk_uvc_item        item_t;
    typedef clk_uvc_cfg         cfg_t;
    typedef clk_uvc_agent_cfg   agent_cfg_t;

    /* ENVIRONMENT ANALYSIS PORTS */
    uvm_analysis_port#(item_t) m_aport [];

    /* ENVIRONMENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* ENVIRONMENT COMPONENTS */
    agent_t m_agent [];

    /* REGISTRATION MACRO */
    `uvm_component_utils(clk_uvc_env)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    /* METHODS */
    extern local function void init_agent_cfg();

endclass : clk_uvc_env

function void clk_uvc_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)
    init_agent_cfg();

    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    // create analysis ports
    m_aport = new[m_cfg.agent_cnt];
    for(int i = 0; i < m_cfg.agent_cnt; ++i) begin
        m_aport[i] = new($sformatf("m_aport_%0d", i), this);
    end

    // create agent components
    m_agent = new[m_cfg.agent_cnt];
    for(int i = 0; i < m_cfg.agent_cnt; ++i) begin

        string agent_id;
        agent_id = $sformatf("m_agent_%0d", i);

        // create agent component
        m_agent[i] = agent_t::type_id::create(agent_id, this);

        // set agent config
        `uvm_config_db_set(agent_cfg_t, this, agent_id, "m_cfg", m_cfg.agent_cfg[i]);

    end

endfunction : build_phase

function void clk_uvc_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect agent analysis ports
    for(int i = 0; i < m_cfg.agent_cnt; ++i) begin
        m_agent[i].m_aport.connect(m_aport[i]);
    end

endfunction : connect_phase

function void clk_uvc_env::init_agent_cfg();

    // create agent config objects based on agent_cfg field
    m_cfg.agent_cfg = new[m_cfg.agent_cnt];

    for(int i = 0; i < m_cfg.agent_cnt; ++i) begin

        string agent_id;
        agent_id = $sformatf("agent_%0d_cfg", i);
        m_cfg.agent_cfg[i] = agent_cfg_t::type_id::create(agent_id);
        m_cfg.agent_cfg[i].agent_id = i;

    end

endfunction : init_agent_cfg

`endif // CLK_UVC_ENV_SV
