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
// Name: rv0_alu_b.sv
// Auth: Nikola Lukić
// Date: 20.12.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

import rv0_core_defs::*;

module rv0_alu_b #(`RV0_CORE_PARAM_LST) (

    input  logic [31:0]         alu_insn_i,
    input  logic [XLEN-1:0]     alu_addr_i,

    input  logic [XLEN-1:0]     alu_rdata1_i,
    input  logic [XLEN-1:0]     alu_rdata2_i,

    output logic [XLEN-1:0]     alu_ct_wdata_o,
    output logic [XLEN-1:0]     alu_ct_target_o,
    output logic                alu_ct_trans_o

);

    rv_opcode_e     opcode;
    logic [2:0]     funct3;
    logic [6:0]     funct7;

    assign opcode = rv_opcode_e'(alu_insn_i[6:0]);
    assign funct3 = alu_insn_i[14:12];
    assign funct7 = alu_insn_i[31:25];

    logic unsigned  [XLEN-1:0]  rdata1;
    logic unsigned  [XLEN-1:0]  rdata2;
    logic signed    [XLEN-1:0]  srdata1;
    logic signed    [XLEN-1:0]  srdata2;

    assign rdata1  = alu_rdata1_i;
    assign rdata2  = alu_rdata2_i;
    assign srdata1 = alu_rdata1_i;
    assign srdata2 = alu_rdata2_i;

    /*
     * CONTROL TRANSFER OFFSET
     */

    logic [XLEN-1:0] jal_ct_target_offs;
    logic [XLEN-1:0] jalr_ct_target_offs;
    logic [XLEN-1:0] branch_ct_target_offs;

    assign jal_ct_target_offs = {
        {XLEN-21{alu_insn_i[31]}},
        alu_insn_i[31],
        alu_insn_i[19:12],
        alu_insn_i[20],
        alu_insn_i[30:21],
        1'b0
    };

    assign jalr_ct_target_offs = {
        {XLEN-12{alu_insn_i[31]}},
        alu_insn_i[31:20]
    };

    assign branch_ct_target_offs = {
        {XLEN-13{alu_insn_i[31]}},
        alu_insn_i[31],
        alu_insn_i[7],
        alu_insn_i[30:25],
        alu_insn_i[11:8],
        1'b0
    };

    /*
     * CONTROL TRANSFER LOGIC
     */

    always_comb begin
        alu_ct_wdata_o  =  'h0;
        alu_ct_target_o =  'h0;
        alu_ct_trans_o  = 1'b0;

        case(opcode)
            JAL: begin
                alu_ct_wdata_o  = alu_addr_i + 'h4;
                alu_ct_target_o = (alu_addr_i + jal_ct_target_offs);
                alu_ct_trans_o  = 1'b1;
            end
            JALR: begin
                alu_ct_wdata_o  = alu_addr_i + 'h4;
                alu_ct_target_o = (rdata1 + jalr_ct_target_offs) & {{XLEN-1{1'b1}}, 1'b0};
                alu_ct_trans_o  = 1'b1;
            end
            BRANCH: begin
                alu_ct_target_o = alu_addr_i + branch_ct_target_offs;
                case(funct3)
                    BEQ:  alu_ct_trans_o = rdata1 == rdata2;
                    BNE:  alu_ct_trans_o = rdata1 != rdata2;
                    BLT:  alu_ct_trans_o = srdata1 <  srdata2;
                    BGE:  alu_ct_trans_o = srdata1 >= srdata2;
                    BLTU: alu_ct_trans_o = rdata1 < rdata2;
                    BGEU: alu_ct_trans_o = rdata1 >= rdata2;
                endcase
            end
        endcase
    end

endmodule : rv0_alu_b
