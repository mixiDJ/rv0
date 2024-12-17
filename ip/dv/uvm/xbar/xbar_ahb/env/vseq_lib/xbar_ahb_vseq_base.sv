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
// Name: xbar_ahb_vseq_base.sv
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

`ifndef XBAR_AHB_VSEQ_BASE_SV
`define XBAR_AHB_VSEQ_BASE_SV

class xbar_ahb_vseq_base #(`XBAR_AHB_PARAMS) extends uvm_sequence;

    typedef ahb_uvc_seq_base#(`AHB_UVC_PARAM_LST)   ahb_seq_base_t;

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(xbar_ahb_vseq_base#(`XBAR_AHB_PARAM_LST))
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(xbar_ahb_vsequencer#(`XBAR_AHB_PARAM_LST))

endclass : xbar_ahb_vseq_base

`endif // XBAR_AHB_VSEQ_BASE_SV
