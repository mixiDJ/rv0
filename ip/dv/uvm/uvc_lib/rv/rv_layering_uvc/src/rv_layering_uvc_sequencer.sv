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
// Name: rv_layering_uvc_sequencer.sv
// Auth: Nikola Lukić
// Date: 16.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_LAYERING_UVC_SEQUENCER_SV
`define RV_LAYERING_UVC_SEQUENCER_SV

typedef rv_layering_uvc_seq_base;

class rv_layering_uvc_sequencer #(`RV_LAYERING_UVC_PARAM_LST) extends uvm_sequencer#(rv_uvc_item#(`RV_UVC_PARAMS));

    typedef rv_layering_uvc_agent_cfg                               cfg_t;
    typedef rv_layering_uvc_seq_base#(`RV_LAYERING_UVC_PARAMS)      seq_base_t;

    /* SEQUENCER CONFIG OBJECT */
    cfg_t m_cfg;

    /* SEQUENCER LAYERING HANDLE */
    IF_SEQR_T m_if_seqr;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(rv_layering_uvc_sequencer#(`RV_LAYERING_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

endclass : rv_layering_uvc_sequencer

function void rv_layering_uvc_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get sequencer config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

endfunction : build_phase

task rv_layering_uvc_sequencer::run_phase(uvm_phase phase);
    seq_base_t layering_seq;

    super.run_phase(phase);

    // create layering sequence and start it on interface UVC sequencer
    layering_seq = seq_base_t::type_id::create("layering_seq", this);
    layering_seq.rv_seqr = this;
    layering_seq.start(m_if_seqr);

endtask : run_phase

`endif // RV_LAYERING_UVC_SEQUENCER_SV
