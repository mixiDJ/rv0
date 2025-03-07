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
// Name: rv_iret_uvc_agent.sv
// Auth: Nikola Lukić
// Date: 21.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_IRET_UVC_AGENT_SV
`define RV_IRET_UVC_AGENT_SV

class rv_iret_uvc_agent #(`RV_IRET_UVC_PARAM_LST) extends uvm_agent;

    typedef rv_uvc_item#(`RV_UVC_PARAMS)                    item_t;
    typedef virtual rv_iret_uvc_if#(`RV_IRET_UVC_PARAMS)    vif_t;
    typedef rv_iret_uvc_monitor#(`RV_IRET_UVC_PARAMS)       monitor_t;
    typedef rv_iret_uvc_subscriber#(`RV_IRET_UVC_PARAMS)    subscriber_t;
    typedef rv_iret_uvc_agent_cfg                           cfg_t;

    /* AGENT ANALYSIS PORTS */
    uvm_analysis_port#(item_t) m_aport;

    /* AGENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* AGENT VIRTUAL INTERFACE */
    vif_t m_vif;

    /* AGENT COMPONENTS */
    monitor_t       m_monitor;
    subscriber_t    m_subscriber;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(rv_iret_uvc_agent#(`RV_IRET_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : rv_iret_uvc_agent

function void rv_iret_uvc_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get agent config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // get agent virtual interface from DB
    `uvm_config_db_get(vif_t, this, "", "m_vif", m_vif)

    // print agent config
    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    // create analysis ports
    m_aport = new("m_aport", this);

    if(m_cfg.has_cov) begin
        // TODO
    end

    // create monitor component
    m_monitor = monitor_t::type_id::create("m_monitor", this);

    // set monitor config object
    `uvm_config_db_set(cfg_t, this, "m_monitor", "m_cfg", m_cfg)

    // set monitor virtual interface
    `uvm_config_db_set(vif_t, this, "m_monitor", "m_vif", m_vif)

endfunction : build_phase

function void rv_iret_uvc_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(m_cfg.has_cov) begin
        // TODO
    end

    // connect monitor analysis ports
    m_monitor.m_aport.connect(m_aport);

endfunction : connect_phase

`endif // RV_IRET_UVC_AGENT_SV
