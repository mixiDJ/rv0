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
// Name: rv_layering_uvc_seq_base.sv
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

/***************************************************************************************************
 *  ! IMPORTANT !
 *
 *  Create a new layering sequence based on the instruction memory interface
 *  and extend it from rv_layering_uvc_seq_base.
 *
 *  Type override for layering sequence must be set before UVM run phase.
 *
 *  translate() function must be overridden in the derived sequence.
 *
 *  The implementation of translate() function needs to contain translation
 *  from RISC-V UVC item data to targeted interface UVC item data.
 *
 *  See rv_layering_uvc_seq_apb.sv for example implementation.
 *
 **************************************************************************************************/

`ifndef RV_LAYERING_UVC_SEQ_BASE_SV
`define RV_LAYERING_UVC_SEQ_BASE_SV

class rv_layering_uvc_seq_base #(`RV_LAYERING_UVC_PARAM_LST) extends uvm_sequence#(IF_ITEM_T);

    typedef rv_uvc_item#(`RV_UVC_PARAMS)                        rv_item_t;
    typedef rv_layering_uvc_sequencer#(`RV_LAYERING_UVC_PARAMS) rv_seqr_t;

    /* SEQUENCER HANDLES */
    rv_seqr_t       rv_seqr;

    /* SEQUENCE ITEMS */
    rv_item_t       rv_item;
    IF_ITEM_T       if_item;

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(rv_layering_uvc_seq_base#(`RV_LAYERING_UVC_PARAMS))
        `uvm_field_object(rv_item, UVM_DEFAULT)
        `uvm_field_object(if_item, UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(IF_SEQR_T)

    /* SEQUENCE BODY TASK */
    extern virtual task body();

    /* LAYERING TRANSLATE METHOD */
    extern virtual function void translate();

endclass : rv_layering_uvc_seq_base

task rv_layering_uvc_seq_base::body();

    forever begin

        if_item = IF_ITEM_T::type_id::create("if_item");

        rv_seqr.get_next_item(rv_item);

        start_item(if_item);
        translate();
        finish_item(if_item);

        rv_seqr.item_done();

    end

endtask : body

function void rv_layering_uvc_seq_base::translate();
    `uvm_fatal(`gtn, "LAYERING TRANSLATE FUNCTION DOES NOT HAVE A VALID OVERRIDE")
endfunction : translate

`endif // RV_LAYERING_UVC_SEQ_BASE_SV
