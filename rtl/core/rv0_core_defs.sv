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
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: rv0_core_defs.svh
// Auth: Nikola Lukić
// Date: 10.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV0_CORE_DEFS_SVH
`define RV0_CORE_DEFS_SVH

localparam int unsigned TLEN = 32;

package rv0_core_defs;

/*
 * RISC-V INSTRUCTION ENCODING DEFINITIONS
 */

typedef enum logic [6:0] {
    LUI       = 7'b0110111,
    AUIPC     = 7'b0010111,
    JAL       = 7'b1101111,
    JALR      = 7'b1100111,
    BRANCH    = 7'b1100011,
    LOAD      = 7'b0000011,
    STORE     = 7'b0100011,
    OP_IMM    = 7'b0010011,
    OP        = 7'b0110011,
    OP_IMM_32 = 7'b0011011,
    OP_32     = 7'b0111011,
    LOAD_FP   = 7'b0000111,
    STORE_FP  = 7'b0100111,
    MADD      = 7'b1000011,
    MSUB      = 7'b1000111,
    NMSUB     = 7'b1001011,
    NMADD     = 7'b1001111,
    OP_FP     = 7'b1010011,
    AMO       = 7'b0101111,
    MISC_MEM  = 7'b0001111,
    SYSTEM    = 7'b1110011
} rv_opcode_e;

typedef enum logic [2:0] {
    BEQ  = 3'b000,
    BNE  = 3'b001,
    BLT  = 3'b100,
    BGE  = 3'b101,
    BLTU = 3'b110,
    BGEU = 3'b111
} rv_branch_funct3_e;

typedef enum logic [2:0] {
    LB  = 3'b000,
    LH  = 3'b001,
    LW  = 3'b010,
    LD  = 3'b011,
    LBU = 3'b100,
    LHU = 3'b101,
    LWU = 3'b110
} rv_load_funct3_e;

typedef enum logic [2:0] {
    SB = 3'b000,
    SH = 3'b001,
    SW = 3'b010,
    SD = 3'b011
} rv_store_funct3_e;

typedef enum logic [2:0] {
    ADDI  = 3'b000,
    SLLI  = 3'b001,
    SLTI  = 3'b010,
    SLTIU = 3'b011,
    XORI  = 3'b100,
    SRLI  = 3'b101,
    ORI   = 3'b110,
    ANDI  = 3'b111
} rv_op_imm_funct3_e;

typedef enum logic [2:0] {
    ADD  = 3'b000,
    SLL  = 3'b001,
    SLT  = 3'b010,
    SLTU = 3'b011,
    XOR  = 3'b100,
    SRL  = 3'b101,
    OR   = 3'b110,
    AND  = 3'b111
} rv_op_funct3_e;

typedef enum logic [6:0] {
    MULDIV = 7'b0000001,
    CZERO  = 7'b0000111,
    FUNCT7_FADD_S  = 7'b0000000,  // FADD.S
    FUNCT7_FSUB_S  = 7'b0000100,  // FSUB.S
    FUNCT7_FMUL_S  = 7'b0001000,  // FMUL.S
    FUNCT7_FDIV_S  = 7'b0001100,  // FDIV.S
    FUNCT7_FSQRT_S = 7'b0101100,  // FSQRT.S
    FUNCT7_FSGNJ_S = 7'b0010000,  // FSGNJ.S
    FUNCT7_FMIN_FMAX_S  = 7'b0010100,  // FMIN.S
    FUNCT7_FCVT_W_S  = 7'b1100000, // FCVT.W.S
    FUNCT7_FCLASS_S  = 7'b1110000  // FCLASS.S
} rv_funct7_e;

typedef enum logic [2:0] { 
    RNE = 3'b000, // Round to nearest, ties to even
    RTZ = 3'b001, // Round to zero
    RDN = 3'b010, // Round down
    RUP = 3'b011, // Round up
    RMM = 3'b100, // Round to nearest, ties to max magnitude
    DYN = 3'b111 // Dynamic mode rounding, looks to fcsr for rounding mode
 } rv_float_rounding_mode;

 typedef enum logic [2:0] { 
    FMIN = 3'b000,
    FMAX = 3'b001
 } rv_float_min_max_field;

// FLOATING POINT NaN value per IEEE 754
parameter NaN = 32'h7fc00000;

/*
 * EXECUTION UNIT ENUM
 */

typedef enum logic [7:0] {
    EXU_I   = 8'b0000_0001, // integer execute unit
    EXU_B   = 8'b0000_0010, // branch execute unit
    EXU_IB  = 8'b0000_0011, // mixed integer/branch execute unit
    EXU_M   = 8'b0000_0100, // integer multiply/divide execute unit
    EXU_F   = 8'b0000_1000, // floating-point execute unit,
    LSU     = 8'b0001_0000, // load/store unit
    CSU     = 8'b0010_0000  // control/status unit
} exu_type_e;

/*
 * MODULE PARAMETER DEFINITIONS
 */

`define RV0_CORE_PARAM_LST                                                                          \
    parameter  int unsigned         XLEN                    = 32,                                   \
    parameter  int unsigned         FLEN                    = 32,                                   \
    parameter  bit                  RVA                     = 1'b0,                                 \
    parameter  bit                  RVC                     = 1'b0,                                 \
    parameter  bit                  RVD                     = 1'b0,                                 \
    parameter  bit                  RVE                     = 1'b0,                                 \
    parameter  bit                  RVF                     = 1'b0,                                 \
    parameter  bit                  RVI                     = 1'b1,                                 \
    parameter  bit                  RVM                     = 1'b0,                                 \
    parameter  bit                  RVS                     = 1'b0,                                 \
    parameter  bit                  RVU                     = 1'b0,                                 \
    parameter  bit                  ZIFENCEI                = 1'b0,                                 \
    parameter  bit                  ZICSR                   = 1'b0,                                 \
    parameter  bit                  ZICNTR                  = 1'b0,                                 \
    parameter  bit                  ZICOND                  = 1'b0,                                 \
    parameter  bit [XLEN-1:0]       PC_RST_VAL              = 'h0010_0000,                          \
    parameter  bit [XLEN-1:0]       VENDOR_ID               = 'h0,                                  \
    parameter  bit [XLEN-1:0]       ARCH_ID                 = 'h0,                                  \
    parameter  bit [XLEN-1:0]       IMP_ID                  = 'h0,                                  \
    parameter  bit [XLEN-1:0]       HART_ID                 = 'h0,                                  \
    parameter  bit                  ROB_ENA                 = 1'b0,                                 \
    parameter  bit                  MMU_ENA                 = 1'b0,                                 \
    parameter  bit                  PMP_ENA                 = 1'b0,                                 \
    parameter  int unsigned         EXU_CNT                 = 2,                                    \
    parameter  exu_type_e           EXU_TYPE [0:EXU_CNT-1]  = {EXU_IB, LSU},                        \
    parameter  int unsigned         ADDR_WIDTH              = XLEN,                                 \
    parameter  int unsigned         DATA_WIDTH              = XLEN,                                 \
    parameter  int unsigned         HBURST_WIDTH            = 0,                                    \
    parameter  int unsigned         HPROT_WIDTH             = 4,                                    \
    parameter  int unsigned         HMASTER_WIDTH           = 1,                                    \
    parameter  int unsigned         USER_REQ_WIDTH          = 0,                                    \
    parameter  int unsigned         USER_DATA_WIDTH         = 0,                                    \
    parameter  int unsigned         USER_RESP_WIDTH         = 0,                                    \
    localparam int unsigned         STRB_WIDTH              = DATA_WIDTH/8

