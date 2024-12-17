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
// Name: rv_uvc_seq_lib.sv
// Auth: Nikola Lukić
// Date: 07.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_UVC_SEQ_LIB_SV
`define RV_UVC_SEQ_LIB_SV

`include "seq_lib/rv_uvc_seq_insn_base.sv"

/* LUI */
`include "seq_lib/rv_uvc_seq_insn_lui.sv"

/* AUIPC */
`include "seq_lib/rv_uvc_seq_insn_auipc.sv"

/* JAL */
`include "seq_lib/rv_uvc_seq_insn_jal.sv"

/* JALR */
`include "seq_lib/rv_uvc_seq_insn_jalr.sv"

/* BRANCH */
`include "seq_lib/rv_uvc_seq_insn_branch.sv"
`include "seq_lib/rv_uvc_seq_insn_beq.sv"
`include "seq_lib/rv_uvc_seq_insn_bne.sv"
`include "seq_lib/rv_uvc_seq_insn_blt.sv"
`include "seq_lib/rv_uvc_seq_insn_bge.sv"
`include "seq_lib/rv_uvc_seq_insn_bltu.sv"
`include "seq_lib/rv_uvc_seq_insn_bgeu.sv"

/* LOAD */
`include "seq_lib/rv_uvc_seq_insn_load.sv"
`include "seq_lib/rv_uvc_seq_insn_lb.sv"
`include "seq_lib/rv_uvc_seq_insn_lh.sv"
`include "seq_lib/rv_uvc_seq_insn_lw.sv"
`include "seq_lib/rv_uvc_seq_insn_ld.sv"
`include "seq_lib/rv_uvc_seq_insn_lbu.sv"
`include "seq_lib/rv_uvc_seq_insn_lhu.sv"
`include "seq_lib/rv_uvc_seq_insn_lwu.sv"

/* STORE */
`include "seq_lib/rv_uvc_seq_insn_store.sv"
`include "seq_lib/rv_uvc_seq_insn_sb.sv"
`include "seq_lib/rv_uvc_seq_insn_sh.sv"
`include "seq_lib/rv_uvc_seq_insn_sw.sv"
`include "seq_lib/rv_uvc_seq_insn_sd.sv"

/* OP-IMM */
`include "seq_lib/rv_uvc_seq_insn_op_imm.sv"
`include "seq_lib/rv_uvc_seq_insn_addi.sv"
`include "seq_lib/rv_uvc_seq_insn_slti.sv"
`include "seq_lib/rv_uvc_seq_insn_sltiu.sv"
`include "seq_lib/rv_uvc_seq_insn_xori.sv"
`include "seq_lib/rv_uvc_seq_insn_ori.sv"
`include "seq_lib/rv_uvc_seq_insn_andi.sv"
`include "seq_lib/rv_uvc_seq_insn_slli.sv"
`include "seq_lib/rv_uvc_seq_insn_srli.sv"
`include "seq_lib/rv_uvc_seq_insn_srai.sv"

/* OP */
`include "seq_lib/rv_uvc_seq_insn_op.sv"
`include "seq_lib/rv_uvc_seq_insn_add.sv"
`include "seq_lib/rv_uvc_seq_insn_sub.sv"
`include "seq_lib/rv_uvc_seq_insn_sll.sv"
`include "seq_lib/rv_uvc_seq_insn_slt.sv"
`include "seq_lib/rv_uvc_seq_insn_sltu.sv"
`include "seq_lib/rv_uvc_seq_insn_xor.sv"
`include "seq_lib/rv_uvc_seq_insn_srl.sv"
`include "seq_lib/rv_uvc_seq_insn_sra.sv"
`include "seq_lib/rv_uvc_seq_insn_or.sv"
`include "seq_lib/rv_uvc_seq_insn_and.sv"

/* OP-IMM-32 */
`include "seq_lib/rv_uvc_seq_insn_op_imm_32.sv"
`include "seq_lib/rv_uvc_seq_insn_addiw.sv"
`include "seq_lib/rv_uvc_seq_insn_slliw.sv"
`include "seq_lib/rv_uvc_seq_insn_srliw.sv"
`include "seq_lib/rv_uvc_seq_insn_sraiw.sv"

/* OP-32 */
`include "seq_lib/rv_uvc_seq_insn_op_32.sv"
`include "seq_lib/rv_uvc_seq_insn_addw.sv"
`include "seq_lib/rv_uvc_seq_insn_subw.sv"
`include "seq_lib/rv_uvc_seq_insn_sllw.sv"
`include "seq_lib/rv_uvc_seq_insn_srlw.sv"
`include "seq_lib/rv_uvc_seq_insn_sraw.sv"

/* LOAD-FP */
// `include "seq_lib/rv_uvc_seq_insn_load_fp.sv"

/* STORE-FP */
//`include "seq_lib/rv_uvc_seq_insn_store_fp.sv"

/* MADD */
//`include "seq_lib/rv_uvc_seq_insn_madd.sv"

/* MSUB */
//`include "seq_lib/rv_uvc_seq_insn_msub.sv"

/* NMSUB */
//`include "seq_lib/rv_uvc_seq_insn_nmsub.sv"

/* NMADD */
//`include "seq_lib/rv_uvc_seq_insn_nmadd.sv"

/* OP-FP */
//`include "seq_lib/rv_uvc_seq_insn_op_fp.sv"

/* AMO */
//`include "seq_lib/rv_uvc_seq_insn_amo.sv"

/* MISC-MEM */
//`include "seq_lib/rv_uvc_seq_insn_misc_mem.sv"

/* SYSTEM */
//`include "seq_lib/rv_uvc_seq_insn_system.sv"

`endif // RV_UVC_SEQ_LIB_SV
