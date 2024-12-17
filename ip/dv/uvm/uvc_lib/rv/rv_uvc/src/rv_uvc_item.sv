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
// Name: rv_uvc_item.sv
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

`ifndef RV_UVC_ITEM_SV
`define RV_UVC_ITEM_SV

class rv_uvc_item #(`RV_UVC_PARAM_LST) extends uvm_sequence_item;

    /* ITEM FIELDS */
    rand rv_uvc_insn_type_e     insn_type;

    rand bit [4:0]              rs2;
    rand bit [4:0]              rs1;
    rand bit [4:0]              rd;

    rand bit [XLEN-1:0]         imm;

    rand bit [2:0]              funct3;
    rand bit [6:0]              funct7;

    rand rv_uvc_opcode_e        opcode;

    rand bit [31:0]             insn;
    bit [XLEN-1:0]              addr;
    bit [XLEN-1:0]              res;

    /* ITEM CONSTRAINTS */
    constraint c_opcode {
        (XLEN  == 32  ) -> soft !(opcode inside {OP_IMM_32, OP_32});
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

        (opcode == OP_IMM && funct3 == SLL && XLEN == 32) ->
            soft imm[11:5] == 7'b0000000;

        (opcode == OP_IMM && funct3 == SRL && XLEN == 32) ->
            soft imm[11:5] inside {7'b0000000, 7'b0100000};

        (opcode == OP_IMM && funct3 == SLL && XLEN == 64) ->
            soft imm[11:6] == 6'b000000;

        (opcode == OP_IMM && funct3 == SRL && XLEN == 64) ->
            soft imm[11:6] inside {6'b000000, 6'b010000};

        (opcode == OP_IMM_32 && funct3 == SLL) ->
            soft imm[11:5] == 7'b0000000;

        (opcode == OP_IMM_32 && funct3 == SRL) ->
            soft imm[11:5] inside {7'b0000000, 7'b0100000};

    }

    constraint c_funct3 {
        solve opcode before funct3;

        (opcode == JALR) ->
            soft funct3 == 3'b000;

        (opcode == BRANCH) ->
            soft funct3 inside {BEQ, BNE, BLT, BGE, BLTU, BGEU};

        (opcode == LOAD && XLEN == 32) ->
            soft funct3 inside {LB, LH, LW, LBU, LHU};

        (opcode == LOAD && XLEN == 64) ->
            soft funct3 inside {LB, LH, LW, LD, LBU, LHU, LWU};

        (opcode == STORE && XLEN == 32) ->
            soft funct3 inside {SB, SH, SW};

        (opcode == STORE && XLEN == 64) ->
            soft funct3 inside {SH, SH, SW, SD};

        (opcode == OP_IMM) ->
            soft funct3 inside {ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, ORI, ANDI};

        (opcode == OP_IMM_32) ->
            soft funct3 inside {ADDIW, SLLIW, SRLIW};

        (opcode == OP_32) ->
            soft funct3 inside {ADDW, SLLW, SRLW};

    }

    constraint c_funct7 {
        solve opcode before funct7;
        solve funct3 before funct7;

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

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(rv_uvc_item#(`RV_UVC_PARAMS))
        `uvm_field_enum(rv_uvc_insn_type_e, insn_type,  UVM_DEFAULT                )
        `uvm_field_int (                    rs2,        UVM_DEFAULT | UVM_DEC      )
        `uvm_field_int (                    rs1,        UVM_DEFAULT | UVM_DEC      )
        `uvm_field_int (                    rd,         UVM_DEFAULT | UVM_DEC      )
        `uvm_field_int (                    imm,        UVM_DEFAULT                )
        `uvm_field_int (                    funct3,     UVM_DEFAULT | UVM_BIN      )
        `uvm_field_int (                    funct7,     UVM_DEFAULT | UVM_BIN      )
        `uvm_field_enum(rv_uvc_opcode_e,    opcode,     UVM_DEFAULT | UVM_BIN      )
        `uvm_field_int (                    insn,       UVM_DEFAULT                )
        `uvm_field_int (                    addr,       UVM_DEFAULT                )
        `uvm_field_int (                    res,        UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end
    `uvm_object_new

    /* METHODS */
    extern function void set_fields();
    extern function void do_print(uvm_printer printer);
    extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);

endclass : rv_uvc_item

function void rv_uvc_item::set_fields();

    opcode = rv_uvc_opcode_e'(insn[6:0]);

    case(opcode)

        // RV_INSN_TYPE_R
        OP: begin
            insn_type = RV_INSN_TYPE_R;
            funct7    = insn[31:25];
            rs2       = insn[24:20];
            rs1       = insn[19:15];
            funct3    = insn[14:12];
            rd        = insn[11:7];
        end

        // RV_INSN_TYPE_I
        JALR, LOAD, OP_IMM: begin
            insn_type = RV_INSN_TYPE_I;
            imm       = {{XLEN-12{insn[31]}}, insn[31:20]};
            rs1       = insn[19:15];
            funct3    = insn[14:12];
            rd        = insn[11:7];
        end

        // RV_INSN_TYPE_S
        STORE: begin
            insn_type = RV_INSN_TYPE_S;
            imm       = {{XLEN-12{insn[31]}}, insn[31:25], insn[11:7]};
            rs2       = insn[24:20];
            rs1       = insn[19:15];
            funct3    = insn[14:12];
        end

        // RV_INSN_TYPE_B
        BRANCH: begin
            insn_type = RV_INSN_TYPE_B;
            imm       = {{XLEN-12{insn[31]}}, insn[7], insn[30:25], insn[11:8], 1'b0};
            rs2       = insn[24:20];
            rs1       = insn[19:15];
            funct3    = insn[14:12];
        end

        // RV_INSN_TYPE_U
        LUI, AUIPC: begin
            insn_type = RV_INSN_TYPE_U;
            imm       = {{XLEN-32{insn[31]}}, insn[31:12], 12'h0};
            rd        = insn[11:7];
        end

        // RV_INSN_TYPE_J
        JAL: begin
            insn_type = RV_INSN_TYPE_J;
            imm       = {{XLEN-20{insn[31]}}, insn[19:12], insn[20], insn[30:21], 1'b0};
            rd        = insn[11:7];
        end

    endcase

endfunction : set_fields

function void rv_uvc_item::do_print(uvm_printer printer);
    super.do_print(printer);

    case(opcode)

        LUI: begin
            printer.print_string("insn", $sformatf("LUI x%0d, 0x%0h", rd, imm));
        end

        AUIPC: begin
            printer.print_string("insn", $sformatf("AUIPC x%0d, 0x%0h", rd, imm));
        end

        JAL: begin
            printer.print_string("insn", $sformatf("JAL x%0d, 0x%0h", rd, imm));
        end

        JALR: begin
            printer.print_string("insn", $sformatf("JALR x%0d, x%0d, 0x%0h", rd, rs1, imm));
        end

        BRANCH: begin

            case(funct3)

                BEQ: begin
                    printer.print_string("insn", $sformatf("BEQ x%0d, x%0d, 0x%0h", rs1, rs2, imm));
                end

                BNE: begin
                    printer.print_string("insn", $sformatf("BNE x%0d, x%0d, 0x%0h", rs1, rs2, imm));
                end

                BLT: begin
                    printer.print_string("insn", $sformatf("BLT x%0d, x%0d, 0x%0h", rs1, rs2, imm));
                end

                BGE: begin
                    printer.print_string("insn", $sformatf("BGE x%0d, x%0d, 0x%0h", rs1, rs2, imm));
                end

                BLTU: begin
                    printer.print_string("insn", $sformatf("BLTU x%0d, x%0d, 0x%0h", rs1, rs2, imm));
                end

                BGEU: begin
                    printer.print_string("insn", $sformatf("BGEU x%0d, x%0d, 0x%0h", rs1, rs2, imm));
                end

                default: begin
                    `uvm_warning(`gtn, "INVALID INSTRUCTION")
                end

            endcase

        end

        LOAD: begin

            case(funct3)

                LB: begin
                    printer.print_string("insn", $sformatf("LB x%0d, 0x%0h(x%0d)", rd, imm, rs1));
                end

                LH: begin
                    printer.print_string("insn", $sformatf("LH x%0d, 0x%0h(x%0d)", rd, imm, rs1));
                end

                LW: begin
                    printer.print_string("insn", $sformatf("LW x%0d, 0x%0h(x%0d)", rd, imm, rs1));
                end

                LD: begin
                    printer.print_string("insn", $sformatf("LD x%0d, 0x%0h(x%0d)", rd, imm, rs1));
                end

                LBU: begin
                    printer.print_string("insn", $sformatf("LBU x%0d, 0x%0h(x%0d)", rd, imm, rs1));
                end

                LHU: begin
                    printer.print_string("insn", $sformatf("LHU x%0d, 0x%0h(x%0d)", rd, imm, rs1));
                end

                LWU: begin
                    printer.print_string("insn", $sformatf("LWU x%0d, 0x%0h(x%0d)", rd, imm, rs1));
                end

                default: begin
                    `uvm_warning(`gtn, "INVALID INSTRUCTION")
                end

            endcase

        end

        STORE: begin

            case(funct3)

                SB: begin
                    printer.print_string("insn", $sformatf("SB x%0d, 0x%0h(x%0d)", rs2, imm, rs1));
                end

                SH: begin
                    printer.print_string("insn", $sformatf("SH x%0d, 0x%0h(x%0d)", rs2, imm, rs1));
                end

                SW: begin
                    printer.print_string("insn", $sformatf("SW x%0d, 0x%0h(x%0d)", rs2, imm, rs1));
                end

                SD: begin
                    printer.print_string("insn", $sformatf("SD x%0d, 0x%0h(x%0d)", rs2, imm, rs1));
                end

                default: begin
                    `uvm_warning(`gtn, "INVALID INSTRUCTION")
                end

            endcase

        end

        OP_IMM: begin

            case(funct3)

                ADDI: begin
                    printer.print_string("insn", $sformatf("ADDI x%0d, x%0d, 0x%0h", rd, rs1, imm));
                end

                SLLI: begin
                    printer.print_string("insn", $sformatf("SLLI x%0d, x%0d, 0x%0h", rd, rs1, imm));
                end

                SLTI: begin
                    printer.print_string("insn", $sformatf("SLTI x%0d, x%0d, 0x%0h", rd, rs1, imm));
                end

                SLTIU: begin
                    printer.print_string("insn", $sformatf("SLTIU x%0d, x%0d, 0x%0h", rd, rs1, imm));
                end

                XORI: begin
                    printer.print_string("insn", $sformatf("XORI x%0d, x%0d, 0x%0h", rd, rs1, imm));
                end

                SRLI: begin

                    if(insn[30]) begin
                        printer.print_string("insn", $sformatf("SRAI x%0d, x%0d, 0x%0h", rd, rs1, imm));
                    end
                    else begin
                        printer.print_string("insn", $sformatf("SRLI x%0d, x%0d, 0x%0h", rd, rs1, imm));
                    end

                end

                ORI: begin
                    printer.print_string("insn", $sformatf("ORI x%0d, x%0d, 0x%0h", rd, rs1, imm));
                end

                ANDI: begin
                    printer.print_string("insn", $sformatf("ANDI x%0d, x%0d, 0x%0h", rd, rs1, imm));
                end

                default: begin
                    `uvm_warning(`gtn, "INVALID INSTRUCTION")
                end

            endcase

        end

        OP: begin
            case(funct3)

                ADD: begin

                    if(funct7[5]) begin
                        printer.print_string("insn", $sformatf("SUB x%0d, x%0d, x%0d", rd, rs1, rs2));
                    end
                    else begin
                        printer.print_string("insn", $sformatf("ADD x%0d, x%0d, x%0d", rd, rs1, rs2));
                    end

                end

                SLL: begin
                    printer.print_string("insn", $sformatf("SLL x%0d, x%0d, x%0d", rd, rs1, rs2));
                end

                SLT: begin
                    printer.print_string("insn", $sformatf("SLT x%0d, x%0d, x%0d", rd, rs1, rs2));
                end

                SLTU: begin
                    printer.print_string("insn", $sformatf("SLTU x%0d, x%0d, x%0d", rd, rs1, rs2));
                end

                XOR: begin
                    printer.print_string("insn", $sformatf("XOR x%0d, x%0d, x%0d", rd, rs1, rs2));
                end

                SRL: begin

                    if(funct7[5]) begin
                        printer.print_string("insn", $sformatf("SRA x%0d, x%0d, x%0d", rd, rs1, rs2));
                    end
                    else begin
                        printer.print_string("insn", $sformatf("SRL x%0d, x%0d, x%0d", rd, rs1, rs2));
                    end

                end

                OR: begin
                    printer.print_string("insn", $sformatf("OR x%0d, x%0d, x%0d", rd, rs1, rs2));
                end

                AND: begin
                    printer.print_string("insn", $sformatf("AND x%0d, x%0d, x%0d", rd, rs1, rs2));
                end

                default: begin
                    `uvm_warning(`gtn, "INVALID INSTRUCTION")
                end

            endcase
        end

        default: begin
            `uvm_warning(`gtn, "INVALID INSTRUCTION")
        end

    endcase

endfunction : do_print

function bit rv_uvc_item::do_compare(uvm_object rhs, uvm_comparer comparer);
    rv_uvc_item#(`RV_UVC_PARAMS)    _rhs;
    bit                             sts;

    if(!$cast(_rhs, rhs)) return 0;

    sts = super.do_compare(rhs, comparer);
    case(opcode)
        BRANCH:  return sts;
        STORE:   return sts;
        default: return sts && comparer.compare_field_int("res", this.res, _rhs.res, XLEN);
    endcase

endfunction : do_compare

`endif // RV_UVC_ITEM_SV
