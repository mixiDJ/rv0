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
// Source location:
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware smoked on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: test_rv0_core_insn_base.sv
// Auth: Nikola Lukić
// Date: 24.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef TEST_RV0_CORE_INSN_BASE_SV
`define TEST_RV0_CORE_INSN_BASE_SV

class test_rv0_core_insn_base #(`RV0_CORE_ENV_PARAM_LST) extends test_rv0_core_base#(`RV0_CORE_ENV_PARAMS);

    typedef rv0_core_vseq_insn_base#(`RV0_CORE_ENV_PARAMS)  vseq_insn_base_t;

    /* EVENTS */
    uvm_event m_rst_deassert_event;

    /* REGISTRATION MACRO */
    `uvm_component_registry(test_rv0_core_insn_base#(`RV0_CORE_ENV_PARAMS), "test_rv0_core_insn_base")
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */
    extern virtual function void set_test_build_cfg();

    /* LOCAL METHODS */
    extern local task reg_init();

endclass : test_rv0_core_insn_base

function void test_rv0_core_insn_base::build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_rst_deassert_event = uvm_event_pool::get_global("m_rst_deassert_event_0");
endfunction : build_phase

task test_rv0_core_insn_base::run_phase(uvm_phase phase);
    vseq_insn_base_t vseq_insn_base;

    super.run_phase(phase);

    uvm_test_done.raise_objection(this, `gtn);
    `uvm_info(`gtn, "TEST STARTED", UVM_LOW)

    reg_init();

    vseq_insn_base = vseq_insn_base_t::type_id::create("vseq_insn_base", this);
    assert(vseq_insn_base.randomize());
    vseq_insn_base.start(m_env.m_vsequencer);
    #100us;

    phase.drop_objection(this);
    `uvm_info(`gtn, "TEST_FINISHED", UVM_LOW)

endtask : run_phase

function void test_rv0_core_insn_base::set_test_build_cfg();
    super.set_test_build_cfg();

    m_cfg.reg_init = REG_RAND;
    m_cfg.reg_path = "rv0_core_tb_top.DUT.u_idu.u_rfi.rf_i_genblk[%0d].reg_q";

endfunction : set_test_build_cfg

task test_rv0_core_insn_base::reg_init();

    if(m_cfg.clk_env_cfg.agent_cfg[0].rst_init) begin
        m_rst_deassert_event.wait_trigger();
        `uvm_info(`gtn, "REG INIT", UVM_LOW)
    end

    for(int i = 1; i < (RVI ? 32 : 16); ++i) begin

        bit [XLEN-1:0] reg_val;
        reg_val = XLEN == 64 ? {$urandom(), $urandom()} : $urandom();

        case(m_cfg.reg_init)

            REG_ZERO: begin
                m_env.m_scoreboard.set_ireg(i, 'h0);
            end

            REG_RAND: begin
                void'(uvm_hdl_deposit($sformatf(m_cfg.reg_path, i), reg_val));
                m_env.m_scoreboard.set_ireg(i, reg_val);
            end

            REG_UNKN: begin
                void'(uvm_hdl_deposit($sformatf(m_cfg.reg_path, i), 'bX));
                m_env.m_scoreboard.set_ireg(i, 'bX);
            end

        endcase

    end

endtask : reg_init

`endif // TEST_RV0_CORE_INSN_BASE_SV
