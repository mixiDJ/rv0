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
// Name: apb_uvc_env.sv
// Auth: Nikola Lukić
// Date: 16.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef APB_UVC_ENV_SV
`define APB_UVC_ENV_SV

class apb_uvc_env #(`APB_UVC_PARAM_LST) extends uvm_env;

    typedef apb_uvc_master_agent#(`APB_UVC_PARAMS)      master_agent_t;
    typedef apb_uvc_slave_agent#(`APB_UVC_PARAMS)       slave_agent_t;
    typedef apb_uvc_item#(`APB_UVC_PARAMS)              item_t;
    typedef apb_uvc_cfg                                 cfg_t;
    typedef apb_uvc_agent_cfg                           agent_cfg_t;

    /* ENVIRONMENT ANALYSIS PORTS */
    uvm_analysis_port#(item_t) m_master_req_aport;
    uvm_analysis_port#(item_t) m_master_rsp_aport;
    uvm_analysis_port#(item_t) m_slave_req_aport;
    uvm_analysis_port#(item_t) m_slave_rsp_aport;

    /* ENVIRONMENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* ENVIRONMENT COMPONENTS */
    master_agent_t  m_master_agent;
    slave_agent_t   m_slave_agent;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(apb_uvc_env#(`APB_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : apb_uvc_env

function void apb_uvc_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // print environment config
    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    m_master_req_aport = new("m_master_req_aport", this);
    m_master_rsp_aport = new("m_master_rsp_aport", this);
    m_slave_req_aport = new("m_slave_req_aport", this);
    m_slave_rsp_aport = new("m_slave_rsp_aport", this);

    if(m_cfg.has_master_agent) begin

        // create master agent component
        m_master_agent = master_agent_t::type_id::create("m_master_agent", this);

        // set master agent config
        `uvm_config_db_set(agent_cfg_t, this, "m_master_agent", "m_cfg", m_cfg.master_agent_cfg)

    end

    if(m_cfg.has_slave_agent) begin

        // create slave agent component
        m_slave_agent = slave_agent_t::type_id::create("m_slave_agent", this);

        // set slave agent config
        `uvm_config_db_set(agent_cfg_t, this, "m_slave_agent", "m_cfg", m_cfg.slave_agent_cfg)

    end

endfunction : build_phase

function void apb_uvc_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect master agent analysis ports
    if(m_cfg.has_master_agent) begin
        m_master_agent.m_req_aport.connect(m_master_req_aport);
        m_master_agent.m_rsp_aport.connect(m_master_rsp_aport);
    end

    // connect slave agent analysis ports
    if(m_cfg.has_slave_agent) begin
        m_slave_agent.m_req_aport.connect(m_slave_req_aport);
        m_slave_agent.m_rsp_aport.connect(m_slave_rsp_aport);
    end

endfunction : connect_phase

`endif // APB_UVC_ENV_SV
