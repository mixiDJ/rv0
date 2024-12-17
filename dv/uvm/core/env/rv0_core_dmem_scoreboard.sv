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
// Name: rv0_core_dmem_scoreboard.sv
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

`ifndef RV0_CORE_DMEM_SCOREBOARD_SV
`define RV0_CORE_DMEM_SCOREBOARD_SV

class rv0_core_dmem_scoreboard #(`RV0_CORE_ENV_PARAM_LST) extends uvm_scoreboard;

    typedef ahb_uvc_item#(`AHB_UVC_PARAMS)  ahb_item_t;
    typedef rv_uvc_item#(`RV_UVC_PARAMS)    rv_item_t;
    typedef rv0_core_cfg                    cfg_t;

    /* SCOREBOARD CONFIG OBJECT */
    cfg_t m_cfg;

    /* SCOREBOARD ANALYSIS FIFOS */
    uvm_tlm_analysis_fifo#(ahb_item_t)  m_dmem_afifo;
    uvm_tlm_analysis_fifo#(ahb_item_t)  m_ld_afifo;
    uvm_tlm_analysis_fifo#(ahb_item_t)  m_st_afifo;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(rv0_core_dmem_scoreboard#(`RV0_CORE_ENV_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void    build_phase(uvm_phase phase);
    extern virtual task             run_phase(uvm_phase phase);
    extern virtual function void    check_phase(uvm_phase phase);

endclass : rv0_core_dmem_scoreboard

function void rv0_core_dmem_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get scoreboard config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // create analysis fifos
    m_dmem_afifo = new("m_dmem_afifo", this);
    m_ld_afifo = new("m_ld_afifo", this);
    m_st_afifo = new("m_st_afifo", this);

endfunction : build_phase

task rv0_core_dmem_scoreboard::run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask : run_phase

function void rv0_core_dmem_scoreboard::check_phase(uvm_phase phase);
    super.check_phase(phase);
endfunction : check_phase

`endif // RV0_CORE_DMEM_SCOREBOARD_SV
