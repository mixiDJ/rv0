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
// Name: uart_tx.sv
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

module uart_tx (

    input  logic            clk_i,
    input  logic            rst_ni,

    input  logic            uart_tx_en_i,

    input  logic            bclk_tick_i,

    input  logic            lcr_sps_i,
    input  logic [ 1:0]     lcr_wlen_i,
    input  logic            lcr_fen_i,
    input  logic            lcr_stp2_i,
    input  logic            lcr_eps_i,
    input  logic            lcr_pen_i,
    input  logic            lcr_brk_i,

    input  logic [7:0]      uart_tx_data_i,
    input  logic            uart_tx_data_rdy_i,
    output logic            uart_tx_data_ack_o,

    output logic            uart_tx_o

);

    logic [3:0] uart_tx_bit_cnt_q;
    logic       uart_tx_bit_cnt_ena;

    logic [3:0] uart_tx_tick_cnt_q;
    logic       uart_tx_tick_cnt_ena;


    /*
     * UART TX CTRL FSM
     */

    typedef enum bit [4:0] {
        S_TX_IDLE,
        S_TX_START,
        S_TX_DATA,
        S_TX_PAR,
        S_TX_STOP
    } uart_tx_fsm_state_e;

    uart_tx_fsm_state_e uart_tx_fsm_state_q;
    uart_tx_fsm_state_e uart_tx_fsm_state_d;

    logic stp2_q;

    logic bit_tick;
    assign bit_tick = &uart_tx_tick_cnt_q == 1'b1 && bclk_tick_i == 1'b1;

    always_comb begin
        uart_tx_fsm_state_d = uart_tx_fsm_state_q;

        uart_tx_tick_cnt_ena = 1'b1;
        uart_tx_bit_cnt_ena  = 1'b0;

        case(uart_tx_fsm_state_q)

            S_TX_IDLE: begin
                uart_tx_tick_cnt_ena = 1'b0;
                if(uart_tx_data_rdy_i == 1'b1) uart_tx_fsm_state_d = S_TX_START;
                if(uart_tx_en_i == 1'b0) uart_tx_fsm_state_d = S_TX_IDLE;
            end

            S_TX_START: begin
                if(bit_tick == 1'b1) begin
                    uart_tx_fsm_state_d = S_TX_DATA;
                end
            end

            S_TX_DATA: begin
                uart_tx_bit_cnt_ena = 1'b1;

                if(bit_tick == 1'b1 && uart_tx_bit_cnt_q == {2'b01, lcr_wlen_i}) begin
                    uart_tx_fsm_state_d = S_TX_PAR;
                end

                if(uart_tx_fsm_state_d == S_TX_PAR && lcr_pen_i == 1'b0) begin
                    uart_tx_fsm_state_d = S_TX_STOP;
                end
            end

            S_TX_PAR: begin
                if(bit_tick == 1'b1) begin
                    uart_tx_fsm_state_d = S_TX_STOP;
                end
            end

            S_TX_STOP: begin
                if(bit_tick == 1'b1) begin
                    uart_tx_fsm_state_d = S_TX_IDLE;
                    if(lcr_stp2_i == 1'b1 && stp2_q == 1'b0) begin
                        uart_tx_fsm_state_d = S_TX_STOP;
                    end
                end
            end

            default: begin
                uart_tx_fsm_state_d = S_TX_IDLE;
            end

        endcase
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) uart_tx_fsm_state_q <= S_TX_IDLE;
        else uart_tx_fsm_state_q <= uart_tx_fsm_state_d;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) stp2_q <= 1'b0;
        else begin
            if(bit_tick == 1'b1 && uart_tx_fsm_state_q == S_TX_STOP && lcr_stp2_i == 1'b1) begin
                stp2_q <= ~stp2_q;
            end
        end
    end


    /*
     * UART BAUD TICK COUNTER LOGIC
     */

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) uart_tx_tick_cnt_q <= 4'h0;
        else begin
            if(bclk_tick_i == 1'b1 && uart_tx_tick_cnt_ena == 1'b1) begin
                uart_tx_tick_cnt_q <= uart_tx_tick_cnt_q + 4'h1;
            end
        end
    end


    /*
     * UART DATA BIT COUNTER LOGIC
     */

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) uart_tx_bit_cnt_q <= 4'h0;
        else begin
            if(bit_tick == 1'b1 && uart_tx_bit_cnt_ena == 1'b1) begin
                uart_tx_bit_cnt_q <= uart_tx_bit_cnt_q + 4'h1;
            end
            if(uart_tx_fsm_state_d == S_TX_STOP) begin
                uart_tx_bit_cnt_q <= 4'h0;
            end
        end
    end


    /*
     * UART TX DATA REGISTER LOGIC
     */

    logic [7:0] uart_tx_data_q;
    logic       uart_tx_data_par_q;

    always_ff @(posedge clk_i) begin
        case(uart_tx_fsm_state_q)
            S_TX_START: begin
                if(bit_tick == 1'b1) begin
                    uart_tx_data_q     <= uart_tx_data_i;
                    uart_tx_data_par_q <= lcr_eps_i == 1'b1 ? ~^uart_tx_data_i : ^uart_tx_data_i;
                end
            end
            S_TX_DATA: begin
                if(bit_tick == 1'b1) begin
                    uart_tx_data_q <= uart_tx_data_q >> 1;
                end
            end
        endcase
    end

    assign uart_tx_data_ack_o = bit_tick == 1'b1 && uart_tx_fsm_state_q == S_TX_START;


    /*
     * UART TX DATA LOGIC
     */

    always_comb begin
        uart_tx_o = 1'b1;

        case(uart_tx_fsm_state_q)
            S_TX_START: uart_tx_o = 1'b0;
            S_TX_DATA:  uart_tx_o = uart_tx_data_q[0];
            S_TX_PAR:   uart_tx_o = uart_tx_data_par_q;
            S_TX_STOP:  uart_tx_o = 1'b1;
        endcase

        if(lcr_brk_i == 1'b1) uart_tx_o = 1'b0;
    end

endmodule : uart_tx
