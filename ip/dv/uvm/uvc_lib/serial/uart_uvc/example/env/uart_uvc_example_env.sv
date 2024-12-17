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
// Name: uart_uvc_example_env.sv
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

`ifndef UART_UVC_EXAMPLE_ENV_SV
`define UART_UVC_EXAMPLE_ENV_SV

class uart_uvc_example_env extends uvm_env;

    typedef uart_uvc_env                    uart_env_t;
    typedef uart_uvc_cfg                    uart_cfg_t;
    typedef uart_uvc_example_vsequencer     vsequencer_t;
    typedef uart_uvc_example_cfg            cfg_t;

    /* ENVIRONMENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* ENVIRONMENT COMPONENTS */
    uart_env_t      m_uart_env[2];

    vsequencer_t    m_vsequencer;

    /* REGISTRATION MACRO */
    `uvm_component_utils(uart_uvc_example_env)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : uart_uvc_example_env

function void uart_uvc_example_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    for(int i = 0; i < 2; ++i) begin
        string env_id = $sformatf("m_uart_env_%0d", i);
        m_uart_env[i] = uart_env_t::type_id::create(env_id, this);
        `uvm_config_db_set(uart_cfg_t, this, env_id, "m_cfg", m_cfg.uart_env_cfg[i])
    end

    m_vsequencer = vsequencer_t::type_id::create("m_vsequencer", this);
    `uvm_config_db_set(cfg_t, this, "m_vsequencer", "m_cfg", m_cfg)

endfunction : build_phase

function void uart_uvc_example_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    for(uint i = 0; i < 2; ++i) begin
        if(m_cfg.uart_env_cfg[i].agent_cfg.agent_type == UVM_ACTIVE) begin
            m_vsequencer.m_uart_seqr[i] = m_uart_env[i].m_agent.m_sequencer;
        end
    end

endfunction : connect_phase

`endif // UART_UVC_EXAMPLE_ENV_SV
