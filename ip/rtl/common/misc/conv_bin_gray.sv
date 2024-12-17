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
// Name: conv_bin_gray.sv
// Auth: Nikola Lukić
// Date: 07.09.2024.
// Desc: Binary to Gray code converter
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module conv_bin_gray #(
    parameter int unsigned WIDTH = 32
) (
    input  logic [WIDTH-1:0]    bin_i,
    output logic [WIDTH-1:0]    gray_o
);

    for(genvar i = 0; i < WIDTH - 1; ++i) begin
        assign gray_o[i] = bin_i[i] ^ bin_i[i+1];
    end
    assign gray_o[WIDTH-1] = bin_i[WIDTH-1];

endmodule : conv_bin_gray
