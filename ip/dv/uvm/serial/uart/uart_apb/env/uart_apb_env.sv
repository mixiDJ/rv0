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
// Name: uart_apb_env.sv
// Auth: Nikola Lukić
// Date: 22.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_APB_ENV_SV
`define UART_APB_ENV_SV

class uart_apb_env #(`APB_UVC_PARAMS) extends uvm_env;

    typedef clk_uvc_env                         clk_env_t;
    typedef clk_uvc_cfg                         clk_cfg_t;

    typedef apb_uvc_env#(`APB_UVC_PARAM_LST)    apb_env_t;
    typedef apb_uvc_cfg                         apb_cfg_t;

    typedef uart_uvc_env                        uart_env_t;
    typedef uart_uvc_cfg                        uart_cfg_t;

    typedef uart_apb_cfg                        cfg_t;
    typedef uart_apb_scoreboard                 scoreboard_t;
    typedef uart_apb_vsequencer                 vsequencer_t;

    /* ENVIRONMENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* ENVIRONMENT COMPONENTS */
    clk_env_t       m_clk_env;
    apb_env_t       m_apb_env;
    uart_env_t      m_uart_env;

    scoreboard_t    m_scoreboard;
    vsequencer_t    m_vsequencer;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(uart_apb_env#(`APB_UVC_PARAM_LST))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : uart_apb_env

function void uart_apb_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get top environment config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // create clock environemnt component
    m_clk_env = clk_env_t::type_id::create("m_clk_env", this);

    // set clock environment config
    `uvm_config_db_set(clk_cfg_t, this, "m_clk_env", "m_cfg", m_cfg.clk_env_cfg)

    // create APB environment component
    m_apb_env = apb_env_t::type_id::create("m_apb_env", this);

    // set AHB environment config
    `uvm_config_db_set(apb_cfg_t, this, "m_apb_env", "m_cfg", m_cfg.apb_env_cfg)

    // create UART environment component
    m_uart_env = uart_env_t::type_id::create("m_uart_env", this);

    // set UART environment config
    `uvm_config_db_set(uart_cfg_t, this, "m_uart_env", "m_cfg", m_cfg.uart_env_cfg)

    // create scoreboard component
    m_scoreboard = scoreboard_t::type_id::create("m_scoreboard", this);

    // set scoreboard config
    `uvm_config_db_set(cfg_t, this, "m_scoreboard", "m_cfg", m_cfg)

    // create virtual sequencer component
    m_vsequencer = vsequencer_t::type_id::create("m_vsequencer", this);

    // set virtual sequencer config
    `uvm_config_db_set(cfg_t, this, "m_vsequencer", "m_cfg", m_cfg)

endfunction : build_phase

function void uart_apb_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(m_cfg.clk_env_cfg.agent_cfg[0].agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_clk_seqr = m_clk_env.m_agent[0].m_sequencer;
    end

    if(m_cfg.apb_env_cfg.has_master_agent == 1 && m_cfg.apb_env_cfg.master_agent_cfg.agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_apb_seqr = m_apb_env.m_master_agent.m_sequencer;
    end

    if(m_cfg.uart_env_cfg.agent_cfg.agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_uart_seqr = m_uart_env.m_agent.m_sequencer;
    end

endfunction : connect_phase

`endif // UART_APB_ENV_SV