`define RV0_CORE_PARAMS                                                                             \
    .XLEN               (XLEN               ),                                                      \
    .FLEN               (FLEN               ),                                                      \
    .RVA                (RVA                ),                                                      \
    .RVC                (RVC                ),                                                      \
    .RVD                (RVD                ),                                                      \
    .RVE                (RVE                ),                                                      \
    .RVF                (RVF                ),                                                      \
    .RVI                (RVI                ),                                                      \
    .RVM                (RVM                ),                                                      \
    .RVS                (RVS                ),                                                      \
    .RVU                (RVU                ),                                                      \
    .ZIFENCEI           (ZIFENCEI           ),                                                      \
    .ZICSR              (ZICSR              ),                                                      \
    .ZICNTR             (ZICNTR             ),                                                      \
    .ZICOND             (ZICOND             ),                                                      \
    .PC_RST_VAL         (PC_RST_VAL         ),                                                      \
    .VENDOR_ID          (VENDOR_ID          ),                                                      \
    .ARCH_ID            (ARCH_ID            ),                                                      \
    .IMP_ID             (IMP_ID             ),                                                      \
    .HART_ID            (HART_ID            ),                                                      \
    .ROB_ENA            (ROB_ENA            ),                                                      \
    .MMU_ENA            (MMU_ENA            ),                                                      \
    .PMP_ENA            (PMP_ENA            ),                                                      \
    .EXU_CNT            (EXU_CNT            ),                                                      \
    .EXU_TYPE           (EXU_TYPE           ),                                                      \
    .ADDR_WIDTH         (ADDR_WIDTH         ),                                                      \
    .DATA_WIDTH         (DATA_WIDTH         ),                                                      \
    .HBURST_WIDTH       (HBURST_WIDTH       ),                                                      \
    .HPROT_WIDTH        (HPROT_WIDTH        ),                                                      \
    .HMASTER_WIDTH      (HMASTER_WIDTH      ),                                                      \
    .USER_REQ_WIDTH     (USER_REQ_WIDTH     ),                                                      \
    .USER_DATA_WIDTH    (USER_DATA_WIDTH    ),                                                      \
    .USER_RESP_WIDTH    (USER_RESP_WIDTH    )

/*
 * AHB INTERFACE DEFINITIONS
 */

typedef enum bit [1:0] {
    HTRANS_IDLE,
    HTRANS_BUSY,
    HTRANS_NONSEQ,
    HTRANS_SEQ
} ahb_uvc_htrans_e;

typedef enum bit [2:0] {
    HSIZE_BYTE,     // 8 bits
    HSIZE_HALF,     // 16 bits
    HSIZE_WORD,     // 32 bits
    HSIZE_DOUBLE,   // 64 bits
    HSIZE_4WL,      // 4-word line
    HSIZE_8WL,      // 8-word line
    HSIZE_16WL,     // 16-word line
    HSIZE_32WL      // 32-word line
} ahb_uvc_hsize_e;

typedef enum bit [2:0] {
    HBURST_SINGLE,
    HBURST_INCR,
    HBURST_WRAP4,
    HBURST_INCR4,
    HBURST_WRAP8,
    HBURST_INCR8,
    HBURST_WRAP16,
    HBURST_INCR16
} ahb_uvc_hburst_e;

typedef enum bit {
    HRESP_OKAY,
    HRESP_ERROR
} ahb_uvc_hresp_e;

endpackage : rv0_core_defs

`endif // RV0_CORE_DEFS_SVH
