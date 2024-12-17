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
// Name: rv0_core_tb_top.sv
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

`ifndef RV0_CORE_TB_TOP_SV
`define RV0_CORE_TB_TOP_SV

`include "rv0_core_defs.svh"

module rv0_core_tb_top;

    `include "uvm_macros.svh"
    `include "uvm_utils.svh"
    import uvm_pkg::*;

    `include "clk_uvc_pkg.sv"
    import clk_uvc_pkg::*;
    `include "ahb_uvc_pkg.sv"
    import ahb_uvc_pkg::*;
    `include "rv_uvc_pkg.sv"
    import rv_uvc_pkg::*;
    `include "rv_layering_uvc_pkg.sv"
    import rv_layering_uvc_pkg::*;
    `include "rv_layering_ahb_uvc_pkg.sv"
    import rv_layering_ahb_uvc_pkg::*;
    `include "rv_iret_uvc_pkg.sv"
    import rv_iret_uvc_pkg::*;

    `include "rv0_core_pkg.sv"
    import rv0_core_pkg::*;
    `include "rv0_core_test_pkg.sv"
    import rv0_core_test_pkg::*;

    /* ISA PARAMETERS */
    localparam int unsigned     XLEN            = 32;
    localparam int unsigned     FLEN            = 32;
    localparam bit              RVA             = 1'b0;
    localparam bit              RVC             = 1'b0;
    localparam bit              RVD             = 1'b0;
    localparam bit              RVE             = 1'b0;
    localparam bit              RVF             = 1'b0;
    localparam bit              RVI             = 1'b1;
    localparam bit              RVM             = 1'b0;
    localparam bit              RVS             = 1'b0;
    localparam bit              RVU             = 1'b0;
    localparam bit              ZIFENCEI        = 1'b0;
    localparam bit              ZICSR           = 1'b0;
    localparam bit              ZICNTR          = 1'b0;
    localparam bit              ZICOND          = 1'b0;

    /* CORE PARAMETERS */
    localparam bit [XLEN-1:0]   PC_RST_VAL      = 'h0010_0000;
    localparam bit [XLEN-1:0]   VENDOR_ID       = 'h0;
    localparam bit [XLEN-1:0]   ARCH_ID         = 'h0;
    localparam bit [XLEN-1:0]   IMP_ID          = 'h0;
    localparam bit [XLEN-1:0]   HART_ID         = 'h0;
    localparam bit [XLEN-1:0]   ROB_ENA         = 1'b0;
    localparam bit [XLEN-1:0]   MMU_ENA         = 1'b0;
    localparam bit [XLEN-1:0]   PMP_ENA         = 1'b0;

    /* AHB INTERFACE PARAMETERS */
    localparam int unsigned     ADDR_WIDTH      = 32;
    localparam int unsigned     DATA_WIDTH      = 32;
    localparam int unsigned     HBURST_WIDTH    = 4;
    localparam int unsigned     HPROT_WIDTH     = 4;
    localparam int unsigned     HMASTER_WIDTH   = 1;
    localparam int unsigned     USER_REQ_WIDTH  = 1;
    localparam int unsigned     USER_DATA_WIDTH = 1;
    localparam int unsigned     USER_RESP_WIDTH = 1;

    /* RISC-V LAYERING UVC PARAMETERS */
    localparam type             IF_ITEM_T       = ahb_uvc_item#(`AHB_UVC_PARAMS);
    localparam type             IF_SEQR_T       = ahb_uvc_sequencer#(`AHB_UVC_PARAMS);

    /* INTERFACES */
    clk_uvc_if u_clk_if ();

    ahb_uvc_if#(`AHB_UVC_PARAMS) u_imem_if (u_clk_if.clk, u_clk_if.rst_n);
    ahb_uvc_if#(`AHB_UVC_PARAMS) u_dmem_if (u_clk_if.clk, u_clk_if.rst_n);

    rv_iret_uvc_if#(`RV_IRET_UVC_PARAMS) u_iret_if (u_clk_if.clk, u_clk_if.rst_n);
    //assign u_iret_if.addr = DUT.exu_sbuf_if.addr;
    //assign u_iret_if.insn = DUT.exu_sbuf_if.insn;
    //assign u_iret_if.ires = DUT.exu_sbuf_if.idata1;
    //assign u_iret_if.iret = DUT.exu_sbuf_if.rdy && DUT.exu_sbuf_if.ack;

    typedef enum logic [1:0] {
        ARBT_EXU,
        ARBT_LSU
    } wbu_arbt_e;

    always_comb begin
        case(DUT.u_wbu.wbu_arbt)
            ARBT_EXU: begin
                u_iret_if.addr = DUT.exu_sbuf_if.addr;
                u_iret_if.insn = DUT.exu_sbuf_if.insn;
                u_iret_if.ires = DUT.exu_sbuf_if.idata1;
                u_iret_if.iret = DUT.exu_sbuf_if.rdy && DUT.exu_sbuf_if.ack;
            end
            ARBT_LSU: begin
                u_iret_if.addr = DUT.lsu_sbuf_if.addr;
                u_iret_if.insn = DUT.lsu_sbuf_if.insn;
                u_iret_if.ires = DUT.lsu_sbuf_if.idata1;
                u_iret_if.iret = DUT.lsu_sbuf_if.rdy && DUT.lsu_sbuf_if.ack;
            end
        endcase
    end

    /* DUT WRAPPER INTERFACES */
    ahb_if#(`AHB_UVC_PARAMS) imem_if ();
    assign u_imem_if.haddr   = imem_if.haddr;
    assign u_imem_if.htrans  = imem_if.htrans;
    assign u_imem_if.hsel    = imem_if.hsel;
    assign imem_if.hrdata    = u_imem_if.hrdata;
    assign imem_if.hreadyout = u_imem_if.hreadyout;

    ahb_if#(`AHB_UVC_PARAMS) dmem_if ();
    assign u_dmem_if.haddr   = dmem_if.haddr;
    assign u_dmem_if.hburst  = dmem_if.hburst;
    assign u_dmem_if.hmastlock = dmem_if.hmastlock;
    assign u_dmem_if.hprot     = dmem_if.hprot;
    assign u_dmem_if.hsize     = dmem_if.hsize;
    assign u_dmem_if.hnonsec   = dmem_if.hnonsec;
    assign u_dmem_if.hexcl     = dmem_if.hexcl;
    assign u_dmem_if.hmaster   = dmem_if.hmaster;
    assign u_dmem_if.htrans    = dmem_if.htrans;
    assign u_dmem_if.hwdata    = dmem_if.hwdata;
    assign u_dmem_if.hwstrb    = dmem_if.hwstrb;
    assign u_dmem_if.hwrite    = dmem_if.hwrite;
    assign u_dmem_if.hsel      = dmem_if.hsel;
    assign dmem_if.hrdata      = u_dmem_if.hrdata;
    assign dmem_if.hreadyout   = u_dmem_if.hreadyout;
    assign dmem_if.hresp       = u_dmem_if.hresp;
    assign dmem_if.hexokay     = u_dmem_if.hexokay;
    assign u_dmem_if.hauser    = u_dmem_if.hauser;
    assign u_dmem_if.hwuser    = u_dmem_if.hwuser;
    assign u_dmem_if.hruser    = u_dmem_if.hruser;
    assign u_dmem_if.hbuser    = u_dmem_if.hbuser;

    /* DUT */
    rv0_core #(`RV0_CORE_PARAMS)
    DUT (
        .clk_i  (u_clk_if.clk   ),
        .rst_ni (u_clk_if.rst_n ),
        .*
    );

    initial begin : tb_top_vif_cfg_blk

        `uvm_config_db_set(
            virtual clk_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_clk_env.m_agent_0",
            "m_vif",
            u_clk_if
        )

        `uvm_config_db_set(
            virtual ahb_uvc_if#(`AHB_UVC_PARAMS),
            uvm_root::get(),
            "uvm_test_top.m_env.m_imem_env.m_slave_agent",
            "m_vif",
            u_imem_if
        )

        `uvm_config_db_set(
            virtual ahb_uvc_if#(`AHB_UVC_PARAMS),
            uvm_root::get(),
            "uvm_test_top.m_env.m_dmem_env.m_slave_agent",
            "m_vif",
            u_dmem_if
        )

        `uvm_config_db_set(
            virtual rv_iret_uvc_if#(`RV_IRET_UVC_PARAMS),
            uvm_root::get(),
            "uvm_test_top.m_env.m_iret_env.m_agent",
            "m_vif",
            u_iret_if
        )

    end // tb_top_vif_cfg_blk

    typedef test_rv0_core_insn_base#(`RV0_CORE_ENV_PARAMS)          test_rv0_core_insn_base_t;

    typedef test_rv0_core_rv32i_insn_base#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_base_t;
    typedef test_rv0_core_rv32i_insn_lui#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_lui_t;
    typedef test_rv0_core_rv32i_insn_auipc#(`RV0_CORE_ENV_PARAMS)   test_rv0_core_rv32i_insn_auipc_t;
    typedef test_rv0_core_rv32i_insn_jal#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_jal_t;
    typedef test_rv0_core_rv32i_insn_jalr#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_jalr_t;
    typedef test_rv0_core_rv32i_insn_branch#(`RV0_CORE_ENV_PARAMS)  test_rv0_core_rv32i_insn_branch_t;
    typedef test_rv0_core_rv32i_insn_beq#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_beq_t;
    typedef test_rv0_core_rv32i_insn_bne#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_bne_t;
    typedef test_rv0_core_rv32i_insn_blt#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_blt_t;
    typedef test_rv0_core_rv32i_insn_bge#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_bge_t;
    typedef test_rv0_core_rv32i_insn_bltu#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_bltu_t;
    typedef test_rv0_core_rv32i_insn_bgeu#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_bgeu_t;
    typedef test_rv0_core_rv32i_insn_lb#(`RV0_CORE_ENV_PARAMS)      test_rv0_core_rv32i_insn_lb_t;
    typedef test_rv0_core_rv32i_insn_lh#(`RV0_CORE_ENV_PARAMS)      test_rv0_core_rv32i_insn_lh_t;
    typedef test_rv0_core_rv32i_insn_lw#(`RV0_CORE_ENV_PARAMS)      test_rv0_core_rv32i_insn_lw_t;
    typedef test_rv0_core_rv32i_insn_lbu#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_lbu_t;
    typedef test_rv0_core_rv32i_insn_lhu#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_lhu_t;
    typedef test_rv0_core_rv32i_insn_sb#(`RV0_CORE_ENV_PARAMS)      test_rv0_core_rv32i_insn_sb_t;
    typedef test_rv0_core_rv32i_insn_sh#(`RV0_CORE_ENV_PARAMS)      test_rv0_core_rv32i_insn_sh_t;
    typedef test_rv0_core_rv32i_insn_sw#(`RV0_CORE_ENV_PARAMS)      test_rv0_core_rv32i_insn_sw_t;
    typedef test_rv0_core_rv32i_insn_addi#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_addi_t;
    typedef test_rv0_core_rv32i_insn_slli#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_slli_t;
    typedef test_rv0_core_rv32i_insn_slti#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_slti_t;
    typedef test_rv0_core_rv32i_insn_sltiu#(`RV0_CORE_ENV_PARAMS)   test_rv0_core_rv32i_insn_sltiu_t;
    typedef test_rv0_core_rv32i_insn_xori#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_xori_t;
    typedef test_rv0_core_rv32i_insn_srli#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_srli_t;
    typedef test_rv0_core_rv32i_insn_srai#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_srai_t;
    typedef test_rv0_core_rv32i_insn_ori#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_ori_t;
    typedef test_rv0_core_rv32i_insn_andi#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_andi_t;
    typedef test_rv0_core_rv32i_insn_add#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_add_t;
    typedef test_rv0_core_rv32i_insn_sub#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_sub_t;
    typedef test_rv0_core_rv32i_insn_sll#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_sll_t;
    typedef test_rv0_core_rv32i_insn_slt#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_slt_t;
    typedef test_rv0_core_rv32i_insn_sltu#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv32i_insn_sltu_t;
    typedef test_rv0_core_rv32i_insn_xor#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_xor_t;
    typedef test_rv0_core_rv32i_insn_srl#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_srl_t;
    typedef test_rv0_core_rv32i_insn_sra#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_sra_t;
    typedef test_rv0_core_rv32i_insn_or#(`RV0_CORE_ENV_PARAMS)      test_rv0_core_rv32i_insn_or_t;
    typedef test_rv0_core_rv32i_insn_and#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv32i_insn_and_t;

    typedef test_rv0_core_rv64i_insn_base#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv64i_insn_base_t;
    typedef test_rv0_core_rv64i_insn_ld#(`RV0_CORE_ENV_PARAMS)      test_rv0_core_rv64i_insn_ld_t;
    typedef test_rv0_core_rv64i_insn_lwu#(`RV0_CORE_ENV_PARAMS)     test_rv0_core_rv64i_insn_lwu_t;
    typedef test_rv0_core_rv64i_insn_sd#(`RV0_CORE_ENV_PARAMS)      test_rv0_core_rv64i_insn_sd_t;
    typedef test_rv0_core_rv64i_insn_addiw#(`RV0_CORE_ENV_PARAMS)   test_rv0_core_rv64i_insn_addiw_t;
    typedef test_rv0_core_rv64i_insn_slliw#(`RV0_CORE_ENV_PARAMS)   test_rv0_core_rv64i_insn_slliw_t;
    typedef test_rv0_core_rv64i_insn_srliw#(`RV0_CORE_ENV_PARAMS)   test_rv0_core_rv64i_insn_srliw_t;
    typedef test_rv0_core_rv64i_insn_sraiw#(`RV0_CORE_ENV_PARAMS)   test_rv0_core_rv64i_insn_sraiw_t;
    typedef test_rv0_core_rv64i_insn_addw#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv64i_insn_addw_t;
    typedef test_rv0_core_rv64i_insn_subw#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv64i_insn_subw_t;
    typedef test_rv0_core_rv64i_insn_sllw#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv64i_insn_sllw_t;
    typedef test_rv0_core_rv64i_insn_srlw#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv64i_insn_srlw_t;
    typedef test_rv0_core_rv64i_insn_sraw#(`RV0_CORE_ENV_PARAMS)    test_rv0_core_rv64i_insn_sraw_t;

    initial begin : tb_top_run_test_blk
        run_test();
    end // tb_top_run_test_blk

endmodule : rv0_core_tb_top

`endif // RV0_CORE_TB_TOP_SV
