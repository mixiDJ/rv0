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
// Name: bridge_ahb_apb_vseq_stress.sv
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

`ifndef BRIDGE_AHB_APB_VSEQ_STRESS_SV
`define BRIDGE_AHB_APB_VSEQ_STRESS_SV

class bridge_ahb_apb_vseq_stress #(`BRIDGE_AHB_APB_PARAMS) extends bridge_ahb_apb_vseq_base#(`BRIDGE_AHB_APB_PARAM_LST);

    typedef bridge_ahb_apb_vseq_base#(`BRIDGE_AHB_APB_PARAM_LST)    vseq_base_t;
    typedef bridge_ahb_apb_vseq_smoke#(`BRIDGE_AHB_APB_PARAM_LST)   vseq_smoke_t;
    typedef bridge_ahb_apb_vseq_burst#(`BRIDGE_AHB_APB_PARAM_LST)   vseq_burst_t;
    typedef bridge_ahb_apb_vseq_rst#(`BRIDGE_AHB_APB_PARAM_LST)     vseq_rst_t;
    typedef bridge_ahb_apb_vseq_slverr#(`BRIDGE_AHB_APB_PARAM_LST)  vseq_slverr_t;
    typedef bridge_ahb_apb_vseq_hexcl#(`BRIDGE_AHB_APB_PARAM_LST)   vseq_hexcl_t;
    typedef bridge_ahb_apb_vseq_hnonsec#(`BRIDGE_AHB_APB_PARAM_LST) vseq_hnonsec_t;

    /* VIRTUAL SEQUENCE FIELDS */
    rand int unsigned seq_cnt;

    /* VIRTUAL SEQUENCE CONSTRAINTS */
    constraint c_seq_cnt { soft seq_cnt inside {[1:20]}; }

    /* SEQUENCE OVERRIDE MAP */
    uvm_object_wrapper m_vseq_proxy [6] = {
        vseq_smoke_t::get_type(),
        vseq_burst_t::get_type(),
        vseq_rst_t::get_type(),
        vseq_slverr_t::get_type(),
        vseq_hexcl_t::get_type(),
        vseq_hnonsec_t::get_type()
    };

    /* BASE SEQUENCE */
    vseq_base_t m_vseq_base;

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(bridge_ahb_apb_vseq_stress#(`BRIDGE_AHB_APB_PARAM_LST))
        `uvm_field_int(seq_cnt, UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(bridge_ahb_apb_vsequencer#(`BRIDGE_AHB_APB_PARAM_LST))

    /* VIRTUAL SEQUENCE BODY TASK */
    extern virtual task body();

endclass : bridge_ahb_apb_vseq_stress

task bridge_ahb_apb_vseq_stress::body();

    repeat(seq_cnt) begin

        int unsigned override_id = $urandom_range(0, 5);

        factory.set_type_override_by_type(
            vseq_base_t::get_type(),
            m_vseq_proxy[override_id]
        );

        `uvm_info(`gtn, "\nTYPE OVERRIDE", UVM_LOW)
        factory.print();

        m_vseq_base = vseq_base_t::type_id::create("m_vseq_stress");
        if(!m_vseq_base.randomize()) begin
            `uvm_fatal(`gtn, "Failed to randomize!")
        end
        m_vseq_base.start(p_sequencer);

    end

endtask : body

`endif // BRIDGE_AHB_APB_VSEQ_STRESS_SV
