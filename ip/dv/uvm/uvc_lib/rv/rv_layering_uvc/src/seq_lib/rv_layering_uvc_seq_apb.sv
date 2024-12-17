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
// Name: rv_layering_uvc_seq_apb.sv
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

`ifndef RV_LAYERING_UVC_SEQ_APB_SV
`define RV_LAYERING_UVC_SEQ_APB_SV

`ifdef APB_UVC_PKG_SV

class rv_layering_uvc_seq_apb #(`RV_LAYERING_UVC_PARAM_LST)
extends rv_layering_uvc_seq_base#(`RV_LAYERING_UVC_PARAMS);

    /* REGISTRATION MACRO */
    `uvm_object_param_utils(rv_layering_uvc_seq_apb#(`RV_LAYERING_UVC_PARAMS))
    `uvm_object_new

    /* LAYERING TRANSLATE METHOD */
    extern virtual function void translate();

endclass : rv_layering_uvc_seq_apb

function void rv_layering_uvc_seq_apb::translate();
    if_item.prdata = rv_item.insn;
endfunction : translate

`endif // APB_UVC_PKG_SV

`endif // RV_LAYERING_UVC_SEQ_APB_SV
