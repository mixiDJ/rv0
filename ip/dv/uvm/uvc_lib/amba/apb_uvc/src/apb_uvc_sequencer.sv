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
// Name: apb_uvc_sequencer.sv
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

`ifndef APB_UVC_SEQUENCER_SV
`define APB_UVC_SEQUENCER_SV

class apb_uvc_sequencer#(`APB_UVC_PARAM_LST) extends uvm_sequencer#(apb_uvc_item#(`APB_UVC_PARAMS));

    typedef apb_uvc_agent_cfg cfg_t;

    /* SEQUENCER CONFIG OBJECT */
    cfg_t m_cfg;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(apb_uvc_sequencer#(`APB_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);

endclass : apb_uvc_sequencer

function void apb_uvc_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

endfunction : build_phase

`endif // APB_UVC_SEQUENCER_SV
