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
// Name: rv0_alu_i.sv
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

`include "rv0_core_defs.svh"

module rv0_alu_i #(`RV0_CORE_PARAM_LST) (

    input  logic                clk_i,
    input  logic                rst_ni,

    input  logic [31:0]         alu_insn_i,

    input  logic [XLEN-1:0]     alu_rdata1_i,
    input  logic [XLEN-1:0]     alu_rdata2_i,

    output logic [XLEN-1:0]     alu_wdata_o

);

    localparam int unsigned SHAMT_WIDTH = XLEN == 64 ? 6 : 5;

    logic [6:0]             opcode;
    logic [2:0]             funct3;
    logic [6:0]             funct7;
    logic [SHAMT_WIDTH-1:0] shamt;

    assign opcode = alu_insn_i[6:0];
    assign funct3 = alu_insn_i[14:12];
    assign funct7 = alu_insn_i[31:25];

    if(XLEN == 64) begin : shamt64_genblk
        // TODO
    end // shamt64_genblk
    else begin : shamt32_genblk
        assign shamt = alu_rdata2_i[SHAMT_WIDTH-1:0];
    end // shamt32_genblk

    always_comb begin
        alu_wdata_o = {XLEN{1'b0}};

        case(opcode)

            OP_IMM: begin

                case(funct3)

                    ADDI: begin
                        alu_wdata_o = alu_rdata1_i + alu_rdata2_i;
                    end

                    SLLI: begin
                        alu_wdata_o = alu_rdata1_i << shamt;
                    end

                    SLTI: begin
                        alu_wdata_o = $signed(alu_rdata1_i) < $signed(alu_rdata2_i);
                    end

                    SLTIU: begin
                        alu_wdata_o = alu_rdata1_i < alu_rdata2_i;
                    end

                    XORI: begin
                       alu_wdata_o = alu_rdata1_i ^ alu_rdata2_i;
                    end

                    SRLI: begin

                        if(funct7[5]) begin
                            alu_wdata_o = $signed(alu_rdata1_i) >>> shamt;
                        end
                        else begin
                            alu_wdata_o = alu_rdata1_i >> shamt;
                        end

                    end

                    ORI: begin
                        alu_wdata_o = alu_rdata1_i | alu_rdata2_i;
                    end

                    ANDI: begin
                        alu_wdata_o = alu_rdata1_i & alu_rdata2_i;
                    end

                endcase

            end

            OP: begin

                case(funct3)

                    ADD: begin

                        if(funct7[5]) begin
                            alu_wdata_o = alu_rdata1_i - alu_rdata2_i;
                        end
                        else begin
                            alu_wdata_o = alu_rdata1_i + alu_rdata2_i;
                        end

                    end

                    SLL: begin
                        alu_wdata_o = alu_rdata1_i << shamt;
                    end

                    SLT: begin
                        alu_wdata_o = $signed(alu_rdata1_i) < $signed(alu_rdata2_i);
                    end

                    SLTU: begin
                        alu_wdata_o = alu_rdata1_i < alu_rdata2_i;
                    end

                    XOR: begin
                        alu_wdata_o = alu_rdata1_i ^ alu_rdata2_i;
                    end

                    SRL: begin

                        if(funct7[5]) begin
                            alu_wdata_o = $signed(alu_rdata1_i) >>> shamt;
                        end
                        else begin
                            alu_wdata_o = alu_rdata1_i >> shamt;
                        end

                    end

                    OR: begin
                        alu_wdata_o = alu_rdata1_i | alu_rdata2_i;
                    end

                    AND: begin
                        alu_wdata_o = alu_rdata1_i & alu_rdata2_i;
                    end

                endcase

            end

            default: begin
                alu_wdata_o = alu_rdata1_i + alu_rdata2_i;
            end

        endcase

    end

endmodule : rv0_alu_i
