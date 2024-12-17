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
// Name: rv_uvc_seq_insn_slti.sv
// Auth: Nikola Lukić
// Date: 11.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_UVC_SEQ_INSN_SLTI_SV
`define RV_UVC_SEQ_INSN_SLTI_SV

class rv_uvc_seq_insn_slti #(`RV_UVC_PARAM_LST) extends rv_uvc_seq_insn_op_imm#(`RV_UVC_PARAMS);

    /* SEQUENCE CONSTRAINTS */
    constraint c_funct3 { funct3 == SLT; }

    /* REGISTRATION MACRO */
    `uvm_object_param_utils(rv_uvc_seq_insn_slti#(`RV_UVC_PARAMS))
    `uvm_object_new
    //`uvm_declare_p_sequencer(rv_uvc_sequencer#(`RV_UVC_PARAMS))

endclass : rv_uvc_seq_insn_slti

`endif // RV_UVC_SEQ_INSN_SLTI_SV
