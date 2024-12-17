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
// Name: xbar_ahb_vseq_smoke.sv
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

`ifndef XBAR_AHB_VSEQ_SMOKE_SV
`define XBAR_AHB_VSEQ_SMOKE_SV

class xbar_ahb_vseq_smoke #(`XBAR_AHB_PARAMS) extends xbar_ahb_vseq_base#(`XBAR_AHB_PARAM_LST);

    /* VIRTUAL SEQUENCE FIELDS */
    rand int                    req_id;
    rand int                    cmp_id;
    rand bit [ADDR_WIDTH-1:0]   haddr;

    /* VIRTUAL SEQUENCE CONSTRAINTS */
    constraint c_req_id {
        req_id inside {[0:7]};
    }

    constraint c_cmp_id {
        //cmp_id inside {[0:XBAR_COMPLETER_CNT-1]};
        cmp_id inside {[0:3]};
    }

    constraint c_haddr  {
        solve cmp_id before haddr;
        (haddr & XBAR_ADDR_MASK[cmp_id]) == XBAR_ADDR_BASE[cmp_id];
    }

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(xbar_ahb_vseq_smoke#(`XBAR_AHB_PARAM_LST))
        `uvm_field_int(req_id, UVM_DEFAULT)
        `uvm_field_int(cmp_id, UVM_DEFAULT)
        `uvm_field_int(haddr,  UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(xbar_ahb_vsequencer#(`XBAR_AHB_PARAM_LST))

    /* VIRTUAL SEQUENCE BODY TASK */
    extern virtual task body();

endclass : xbar_ahb_vseq_smoke

task xbar_ahb_vseq_smoke::body();
    ahb_seq_base_t ahb_seq_base;

    this.randomize();

    `uvm_do_on_with(
        ahb_seq_base,
        p_sequencer.m_ahb_slave_seqr[cmp_id],
        { rsp_dly == 20; }
    )

    `uvm_do_on_with(
        ahb_seq_base,
        p_sequencer.m_ahb_master_seqr[req_id],
        { haddr == local::haddr; }
    )

    #1000ns;
    for(int i = 0; i < XBAR_COMPLETER_CNT; ++i) begin
        `uvm_do_on_with(
            ahb_seq_base,
            p_sequencer.m_ahb_slave_seqr[i],
            { rsp_dly == 20; }
        )
    end
    #100ns;

    for(int i = 0; i < XBAR_REQUESTER_CNT; ++i) begin
        this.randomize();
        `uvm_do_on_with(
            ahb_seq_base,
            p_sequencer.m_ahb_master_seqr[i],
            { haddr == local::haddr; }
        )
        #100ns;
    end

endtask : body

`endif // XBAR_AHB_VSEQ_SMOKE_SV
