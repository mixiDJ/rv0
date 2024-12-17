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
// Name: rv0_core_env.sv
// Auth: Nikola Lukić
// Date: 31.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV0_CORE_ENV_SV
`define RV0_CORE_ENV_SV

class rv0_core_env #(`RV0_CORE_ENV_PARAM_LST) extends uvm_env;

    typedef clk_uvc_env                                     clk_env_t;
    typedef clk_uvc_cfg                                     clk_cfg_t;
    typedef clk_uvc_item                                    clk_item_t;
    typedef ahb_uvc_env#(`AHB_UVC_PARAMS)                   ahb_env_t;
    typedef ahb_uvc_cfg                                     ahb_cfg_t;
    typedef ahb_uvc_item#(`AHB_UVC_PARAMS)                  ahb_item_t;
    typedef rv_uvc_item#(`RV_UVC_PARAMS)                    rv_item_t;
    typedef rv_layering_uvc_env#(`RV_LAYERING_UVC_PARAMS)   rv_env_t;
    typedef rv_layering_uvc_cfg                             rv_cfg_t;
    typedef rv_iret_uvc_env#(`RV_IRET_UVC_PARAMS)           iret_env_t;
    typedef rv_iret_uvc_cfg                                 iret_cfg_t;

    typedef rv0_core_vsequencer#(`RV0_CORE_ENV_PARAMS)      vsequencer_t;
    typedef rv0_core_scoreboard#(`RV0_CORE_ENV_PARAMS)      scoreboard_t;
    typedef rv0_core_dmem_scoreboard#(`RV0_CORE_ENV_PARAMS) dmem_scoreboard_t;
    typedef rv0_core_cfg                                    cfg_t;

    /* ENVIRONMENT ANALYSIS PORTS */
    uvm_analysis_port#(clk_item_t)  m_clk_aport;
    uvm_analysis_port#(ahb_item_t)  m_imem_aport;
    uvm_analysis_port#(ahb_item_t)  m_dmem_aport;
    uvm_analysis_port#(rv_item_t)   m_iret_aport;

    /* ENVIRONMENT CONFIG OBJECT */
    cfg_t m_cfg;

    /* ENVIRONMENT COMPONENTS */
    clk_env_t           m_clk_env;
    ahb_env_t           m_imem_env;     // instruction memory interface environment
    ahb_env_t           m_dmem_env;     // data memory interface environment
    rv_env_t            m_rv_env;       // RISC-V layering environment
    iret_env_t          m_iret_env;     // RISC-V instruction retire environment

    vsequencer_t        m_vsequencer;
    scoreboard_t        m_scoreboard;
    dmem_scoreboard_t   m_dmem_scoreboard;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(rv0_core_env#(`RV0_CORE_ENV_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

endclass : rv0_core_env

function void rv0_core_env::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get core environment config object
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // print core environment config
    `uvm_info(`gtn, {"\n", m_cfg.sprint()}, UVM_HIGH)

    // create environment analysis ports
    m_clk_aport  = new("m_clk_aport", this);
    m_imem_aport = new("m_imem_aport", this);
    m_dmem_aport = new("m_dmem_aport", this);
    m_iret_aport = new("m_iret_aport", this);

    // create clock environment component
    m_clk_env = clk_env_t::type_id::create("m_clk_env", this);
    `uvm_config_db_set(clk_cfg_t, this, "m_clk_env", "m_cfg", m_cfg.clk_env_cfg)

    // create imem environment component
    m_imem_env = ahb_env_t::type_id::create("m_imem_env", this);
    `uvm_config_db_set(ahb_cfg_t, this, "m_imem_env", "m_cfg", m_cfg.imem_env_cfg)

    // create dmem environment component
    m_dmem_env = ahb_env_t::type_id::create("m_dmem_env", this);
    `uvm_config_db_set(ahb_cfg_t, this, "m_dmem_env", "m_cfg", m_cfg.dmem_env_cfg)

    // create RISC-V layering environment component
    m_rv_env = rv_env_t::type_id::create("m_rv_env", this);
    `uvm_config_db_set(rv_cfg_t, this, "m_rv_env", "m_cfg", m_cfg.rv_env_cfg)

    // create RISC-V instruction retire environment component
    m_iret_env = iret_env_t::type_id::create("m_iret_env", this);
    `uvm_config_db_set(iret_cfg_t, this, "m_iret_env", "m_cfg", m_cfg.iret_env_cfg)

    // create virtual sequencer component
    m_vsequencer = vsequencer_t::type_id::create("m_vsequencer", this);
    `uvm_config_db_set(cfg_t, this, "m_vsequencer", "m_cfg", m_cfg)

    // create scoreboard component
    m_scoreboard = scoreboard_t::type_id::create("m_scoreboard", this);
    `uvm_config_db_set(cfg_t, this, "m_scoreboard", "m_cfg", m_cfg)

    // create memory access scoreboard component
    m_dmem_scoreboard = dmem_scoreboard_t::type_id::create("m_dmem_scoreboard", this);
    `uvm_config_db_set(cfg_t, this, "m_dmem_scoreboard", "m_cfg", m_cfg)

endfunction : build_phase

function void rv0_core_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // set virtual sequencer handles
    if(m_cfg.clk_env_cfg.agent_cfg[0].agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_clk_seqr = m_clk_env.m_agent[0].m_sequencer;
    end

    if(m_cfg.imem_env_cfg.slave_agent_cfg.agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_imem_seqr = m_imem_env.m_slave_agent.m_sequencer;
    end

    if(m_cfg.dmem_env_cfg.slave_agent_cfg.agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_dmem_seqr = m_dmem_env.m_slave_agent.m_sequencer;
    end

    if(m_cfg.rv_env_cfg.agent_cfg.agent_type == UVM_ACTIVE) begin
        m_vsequencer.m_rv_seqr = m_rv_env.m_agent.m_sequencer;
        m_rv_env.m_agent.m_sequencer.m_if_seqr = m_vsequencer.m_imem_seqr;
    end

    // connect environment analysis ports
    m_clk_aport.connect(m_clk_env.m_aport[0]);
    m_imem_aport.connect(m_imem_env.m_slave_rsp_aport);
    m_dmem_aport.connect(m_dmem_env.m_slave_rsp_aport);
    m_iret_aport.connect(m_iret_env.m_aport);

    // connect scoreboard analysis ports
    // TODO: add clock analysis port connection
    m_imem_env.m_slave_rsp_aport.connect(m_scoreboard.m_imem_afifo.analysis_export);
    m_dmem_env.m_slave_rsp_aport.connect(m_scoreboard.m_dmem_afifo.analysis_export);
    m_iret_env.m_aport.connect(m_scoreboard.m_iret_afifo.analysis_export);

    // connect memory access scoreboard analysis ports
    // TODO: add clock analysis port connection
    m_dmem_env.m_slave_rsp_aport.connect(m_dmem_scoreboard.m_dmem_afifo.analysis_export);
    m_scoreboard.m_ld_aport.connect(m_dmem_scoreboard.m_ld_afifo.analysis_export);
    m_scoreboard.m_st_aport.connect(m_dmem_scoreboard.m_st_afifo.analysis_export);

endfunction : connect_phase

`endif // RV0_CORE_ENV_SV
