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
// Name: bridge_ahb_apb_vseq_base.sv
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

`ifndef BRIDGE_AHB_APB_VSEQ_BASE_SV
`define BRIDGE_AHB_APB_VSEQ_BASE_SV

class bridge_ahb_apb_vseq_base #(`BRIDGE_AHB_APB_PARAMS) extends uvm_sequence;

    typedef ahb_uvc_seq_base#(`AHB_UVC_PARAM_LST)   ahb_seq_base_t;
    typedef ahb_uvc_seq_burst#(`AHB_UVC_PARAM_LST)  ahb_seq_burst_t;
    typedef apb_uvc_seq_base#(`APB_UVC_PARAM_LST)   apb_seq_base_t;
    typedef clk_uvc_seq_rst                         clk_seq_rst_t;

    /* VIRTUAL SEQUENCES */
    ahb_seq_base_t      ahb_seq_base;
    ahb_seq_burst_t     ahb_seq_burst;
    apb_seq_base_t      apb_seq_base;
    clk_seq_rst_t       clk_seq_rst;

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(bridge_ahb_apb_vseq_base#(`BRIDGE_AHB_APB_PARAM_LST))
        `uvm_field_object(ahb_seq_base,  UVM_DEFAULT)
        `uvm_field_object(ahb_seq_burst, UVM_DEFAULT)
        `uvm_field_object(apb_seq_base,  UVM_DEFAULT)
        `uvm_field_object(clk_seq_rst,   UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(bridge_ahb_apb_vsequencer#(`BRIDGE_AHB_APB_PARAM_LST))

    /* VIRTUAL SEQUENCE BODY TASK */
    extern virtual task body();

endclass : bridge_ahb_apb_vseq_base

task bridge_ahb_apb_vseq_base::body();
endtask : body

`endif // BRIDGE_AHB_APB_VSEQ_BASE_SV
