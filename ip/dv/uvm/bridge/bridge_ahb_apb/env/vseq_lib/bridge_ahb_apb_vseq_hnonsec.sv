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
// Name: bridge_ahb_apb_vseq_hnonsec.sv
// Auth: Nikola Lukić
// Date: 18.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef BRIDGE_AHB_APB_VSEQ_HNONSEC_SV
`define BRIDGE_AHB_APB_VSEQ_HNONSEC_SV

class bridge_ahb_apb_vseq_hnonsec #(`BRIDGE_AHB_APB_PARAMS) extends bridge_ahb_apb_vseq_base#(`BRIDGE_AHB_APB_PARAM_LST);

    /* VIRTUAL SEQUENCE FIELDS */
    rand int unsigned seq_cnt;

    /* VIRTUAL SEQUENCE CONSTRAINTS */
    constraint c_seq_cnt { soft seq_cnt inside {[1:20]}; }

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(bridge_ahb_apb_vseq_hnonsec#(`BRIDGE_AHB_APB_PARAM_LST))
        `uvm_field_int(seq_cnt, UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(bridge_ahb_apb_vsequencer#(`BRIDGE_AHB_APB_PARAM_LST))

    /* VIRTUAL SEQUENCE BODY TASK */
    extern virtual task body();

endclass : bridge_ahb_apb_vseq_hnonsec

task bridge_ahb_apb_vseq_hnonsec::body();

    repeat(seq_cnt) begin

        `uvm_start_on_with(
            ahb_seq_base,
            p_sequencer.m_ahb_master_seqr,
            {
                hnonsec == 1'b1;
                hexcl   == 1'b0;
            }
        )

        `uvm_start_on_with(
            apb_seq_base,
            p_sequencer.m_apb_slave_seqr,
            {
                pslverr == 1'b0;
            }
        )

    end

endtask : body

`endif // BRIDGE_AHB_APB_VSEQ_HNONSEC_SV
