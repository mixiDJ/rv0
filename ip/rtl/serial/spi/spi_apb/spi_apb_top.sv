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
// Name: spi_apb_top.sv
// Auth: Nikola Lukić
// Date: 19.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module spi_apb_top #(
    parameter  int unsigned ADDR_WIDTH      = 32,
    parameter  int unsigned DATA_WIDTH      = 32,
    parameter  int unsigned USER_REQ_WIDTH  = 0,
    parameter  int unsigned USER_DATA_WIDTH = 0,
    parameter  int unsigned USER_RESP_WIDTH = 0,
    localparam int unsigned STRB_WIDTH      = DATA_WIDTH/8,
    parameter  int unsigned SPI_CS_CNT      = 3,
    parameter  int unsigned SPI_WIDTH       = 4
) (

    /* APB INTERFACE */
    input  logic                        pclk_i,
    input  logic                        prst_ni,
    output logic [ADDR_WIDTH-1:0]       paddr_i,
    output logic [3:0]                  pprot_i,
    output logic                        pnse_i,
    output logic                        psel_i,
    output logic                        penable_i,
    output logic                        pwrite_i,
    output logic [DATA_WIDTH-1:0]       pwdata_i,
    output logic [STRB_WIDTH-1:0]       pstrb_i,
    input  logic                        pready_o,
    input  logic [DATA_WIDTH-1:0]       prdata_o,
    input  logic                        pslverr_o,
    output logic                        pwakeup_i,
    output logic [USER_REQ_WIDTH-1:0]   pauser_i,
    output logic [USER_DATA_WIDTH-1:0]  pwuser_i,
    input  logic [USER_DATA_WIDTH-1:0]  pruser_o,
    input  logic [USER_RESP_WIDTH-1:0]  pbuser_o,

    /* SPI INTERFACE */
    output logic                        cs_no  [0:SPI_CS_CNT-1],
    output logic                        sclk_o,
    output logic                        mosi_o [0:SPI_WIDTH-1],
    input  logic                        miso_i [0:SPI_WIDTH-1]

);


endmodule : spi_apb_top
