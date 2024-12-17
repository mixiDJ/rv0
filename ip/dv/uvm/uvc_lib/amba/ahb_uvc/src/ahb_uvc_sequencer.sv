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
// Name: ahb_uvc_sequencer.sv
// Auth: Nikola Lukić
// Date: 28.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef AHB_UVC_SEQUENCER_SV
`define AHB_UVC_SEQUENCER_SV

class ahb_uvc_sequencer #(`AHB_UVC_PARAM_LST) extends uvm_sequencer#(ahb_uvc_item#(`AHB_UVC_PARAMS));

    typedef ahb_uvc_agent_cfg cfg_t;

    /* SEQUENCER CONFIG OBJECT */
    cfg_t m_cfg;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(ahb_uvc_sequencer#(`AHB_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);

endclass : ahb_uvc_sequencer

function void ahb_uvc_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get sequencer config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

endfunction : build_phase

`endif // AHB_UVC_SEQUENCER_SV
