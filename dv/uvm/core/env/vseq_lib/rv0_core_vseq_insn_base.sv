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
// Source location: svn://lukic.sytes.net/rv0
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: rv0_core_vseq_insn_base.sv
// Auth: Nikola Lukić
// Date: 31.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV0_CORE_VSEQ_INSN_BASE_SV
`define RV0_CORE_VSEQ_INSN_BASE_SV

class rv0_core_vseq_insn_base #(`RV0_CORE_ENV_PARAM_LST) extends uvm_sequence;

    /* VIRTUAL SEQUENCE FIELDS */
    rand int unsigned insn_cnt;

    /* VIRTUAL SEQUENCE CONSTRAINTS */
    constraint c_insn_cnt { soft insn_cnt inside {[50:100]}; }

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(rv0_core_vseq_insn_base#(`RV0_CORE_ENV_PARAMS))
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(rv0_core_vsequencer#(`RV0_CORE_ENV_PARAMS))

    /* VIRTUAL SEQUENCE BODY TASK */
    extern virtual task body();

endclass : rv0_core_vseq_insn_base

task rv0_core_vseq_insn_base::body();
    rv_uvc_seq_insn_base#(`RV_UVC_PARAMS)   seq_insn_base;
    ahb_uvc_seq_base#(`AHB_UVC_PARAMS)      seq_ahb_base;

    repeat(insn_cnt) begin

        `uvm_do_on(seq_insn_base, p_sequencer.m_rv_seqr)

        if(seq_insn_base.opcode == LOAD) begin
            `uvm_do_on(seq_ahb_base, p_sequencer.m_dmem_seqr)
        end

        if(seq_insn_base.opcode == STORE) begin
            `uvm_do_on_with(
                seq_ahb_base,
                p_sequencer.m_dmem_seqr,
                { hrdata == 'h0; }
            )
        end

    end

endtask : body

`endif // RV0_CORE_VSEQ_INSN_BASE_SV
