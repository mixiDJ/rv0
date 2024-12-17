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
// Name: rv0_core_test_pkg.sv
// Auth: Nikola Lukić
// Date: 13.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV0_CORE_TEST_PKG_SV
`define RV0_CORE_TEST_PKG_SV

package rv0_core_test_pkg;

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

`include "rv0_core_pkg.sv"
import rv0_core_pkg::*;

`include "test_rv0_core_base.sv"

`include "test_rv0_core_insn_base.sv"

`include "test_rv0_core_rv32i_insn_base.sv"
`include "test_rv0_core_rv32i_insn_lui.sv"
`include "test_rv0_core_rv32i_insn_auipc.sv"
`include "test_rv0_core_rv32i_insn_jal.sv"
`include "test_rv0_core_rv32i_insn_jalr.sv"
`include "test_rv0_core_rv32i_insn_branch.sv"
`include "test_rv0_core_rv32i_insn_beq.sv"
`include "test_rv0_core_rv32i_insn_bne.sv"
`include "test_rv0_core_rv32i_insn_blt.sv"
`include "test_rv0_core_rv32i_insn_bge.sv"
`include "test_rv0_core_rv32i_insn_bltu.sv"
`include "test_rv0_core_rv32i_insn_bgeu.sv"
`include "test_rv0_core_rv32i_insn_lb.sv"
`include "test_rv0_core_rv32i_insn_lh.sv"
`include "test_rv0_core_rv32i_insn_lw.sv"
`include "test_rv0_core_rv32i_insn_lbu.sv"
`include "test_rv0_core_rv32i_insn_lhu.sv"
`include "test_rv0_core_rv32i_insn_sb.sv"
`include "test_rv0_core_rv32i_insn_sh.sv"
`include "test_rv0_core_rv32i_insn_sw.sv"
`include "test_rv0_core_rv32i_insn_addi.sv"
`include "test_rv0_core_rv32i_insn_slli.sv"
`include "test_rv0_core_rv32i_insn_slti.sv"
`include "test_rv0_core_rv32i_insn_sltiu.sv"
`include "test_rv0_core_rv32i_insn_xori.sv"
`include "test_rv0_core_rv32i_insn_srli.sv"
`include "test_rv0_core_rv32i_insn_srai.sv"
`include "test_rv0_core_rv32i_insn_ori.sv"
`include "test_rv0_core_rv32i_insn_andi.sv"
`include "test_rv0_core_rv32i_insn_add.sv"
`include "test_rv0_core_rv32i_insn_sub.sv"
`include "test_rv0_core_rv32i_insn_sll.sv"
`include "test_rv0_core_rv32i_insn_slt.sv"
`include "test_rv0_core_rv32i_insn_sltu.sv"
`include "test_rv0_core_rv32i_insn_xor.sv"
`include "test_rv0_core_rv32i_insn_srl.sv"
`include "test_rv0_core_rv32i_insn_sra.sv"
`include "test_rv0_core_rv32i_insn_or.sv"
`include "test_rv0_core_rv32i_insn_and.sv"

`include "test_rv0_core_rv64i_insn_base.sv"
`include "test_rv0_core_rv64i_insn_lwu.sv"
`include "test_rv0_core_rv64i_insn_ld.sv"
`include "test_rv0_core_rv64i_insn_sd.sv"
`include "test_rv0_core_rv64i_insn_addiw.sv"
`include "test_rv0_core_rv64i_insn_slliw.sv"
`include "test_rv0_core_rv64i_insn_srliw.sv"
`include "test_rv0_core_rv64i_insn_sraiw.sv"
`include "test_rv0_core_rv64i_insn_addw.sv"
`include "test_rv0_core_rv64i_insn_subw.sv"
`include "test_rv0_core_rv64i_insn_sllw.sv"
`include "test_rv0_core_rv64i_insn_srlw.sv"
`include "test_rv0_core_rv64i_insn_sraw.sv"

//`include "test_rv0_core_rv32m_insn_base.sv"
//`include "test_rv0_core_rv32m_insn_mul.sv"
//`include "test_rv0_core_rv32m_insn_mulh.sv"
//`include "test_rv0_core_rv32m_insn_mulhsu.sv"
//`include "test_rv0_core_rv32m_insn_div.sv"
//`include "test_rv0_core_rv32m_insn_divu.sv"
//`include "test_rv0_core_rv32m_insn_rem.sv"
//`include "test_rv0_core_rv32m_insn_remu.sv"

//`include "test_rv0_core_rv64m_insn_base.sv"
//`include "test_rv0_core_rv64m_insn_mulw.sv"
//`include "test_rv0_core_rv64m_insn_divw.sv"
//`include "test_rv0_core_rv64m_insn_divuw.sv"
//`include "test_rv0_core_rv64m_insn_remw.sv"
//`include "test_rv0_core_rv64m_insn_remuw.sv"

//`include "test_rv0_core_rv32a_insn_base.sv"
//`include "test_rv0_core_rv32a_insn_lr.sv"
//`include "test_rv0_core_rv32a_insn_sc.sv"
//`include "test_rv0_core_rv32a_insn_amoswap.sv"
//`include "test_rv0_core_rv32a_insn_amoadd.sv"
//`include "test_rv0_core_rv32a_insn_amoxor.sv"
//`include "test_rv0_core_rv32a_insn_amoand.sv"
//`include "test_rv0_core_rv32a_insn_amoor.sv"
//`include "test_rv0_core_rv32a_insn_amomin.sv"
//`include "test_rv0_core_rv32a_insn_amomax.sv"
//`include "test_rv0_core_rv32a_insn_amominu.sv"
//`include "test_rv0_core_rv32a_insn_amomaxu.sv"

//`include "test_rv0_core_rv64a_insn_base.sv"
//`include "test_rv0_core_rv64a_insn_lr.sv"
//`include "test_rv0_core_rv64a_insn_sc.sv"
//`include "test_rv0_core_rv64a_insn_amoswap.sv"
//`include "test_rv0_core_rv64a_insn_amoadd.sv"
//`include "test_rv0_core_rv64a_insn_amoxor.sv"
//`include "test_rv0_core_rv64a_insn_amoand.sv"
//`include "test_rv0_core_rv64a_insn_amoor.sv"
//`include "test_rv0_core_rv64a_insn_amomin.sv"
//`include "test_rv0_core_rv64a_insn_amomax.sv"
//`include "test_rv0_core_rv64a_insn_amominu.sv"
//`include "test_rv0_core_rv64a_insn_amomaxu.sv"

endpackage : rv0_core_test_pkg

`endif // RV0_CORE_TEST_PKG_SV
