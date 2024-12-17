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
// Name: rv_uvc_common.sv
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

`ifndef RV_UVC_COMMON_SV
`define RV_UVC_COMMON_SV

`define RV_UVC_PARAM_LST                                                        \
    parameter int unsigned  XLEN            = 32,                               \
    parameter int unsigned  FLEN            = 32,                               \
    parameter bit           RVA             = 1'b0,                             \
    parameter bit           RVC             = 1'b0,                             \
    parameter bit           RVD             = 1'b0,                             \
    parameter bit           RVE             = 1'b0,                             \
    parameter bit           RVF             = 1'b0,                             \
    parameter bit           RVI             = 1'b0,                             \
    parameter bit           RVM             = 1'b0,                             \
    parameter bit           RVS             = 1'b0,                             \
    parameter bit           RVU             = 1'b0,                             \
    parameter bit           ZIFENCEI        = 1'b0,                             \
    parameter bit           ZICSR           = 1'b0,                             \
    parameter bit           ZICNTR          = 1'b0,                             \
    parameter bit           ZICOND          = 1'b0

`define RV_UVC_PARAMS                                                           \
    .XLEN           (XLEN           ),                                          \
    .FLEN           (FLEN           ),                                          \
    .RVA            (RVA            ),                                          \
    .RVC            (RVC            ),                                          \
    .RVD            (RVD            ),                                          \
    .RVE            (RVE            ),                                          \
    .RVF            (RVF            ),                                          \
    .RVI            (RVI            ),                                          \
    .RVM            (RVM            ),                                          \
    .RVS            (RVS            ),                                          \
    .RVU            (RVU            ),                                          \
    .ZIFENCEI       (ZIFENCEI       ),                                          \
    .ZICSR          (ZICSR          ),                                          \
    .ZICNTR         (ZICNTR         ),                                          \
    .ZICOND         (ZICOND         )

typedef enum int unsigned {
    RV_INSN_TYPE_R,
    RV_INSN_TYPE_I,
    RV_INSN_TYPE_S,
    RV_INSN_TYPE_B,
    RV_INSN_TYPE_U,
    RV_INSN_TYPE_J
} rv_uvc_insn_type_e;

typedef enum bit [6:0] {
    LUI         = 7'b0110111,
    AUIPC       = 7'b0010111,
    JAL         = 7'b1101111,
    JALR        = 7'b1100111,
    BRANCH      = 7'b1100011,
    LOAD        = 7'b0000011,
    STORE       = 7'b0100011,
    OP_IMM      = 7'b0010011,
    OP          = 7'b0110011,
    OP_IMM_32   = 7'b0011011,
    OP_32       = 7'b0111011,
    LOAD_FP     = 7'b0000111,
    STORE_FP    = 7'b0100111,
    OP_FP       = 7'b1010011,
    MADD        = 7'b1000011,
    MSUB        = 7'b1000111,
    NMSUB       = 7'b1001011,
    NMADD       = 7'b1001111,
    AMO         = 7'b0101111,
    SYSTEM      = 7'b1110011,
    MISC_MEM    = 7'b0001111
} rv_uvc_opcode_e;

typedef enum bit [2:0] {
    BEQ  = 3'b000,
    BNE  = 3'b001,
    BLT  = 3'b100,
    BGE  = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111
} rv_uvc_branch_funct3_e;

typedef enum bit [2:0] {
    LB  = 3'b000,
    LH  = 3'b001,
    LW  = 3'b010,
    LD  = 3'b011,
    LBU = 3'b100,
    LHU = 3'b101,
    LWU = 3'b110
} rv_uvc_load_funct3_e;

typedef enum bit [2:0] {
    SB = 3'b000,
    SH = 3'b001,
    SW = 3'b010,
    SD = 3'b011
} rv_uvc_store_funct3_e;

typedef enum bit [2:0] {
    ADDI  = 3'b000,
    SLLI  = 3'b001,
    SLTI  = 3'b010,
    SLTIU = 3'b011,
    XORI  = 3'b100,
    SRLI  = 3'b101,
    ORI   = 3'b110,
    ANDI  = 3'b111
} rv_uvc_op_imm_funct3_e;

typedef enum bit [2:0] {
    ADD  = 3'b000,
    SLL  = 3'b001,
    SLT  = 3'b010,
    SLTU = 3'b011,
    XOR  = 3'b100,
    SRL  = 3'b101,
    OR   = 3'b110,
    AND  = 3'b111
} rv_uvc_op_funct3_e;

typedef enum bit [2:0] {
    ADDIW = 3'b000,
    SLLIW = 3'b001,
    SRLIW = 3'b101
} rv_uvc_op_imm_32_funct3_e;

typedef enum bit [2:0] {
    ADDW = 3'b000,
    SLLW = 3'b001,
    SRLW = 3'b101
} rv_uvc_op_32_funct3_e;

`endif // RV_UVC_COMMON_SV
