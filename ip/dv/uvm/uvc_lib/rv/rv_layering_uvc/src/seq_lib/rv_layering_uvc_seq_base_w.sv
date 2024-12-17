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
// Name: rv_layering_uvc_seq_base_w.sv
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

`ifndef RV_LAYERING_UVC_SEQ_BASE_W_SV
`define RV_LAYERING_UVC_SEQ_BASE_W_SV

class rv_layering_uvc_seq_base_w #(`RV_LAYERING_UVC_PARAM_LST)
extends rv_layering_uvc_seq_base#(`RV_LAYERING_UVC_PARAMS);

    localparam int unsigned INSN_CNT = 4;

    /* SEQUENCE ITEM QUEUE */
    rv_item_t   rv_item_q [$];

    /* REGISTRATION MACRO */
    `uvm_object_param_utils(rv_layering_uvc_seq_base_w#(`RV_LAYERING_UVC_PARAMS))
    `uvm_object_new

    /* SEQUENCE BODY TASK */
    extern virtual task body();

endclass : rv_layering_uvc_seq_base_w

task rv_layering_uvc_seq_base_w::body();

    forever begin

        if_item = IF_ITEM_T::type_id::create("if_item");

        for(int i = 0; i < INSN_CNT; ++i) begin
            rv_seqr.get_next_item(rv_item);
            rv_item_q.push_back(rv_item);
        end

        start_item(if_item);
        translate();
        finish_item(if_item);

        for(int i = 0; i < INSN_CNT; ++i) begin
            rv_seqr.item_done();
        end

    end

endtask : rv_layering_uvc_seq_base_w

`endif // RV_LAYERING_UVC_SEQ_BASE_W_SV
