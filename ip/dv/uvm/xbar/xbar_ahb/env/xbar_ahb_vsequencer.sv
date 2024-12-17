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
// Name: xbar_ahb_vsequencer.sv
// Auth: Nikola Lukić
// Date: 28.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef XBAR_AHB_VSEQUENCER_SV
`define XBAR_AHB_VSEQUENCER_SV

class xbar_ahb_vsequencer #(`XBAR_AHB_PARAMS) extends uvm_sequencer;

    typedef ahb_uvc_sequencer#(`AHB_UVC_PARAM_LST)  ahb_seqr_t;
    typedef xbar_ahb_cfg#(`XBAR_AHB_PARAM_LST)      cfg_t;

    /* VIRTUAL SEQUENCER CONFIG OBJECT */
    cfg_t m_cfg;

    /* VIRTUAL SEQUENCER HANDLES */
    ahb_seqr_t  m_ahb_master_seqr [0:XBAR_REQUESTER_CNT-1];
    ahb_seqr_t  m_ahb_slave_seqr  [0:XBAR_COMPLETER_CNT-1];

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(xbar_ahb_vsequencer#(`XBAR_AHB_PARAM_LST))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);

endclass : xbar_ahb_vsequencer

function void xbar_ahb_vsequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

endfunction : build_phase

`endif // XBAR_AHB_VSEQUENCER_SV
