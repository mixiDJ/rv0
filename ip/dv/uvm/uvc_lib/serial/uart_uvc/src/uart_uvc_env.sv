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
// Source location:
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: uart_uvc_env.sv
// Auth: Nikola Lukić
// Date: 10.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_UVC_ENV_SV
`define UART_UVC_ENV_SV

class uart_uvc_env extends uvm_env;

    typedef uart_uvc_agent      agent_t;
    typedef uart_uvc_item       item_t;
    typedef uart_uvc_cfg        cfg_t;
    typedef uart_uvc_agent_cfg  agent_cfg_t;

    /* ENVIRONMENT ANALYSIS PORTS */
    uvm_analysis_port#(item_t)  m_rx_aport;
    uvm_analysis_port#(item_t)  m_tx_aport;

    /* ENVIRONMENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* ENVIRONMENT COMPONENTS */
    agent_t m_agent;

    /* REGISTRATION MACRO */
    `uvm_component_utils(uart_uvc_env)
    `uvm_component_new

    /* UVM PHASES */
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass : uart_uvc_env

function void uart_uvc_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // print envrionment config
    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    // create analysis ports
    m_rx_aport = new("m_rx_aport", this);
    m_tx_aport = new("m_tx_aport", this);

    // create agent component
    m_agent = agent_t::type_id::create("m_agent", this);

    // set agent config
    `uvm_config_db_set(agent_cfg_t, this, "m_agent", "m_cfg", m_cfg.agent_cfg)

endfunction : build_phase

function void uart_uvc_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect agent analysis ports
    m_agent.m_rx_aport.connect(m_rx_aport);
    m_agent.m_tx_aport.connect(m_tx_aport);

endfunction : connect_phase

`endif // UART_UVC_ENV_SV
