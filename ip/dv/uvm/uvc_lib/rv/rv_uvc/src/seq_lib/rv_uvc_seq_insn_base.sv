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
// Name: rv_uvc_seq_insn_base.sv
// Auth: Nikola Lukić
// Date: 09.11.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV_UVC_SEQ_INSN_BASE_SV
`define RV_UVC_SEQ_INSN_BASE_SV

class rv_uvc_seq_insn_base#(`RV_UVC_PARAM_LST) extends uvm_sequence#(rv_uvc_item#(`RV_UVC_PARAMS));

    /* SEQUENCE FIELDS */
    rand rv_uvc_insn_type_e     insn_type;

    rand bit [4:0]              rs2;
    rand bit [4:0]              rs1;
    rand bit [4:0]              rd;

    rand bit [XLEN-1:0]         imm;

    rand bit [2:0]              funct3;
    rand bit [6:0]              funct7;

    rand rv_uvc_opcode_e        opcode;

    rand bit [31:0]             insn;

    /* SEQUENCE CONSTRAINTS */
    constraint c_opcode {
        (XLEN  == 32)   -> soft !(opcode inside {OP_IMM_32, OP_32});
        (RVA   == 1'b0) -> soft !(opcode inside {AMO});
        (RVF   == 1'b0) -> soft !(opcode inside {LOAD_FP, STORE_FP, OP_FP});
        (RVF   == 1'b0) -> soft !(opcode inside {MADD, MSUB, NMSUB, NMADD});
        // FIXME
        (ZICSR == 1'b0) -> soft !(opcode inside {SYSTEM});
        soft !(opcode inside {MISC_MEM});
    }

    constraint c_insn_type {
        solve opcode before insn_type;

        (opcode == LUI      ) -> soft insn_type == RV_INSN_TYPE_U;
        (opcode == AUIPC    ) -> soft insn_type == RV_INSN_TYPE_U;
        (opcode == JAL      ) -> soft insn_type == RV_INSN_TYPE_J;
        (opcode == JALR     ) -> soft insn_type == RV_INSN_TYPE_I;
        (opcode == BRANCH   ) -> soft insn_type == RV_INSN_TYPE_B;
        (opcode == LOAD     ) -> soft insn_type == RV_INSN_TYPE_I;
        (opcode == STORE    ) -> soft insn_type == RV_INSN_TYPE_S;
        (opcode == OP_IMM   ) -> soft insn_type == RV_INSN_TYPE_I;
        (opcode == OP       ) -> soft insn_type == RV_INSN_TYPE_R;
        (opcode == OP_IMM_32) -> soft insn_type == RV_INSN_TYPE_I;
        (opcode == OP_32    ) -> soft insn_type == RV_INSN_TYPE_R;

        // TODO:
        (opcode == LOAD_FP  ) -> soft insn_type == RV_INSN_TYPE_I;
        (opcode == STORE_FP ) -> soft insn_type == RV_INSN_TYPE_S;
        (opcode == OP_FP    ) -> soft insn_type == RV_INSN_TYPE_R;
        (opcode == MADD     ) -> soft insn_type == RV_INSN_TYPE_R;
        (opcode == MSUB     ) -> soft insn_type == RV_INSN_TYPE_R;
        (opcode == NMSUB    ) -> soft insn_type == RV_INSN_TYPE_R;
        (opcode == NMADD    ) -> soft insn_type == RV_INSN_TYPE_R;
        (opcode == AMO      ) -> soft insn_type == RV_INSN_TYPE_R;
        (opcode == SYSTEM   ) -> soft insn_type == RV_INSN_TYPE_I;
        (opcode == MISC_MEM ) -> soft insn_type == RV_INSN_TYPE_I;
    }

    constraint c_rs1 { (RVE == 1'b1) -> soft rs1 inside {[0:15]}; }
    constraint c_rs2 { (RVE == 1'b1) -> soft rs2 inside {[0:15]}; }
    constraint c_rd  { (RVE == 1'b1) -> soft rd  inside {[0:15]}; }

    constraint c_imm {
        solve opcode before imm;
        solve funct3 before imm;

        (opcode == OP_IMM && funct3 inside {SLL, SRL} && XLEN == 32) ->
            soft imm[11:5] == 7'b0;

        (opcode == OP_IMM && funct3 inside {SLL, SRL} && XLEN == 64) ->
            soft imm[11:6] == 6'b0;

        (opcode == OP_IMM && funct3 == SRL && XLEN == 32) ->
            soft imm[11:5] inside {7'b0000000, 7'b0100000};

    }

    constraint c_funct3 {
        solve opcode before funct3;

        (opcode == JALR) ->
            soft funct3 == 3'b000;

        (opcode == BRANCH) ->
            soft funct3 inside {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};

        (opcode == LOAD) ->
            soft funct3 inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101};

        (opcode == STORE) ->
            soft funct3 inside {3'b000, 3'b001, 3'b010};

        (opcode == OP_IMM) ->
            soft funct3 inside {3'b000, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111};

    }

    constraint c_funct7 {
        solve funct3 before funct7;
        solve opcode before funct7;

        (opcode == RV_INSN_TYPE_R && funct3 == ADD) ->
            soft funct7 inside {7'b0000000, 7'b0100000};

        (opcode == RV_INSN_TYPE_R && funct3 == SLL) ->
            soft funct7 == 7'b0000000;

        (opcode == RV_INSN_TYPE_R && funct3 == SLT) ->
            soft funct7 == 7'b0000000;

        (opcode == RV_INSN_TYPE_R && funct3 == SLTU) ->
            soft funct7 == 7'b0000000;

        (opcode == RV_INSN_TYPE_R && funct3 == XOR) ->
            soft funct7 == 7'b0000000;

        (opcode == RV_INSN_TYPE_R && funct3 == SRL) ->
            soft funct7 inside {7'b0000000, 7'b0100000};

        (opcode == RV_INSN_TYPE_R && funct3 == OR) ->
            soft funct7 == 7'b0000000;

        (opcode == RV_INSN_TYPE_R && funct3 == AND) ->
            soft funct7 == 7'b0000000;

    }

    constraint c_insn {
        solve opcode before insn;
        solve insn_type before insn;
        solve imm before insn;
        solve funct3 before insn;
        solve funct7 before insn;

        (insn_type == RV_INSN_TYPE_R) ->
            soft insn == {funct7, rs2, rs1, funct3, rd, opcode};

        (insn_type == RV_INSN_TYPE_I) ->
            soft insn == {imm[11:0], rs1, funct3, rd, opcode};

        (insn_type == RV_INSN_TYPE_S) ->
            soft insn == {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};

        (insn_type == RV_INSN_TYPE_B) ->
            soft insn == {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};

        (insn_type == RV_INSN_TYPE_U) ->
            soft insn == {imm[31:12], rd, opcode};

        (insn_type == RV_INSN_TYPE_J) ->
            soft insn == {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};

    }

    /* SEQUENCE ITEMS */
    REQ m_req;

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(rv_uvc_seq_insn_base#(`RV_UVC_PARAMS))
        `uvm_field_enum(rv_uvc_insn_type_e, insn_type,  UVM_DEFAULT)
        `uvm_field_int (                    rs2,        UVM_DEFAULT)
        `uvm_field_int (                    rs1,        UVM_DEFAULT)
        `uvm_field_int (                    rd,         UVM_DEFAULT)
        `uvm_field_int (                    imm,        UVM_DEFAULT)
        `uvm_field_int (                    funct3,     UVM_DEFAULT)
        `uvm_field_int (                    funct7,     UVM_DEFAULT)
        `uvm_field_enum(rv_uvc_opcode_e,    opcode,     UVM_DEFAULT)
        `uvm_field_int (                    insn,       UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new

    /* SEQUENCE BODY TASK */
    extern virtual task body();

endclass : rv_uvc_seq_insn_base

task rv_uvc_seq_insn_base::body();

    `uvm_do_with(
        m_req,
        {
            rs2     == local::rs2;
            rs1     == local::rs1;
            rd      == local::rd;
            imm     == local::imm;
            funct3  == local::funct3;
            funct7  == local::funct7;
            opcode  == local::opcode;
            insn    == local::insn;
        }
    )

endtask : body

`endif // RV_UVC_SEQ_INSN_BASE_SV
