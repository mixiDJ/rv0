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
// Name: rv0_core_vsequencer.sv
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

`ifndef RV0_CORE_VSEQUENCER_SV
`define RV0_CORE_VSEQUENCER_SV

class rv0_core_vsequencer #(`RV0_CORE_ENV_PARAM_LST) extends uvm_sequencer;

    typedef clk_uvc_sequencer                                       clk_seqr_t;
    typedef ahb_uvc_sequencer#(`AHB_UVC_PARAMS)                     ahb_seqr_t;
    typedef rv_layering_uvc_sequencer#(`RV_LAYERING_UVC_PARAMS)     rv_seqr_t;
    typedef rv0_core_cfg                                            cfg_t;

    /* VIRTUAL SEQUENCER CONFIG */
    cfg_t m_cfg;

    /* VIRTUAL SEQUENCER HANDLES */
    clk_seqr_t      m_clk_seqr;
    ahb_seqr_t      m_imem_seqr;
    ahb_seqr_t      m_dmem_seqr;
    rv_seqr_t       m_rv_seqr;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(rv0_core_vsequencer#(`RV0_CORE_ENV_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);

endclass : rv0_core_vsequencer

function void rv0_core_vsequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get virtual sequencer config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

endfunction : build_phase

`endif // RV0_CORE_VSEQUENCER_SV
