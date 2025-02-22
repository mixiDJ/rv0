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
// Name: rv0_alu_f.sv
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
import rv0_core_defs::*;

module rv0_alu_f #(`RV0_CORE_PARAM_LST) (

    input logic [31:0]          alu_f_insn_i,
    input logic [FLEN-1:0]      alu_f_addr_i,

    input logic [FLEN-1:0]      alu_f_rdata1_i,
    input logic [FLEN-1:0]      alu_f_rdata2_i,

    // should this be a register or no?? TODO
    input logic [2:0]           frm, // rounding mode part of fp control status reg
                                    


    output logic [FLEN-1:0]     alu_f_wdata_o,
    output logic [4:0]          fflags // flags for fp control status reg

);
    // nzm sta je ovo?? - Za shift instrukcije 
    // localparam int unsigned SHAMT_WIDTH_32 = 5;
    // localparam int unsigned SHAMT_WIDTH_64 = 6;
    // localparam int unsigned SHAMT_WIDTH    = XLEN == 64 ? SHAMT_WIDTH_64 : SHAMT_WIDTH_32;
    localparam int unsigned BIAS = FLEN == 64 ? 1023 : 127;

    localparam int unsigned EXP_INDEX_END = FLEN == 64 ? 51 : 23;
    localparam int unsigned MANTISSA_INDEX_START = EXP_INDEX_END-1;
    localparam logic [22:0] THRESHOLD = {1'b1, 22'b0}; // 23-bit value: 100...0

    rv_opcode_e opcode;
    logic [6:0] funct7;
    logic [FLEN-1 : 0] alu_res;
    logic [2:0] rounding_mode;
    

    //logic [2:0] frm_reg;

    assign opcode = rv_opcode_e'(alu_f_insn_i[6:0]);
    // check for DYNAMIC MODE, than look to fcsr 
    assign rounding_mode = alu_f_insn_i[14:12] == DYN ? frm : alu_f_insn_i[14:12]; 
    assign funct7 = alu_f_insn_i[31:25];

    // sign of data vals
    logic sign_rdata1;
    logic sign_rdata2;

    //exponents of data vals, TODO needs small rework for 64 bit version
    // NOTE : exponent has bias (offset) of 127 or 32 bit version
    logic [7:0] exponent_rdata1;
    logic [7:0] exponent_rdata2;

    //matissas of data vals
    logic [22:0] mantissa_rdata1;
    logic [22:0] mantissa_rdata2;

    assign sign_rdata1 = alu_f_rdata1_i[FLEN-1];
    assign sign_rdata2 = alu_f_rdata2_i[FLEN-1];

    assign exponent_rdata1 = alu_f_rdata1_i[FLEN-2:EXP_INDEX_END];
    assign exponent_rdata2 = alu_f_rdata2_i[FLEN-2:EXP_INDEX_END];

    assign mantissa_rdata1 = alu_f_rdata1_i[MANTISSA_INDEX_START:0];
    assign mantissa_rdata2 = alu_f_rdata2_i[MANTISSA_INDEX_START:0];

    // flag for knowing which exponent is bigger
    logic exp_rdata1_bigger; 
    logic [7:0] exp_difference;

    // so, here is the idea to incorporate sign bits in these mantissa calculations
    // to use advantage of 2's complement addition
    // in other words, to not care about the signs of operands
    // just add them together
    // MSB is sign, MSB-1 is a 1 from IEEE 754 standard
    logic [24:0] mantissa_from_smaller;
    logic [24:0] mantissa_from_bigger;

    // wider for 1 bit for overflow
    logic [25:0] result_mantissa;
    logic [7:0] result_exponent;


    logic [4:0] fflags_reg;

    //mult results, for rounding later TODO
    logic [2*24-1 : 0] mult_long_mantissa;
    logic [22:0] excess_bits_from_mul;
    // this is expanded because if rounding 
    // is up, there can be overflow 
    // so exponent needs to increase
    // and to normalize mantissa
    logic [24:0] saved_mantissa_from_mul;

    

    always_comb begin : operation
        alu_res = {FLEN{1'b0}};
        fflags_reg = {5{1'b0}};

        exp_rdata1_bigger = exponent_rdata1 > exponent_rdata2 ? 1'b1 : 1'b0;
        exp_difference = exp_rdata1_bigger ? exponent_rdata1 - exponent_rdata2 : exponent_rdata2 - exponent_rdata1;

        
        mantissa_from_bigger[23] = 1'b1;

        // need to shift mantissa of lesser exponent
        if(exp_rdata1_bigger) begin
            // it should check if there is loss to precision,
            // i.e. least bits before shift are non zero, and that should raise a 
            // flag in fflags TODO
            mantissa_from_smaller[23:0] = {1'b1, mantissa_rdata2} >> exp_difference;
            mantissa_from_bigger[22:0] = mantissa_rdata1;
            mantissa_from_bigger[24] = sign_rdata1;
            mantissa_from_smaller[24] = sign_rdata2;
            
        end
        else begin
            mantissa_from_smaller[23:0] = {1'b1, mantissa_rdata1} >> exp_difference;
            mantissa_from_bigger[22:0] = mantissa_rdata2;
            mantissa_from_bigger[24] = sign_rdata2;
            mantissa_from_smaller[24] = sign_rdata1;
        end

        
        
        

        // do 2's complement last and add sign bit to this up TODO

        // if operand is negative, do 2's complement
        if(mantissa_from_bigger[24]) begin
            mantissa_from_bigger[23:0] = -mantissa_from_bigger[23:0];
        end

        if(mantissa_from_smaller[24]) begin
            mantissa_from_smaller[23:0] = -mantissa_from_smaller[23:0];
        end

        
       

        case (opcode)
            OP_FP: begin
                case (funct7)
                // FIX TO SET FLAGS FOR ARITHMETIC TODO
                    FUNCT7_FADD_S, FUNCT7_FSUB_S:
                     begin
                        if (funct7 == FUNCT7_FSUB_S) begin
                            if(exp_rdata1_bigger) begin
                                mantissa_from_smaller = -mantissa_from_smaller;
                            end
                            else begin
                                mantissa_from_bigger = -mantissa_from_bigger;
                            end
                        end
                        result_mantissa = mantissa_from_bigger + mantissa_from_smaller;
                        result_exponent = exp_rdata1_bigger ? exponent_rdata1 : exponent_rdata2;

                        //normalize 
                        if(result_mantissa[24]) begin
                            result_mantissa = result_mantissa >> 1;
                            result_exponent = result_exponent + 1;
                        end
                        // if both MSBs are 0, go down
                        // probably needs to be shifted until there is a leading 1 TODO
                        else if (!result_mantissa[23]) begin
                            result_mantissa = result_mantissa << 1;
                            result_exponent = result_exponent - 1;
                        end

                        alu_res = {result_mantissa[25],result_exponent,result_mantissa[22:0]};
                    end
                    FUNCT7_FMUL_S: begin
                        // sign of result is just xor of sign bits of both operands
                        alu_res[FLEN-1] = alu_f_rdata1_i[FLEN-1] ^ alu_f_rdata2_i[FLEN-1];

                        // exponent calculation: add both of them together and subtract bias
                        result_exponent = exponent_rdata1 + exponent_rdata2;
                        result_exponent = result_exponent - BIAS;

                        // using hardware multipliers, Im lazy to implement dadda tree, you are welcome to
                        // watch out where is decimal point
                        mult_long_mantissa = {1'b1,mantissa_rdata1} * {1'b1,mantissa_rdata2};

                        // if last bit is 1, need to normalize
                        if(mult_long_mantissa[2*24-1]) begin
                            result_exponent = result_exponent + 1;
                            mult_long_mantissa = mult_long_mantissa >> 1;
                        end
                        // if both last bits are zero, go down
                        else if (!mult_long_mantissa[2*24-2]) begin
                            result_exponent = result_exponent - 1;
                            mult_long_mantissa = mult_long_mantissa << 1;
                        end


                        excess_bits_from_mul = mult_long_mantissa[22:0];
                        //if rounding up, need 1 bit more for add
                        saved_mantissa_from_mul = {1'b0, mult_long_mantissa[2*24-2:23]};
                        // rounding now :(
                        if(excess_bits_from_mul != 23'b0) begin
                            // this raises the not exact flag in fflags TODO
                            fflags_reg[0] = 1'b1;
                            case(rounding_mode) 
                                RNE: begin // round down if 100000000... or less   
                                    if(excess_bits_from_mul > THRESHOLD) begin
                                        saved_mantissa_from_mul = saved_mantissa_from_mul + 1;
                                        if(saved_mantissa_from_mul[24]) begin
                                            saved_mantissa_from_mul = saved_mantissa_from_mul >> 1;
                                            result_exponent = result_exponent + 1;
                                        end
                                    end   
                                end
                                RTZ: begin
                                   // do nothing, just ignore excess bits 
                                end
                                RDN: begin // round down, careful with sign!!
                                    // if the result is negative 
                                    // go deeper down
                                    // if positive, just cut off the excess
                                    if(alu_res[FLEN-1]) begin
                                        saved_mantissa_from_mul = saved_mantissa_from_mul + 1;
                                        if(saved_mantissa_from_mul[24]) begin
                                            saved_mantissa_from_mul = saved_mantissa_from_mul >> 1;
                                            result_exponent = result_exponent + 1;
                                        end
                                    end
                                end
                                RUP: begin
                                    if(!alu_res[FLEN-1]) begin
                                        saved_mantissa_from_mul = saved_mantissa_from_mul + 1;
                                        if(saved_mantissa_from_mul[24]) begin
                                            saved_mantissa_from_mul = saved_mantissa_from_mul >> 1;
                                            result_exponent = result_exponent + 1;
                                        end
                                    end
                                end
                                RMM: begin
                                    if(excess_bits_from_mul >= THRESHOLD) begin
                                        saved_mantissa_from_mul = saved_mantissa_from_mul + 1;
                                        if(saved_mantissa_from_mul[24]) begin
                                            saved_mantissa_from_mul = saved_mantissa_from_mul >> 1;
                                            result_exponent = result_exponent + 1;
                                        end
                                    end 
                                end
                            endcase
                        end 

                        alu_res[FLEN-2:0] = {result_exponent,saved_mantissa_from_mul[22:0]};        
                    end
                    FUNCT7_FMIN_FMAX_S: begin
                        case(rounding_mode) // same field is used
                            FMIN : begin
                                if(alu_f_rdata1_i == NaN && alu_f_rdata2_i == NaN) begin
                                    alu_res = NaN;
                                    // triggers NV flag in fflags
                                    fflags_reg[4] = 1'b1;
                                end
                                else if (alu_f_rdata1_i == NaN) alu_res = alu_f_rdata2_i;
                                else if (alu_f_rdata2_i == NaN) alu_res = alu_f_rdata1_i;
                                else begin
                                    if (sign_rdata1 ^ sign_rdata2) alu_res = sign_rdata1 ? alu_f_rdata1_i : alu_f_rdata2_i;
                                    else if(exponent_rdata1 == exponent_rdata2) begin
                                        if (mantissa_rdata1 <= mantissa_rdata2) alu_res = alu_f_rdata1_i;
                                        else alu_res = alu_f_rdata2_i;
                                    end
                                    else if (exponent_rdata1 < exponent_rdata2) alu_res = alu_f_rdata1_i;
                                    else alu_res = alu_f_rdata2_i;
                                end
                            end
                            FMAX : begin
                                if(alu_f_rdata1_i == NaN && alu_f_rdata2_i == NaN) begin
                                    alu_res = NaN;
                                    // triggers NV flag in fflags
                                    fflags_reg[4] = 1'b1;
                                end
                                else if (alu_f_rdata1_i == NaN) alu_res = alu_f_rdata2_i;
                                else if (alu_f_rdata2_i == NaN) alu_res = alu_f_rdata1_i;
                                else begin
                                    if (sign_rdata1 ^ sign_rdata2) alu_res = sign_rdata1 ? alu_f_rdata2_i : alu_f_rdata1_i;
                                    else if(exponent_rdata1 == exponent_rdata2) begin
                                        if (mantissa_rdata1 >= mantissa_rdata2) alu_res = alu_f_rdata1_i;
                                        else alu_res = alu_f_rdata2_i;
                                    end
                                    else if (exponent_rdata1 > exponent_rdata2) alu_res = alu_f_rdata1_i;
                                    else alu_res = alu_f_rdata2_i;
                                end  
                            end
                        endcase
                    end
                endcase
            end
        endcase
        alu_f_wdata_o = alu_res;
        fflags = fflags_reg;
    end




endmodule : rv0_alu_f
