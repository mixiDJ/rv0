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
// Name: rv_iret_uvc_subscriber.sv
// Auth: Nikola Lukić
// Date: 03.12.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_IRET_UVC_SUBSCRIBER_SV
`define RV_IRET_UVC_SUBSCRIBER_SV

class rv_iret_uvc_subscriber #(`RV_IRET_UVC_PARAM_LST) extends uvm_subscriber#(rv_uvc_item#(`RV_UVC_PARAMS));

    typedef rv_uvc_item#(`RV_UVC_PARAMS)        item_t;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(rv_iret_uvc_subscriber#(`RV_IRET_UVC_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);

    /* SUBSCRIBER WRITE METHOD */
    extern virtual function void write(item_t t);

endclass : rv_iret_uvc_subscriber

function void rv_iret_uvc_subscriber::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase

function void rv_iret_uvc_subscriber::write(item_t t);

endfunction : write

`endif // RV_IRET_UVC_SUBSCRIBER_SV
