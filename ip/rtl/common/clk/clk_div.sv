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
// Name: clk_div.svh
// Auth: Nikola Lukić
// Date: 28.08.2024.
// Desc: ***
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module clk_div #(
    // divider counter width
    parameter int unsigned  CNT_WIDTH = 8,
    // constant divider value mode enable
    parameter bit           DIV_CONST = 0,
    // constant divider value
    parameter int unsigned  DIV_VALUE = {{CNT_WIDTH-1{1'b0}}, 1'b1}
) (

    input  logic                    clk_i,
    input  logic                    rst_ni,

    input  logic [CNT_WIDTH-1:0]    div_i,
    output logic                    dclk_o

);

    logic [CNT_WIDTH-1:0] cnt_q;

    if(DIV_CONST == 1'b1) begin : const_div_genblk

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) cnt_q <= {CNT_WIDTH{1'b0}};
            else begin
                if(cnt_q == DIV_VALUE - 1) cnt_q <= {CNT_WIDTH{1'b0}};
                else cnt_q <= cnt_q + 1;
            end
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) dclk_o <= 1'b0;
            else if(cnt_q == DIV_VALUE - 1) dclk_o <= ~dclk_o;
        end

    end // const_div_genblk
    else begin : var_div_genblk

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) cnt_q <= {CNT_WIDTH{1'b0}};
            else begin
                if(cnt_q >= div_i - 1) cnt_q <= {CNT_WIDTH{1'b0}};
                else cnt_q <= cnt_q + 1;

                if(div_i == {CNT_WIDTH{1'b0}}) cnt_q <= {CNT_WIDTH{1'b0}};
            end
        end

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) dclk_o <= 1'b0;
            else if(cnt_q >= div_i - 1) dclk_o <= ~dclk_o;
        end

    end // var_dir_genblk

endmodule : clk_div
