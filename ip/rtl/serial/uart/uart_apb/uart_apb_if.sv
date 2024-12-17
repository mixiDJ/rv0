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
// Name: uart_apb_if.sv
// Auth: Nikola Lukić
// Date: 20.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module uart_apb_if #(
    parameter  int unsigned         ADDR_WIDTH      = 32,
    parameter  int unsigned         DATA_WIDTH      = 32,
    parameter  int unsigned         USER_REQ_WIDTH  = 0,
    parameter  int unsigned         USER_DATA_WIDTH = 0,
    parameter  int unsigned         USER_RESP_WIDTH = 0,
    localparam int unsigned         STRB_WIDTH      = DATA_WIDTH/8,
    parameter  bit [ADDR_WIDTH-1:0] UART_ADDR_BASE  = 'h1600_0000,
    parameter  bit [ADDR_WIDTH-1:0] UART_ADDR_MASK  = 'hfff
) (

    /* APB INTERFACE */
    input  logic                        pclk_i,
    input  logic                        prst_ni,
    input  logic [ADDR_WIDTH-1:0]       paddr_i,
    input  logic [3:0]                  pprot_i,
    input  logic                        pnse_i,
    input  logic                        psel_i,
    input  logic                        penable_i,
    input  logic                        pwrite_i,
    input  logic [DATA_WIDTH-1:0]       pwdata_i,
    input  logic [STRB_WIDTH-1:0]       pstrb_i,
    output logic                        pready_o,
    output logic [DATA_WIDTH-1:0]       prdata_o,
    output logic                        pslverr_o,
    input  logic                        pwakeup_i,
    input  logic [USER_REQ_WIDTH-1:0]   pauser_i,
    input  logic [USER_DATA_WIDTH-1:0]  pwuser_i,
    output logic [USER_DATA_WIDTH-1:0]  pruser_o,
    output logic [USER_RESP_WIDTH-1:0]  pbuser_o,

    /* REGISTER INTERFACE */
    output logic                        reg_access_o,
    output logic [11:0]                 reg_addr_o,
    output logic                        reg_we_o,
    output logic [15:0]                 reg_wdata_o,
    input  logic [15:0]                 reg_rdata_i

);

    /*
     * APB INTERFACE LOGIC
     */

    logic bus_addr_valid;
    assign bus_addr_valid = ((paddr_i & ~UART_ADDR_MASK) == UART_ADDR_BASE) && paddr_i[1:0] == 2'b00;

    logic bus_req_pend;
    assign bus_req_pend = psel_i == 1'b1 && penable_i == 1'b1 && pready_o == 1'b0;

    logic bus_req_valid;
    assign bus_req_valid = bus_req_pend == 1'b1 && bus_addr_valid == 1'b1;

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) pready_o <= 1'b0;
        else pready_o <= bus_req_pend == 1'b1;
    end

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) prdata_o <= {DATA_WIDTH{1'b0}};
        else if(bus_req_valid == 1'b1 && pwrite_i == 1'b0) prdata_o <= reg_rdata_i;
    end

    always_ff @(posedge pclk_i or negedge prst_ni) begin
        if(prst_ni == 1'b0) pslverr_o <= 1'b0;
        else pslverr_o <= bus_req_pend == 1'b1 && bus_req_valid == 1'b0;
    end


    /*
     * REGISTER COMMAND LOGIC
     */

    assign reg_access_o = bus_req_pend == 1'b1;
    assign reg_addr_o   = paddr_i[11:0] & ~12'b11;
    assign reg_we_o     = bus_req_valid == 1'b1 && pwrite_i == 1'b1;
    assign reg_wdata_o  = pwdata_i[15:0];

endmodule : uart_apb_if
