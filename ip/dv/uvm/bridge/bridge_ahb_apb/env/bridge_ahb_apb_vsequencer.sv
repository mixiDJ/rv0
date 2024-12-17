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
// Name: bridge_ahb_apb_vsequencer.sv
// Auth: Nikola Lukić
// Date: 01.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef BRIDGE_AHB_APB_VSEQUENCER_SV
`define BRIDGE_AHB_APB_VSEQUENCER_SV

class bridge_ahb_apb_vsequencer #(`BRIDGE_AHB_APB_PARAMS) extends uvm_sequencer;

    typedef bridge_ahb_apb_cfg                          cfg_t;
    typedef ahb_uvc_sequencer#(`AHB_UVC_PARAM_LST)      ahb_seqr_t;
    typedef apb_uvc_sequencer#(`APB_UVC_PARAM_LST)      apb_seqr_t;
    typedef clk_uvc_sequencer                           clk_seqr_t;

    /* VIRTUAL SEQUENCER CONFIG */
    cfg_t m_cfg;

    /* VIRTUAL SEQUENCER HANDLES */
    ahb_seqr_t  m_ahb_master_seqr;
    apb_seqr_t  m_apb_slave_seqr;
    clk_seqr_t  m_clk_seqr [];

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(bridge_ahb_apb_vsequencer#(`BRIDGE_AHB_APB_PARAM_LST))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);

endclass : bridge_ahb_apb_vsequencer

function void bridge_ahb_apb_vsequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get virtual sequencer config from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

endfunction : build_phase

`endif // BRIDGE_AHB_APB_VSEQUENCER_SV
