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
// Name: uart_rx.sv
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

module uart_rx (

    input  logic            clk_i,
    input  logic            rst_ni,

    input  logic            uart_rx_en_i,

    input  logic            bclk_tick_i,

    input  logic            lcr_sps_i,
    input  logic [ 1:0]     lcr_wlen_i,
    input  logic            lcr_fen_i,
    input  logic            lcr_stp2_i,
    input  logic            lcr_eps_i,
    input  logic            lcr_pen_i,
    input  logic            lcr_brk_i,

    output logic [11:0]     uart_rx_data_o,
    output logic            uart_rx_data_rdy_o,

    input  logic            uart_rx_i

);

    logic [3:0] uart_rx_bit_cnt_q;
    logic       uart_rx_bit_cnt_ena;

    logic [3:0] uart_rx_tick_cnt_q;
    logic       uart_rx_tick_cnt_ena;

    /*
     * UART RX SYNCHRONIZATION
     */

    sync #(.RST_VAL(1'b1))
    u_rx_sync (
        .clk_i  (clk_i          ),
        .rst_ni (rst_ni         ),
        .sig_i  (uart_rx_i      ),
        .sync_o (uart_rx_sync   )
    );


    /*
     * UART RX CTRL FSM
     */

    typedef enum bit[4:0] {
        S_RX_IDLE  = 5'b00001,
        S_RX_START = 5'b00010,
        S_RX_DATA  = 5'b00100,
        S_RX_PAR   = 5'b01000,
        S_RX_STOP  = 5'b10000
    } uart_rx_fsm_state_e;

    uart_rx_fsm_state_e uart_rx_fsm_state_q;
    uart_rx_fsm_state_e uart_rx_fsm_state_d;

    logic stp2_q;

    logic bit_tick;
    assign bit_tick = &uart_rx_tick_cnt_q == 1'b1 && bclk_tick_i == 1'b1;

    always_comb begin
        uart_rx_fsm_state_d = uart_rx_fsm_state_q;

        uart_rx_tick_cnt_ena = 1'b1;
        uart_rx_bit_cnt_ena  = 1'b0;

        case(uart_rx_fsm_state_q)

            S_RX_IDLE: begin
                uart_rx_tick_cnt_ena = 1'b0;
                if(uart_rx_sync == 1'b0) uart_rx_fsm_state_d = S_RX_START;
                if(uart_rx_en_i == 1'b0) uart_rx_fsm_state_d = S_RX_IDLE;
            end

            S_RX_START: begin
                if(bit_tick == 1'b1) begin
                    uart_rx_fsm_state_d = S_RX_DATA;
                end
            end

            S_RX_DATA: begin
                uart_rx_bit_cnt_ena  = 1'b1;

                if(bit_tick == 1'b1 && uart_rx_bit_cnt_q == {2'b01, lcr_wlen_i}) begin
                    uart_rx_fsm_state_d = S_RX_PAR;
                end

                if(uart_rx_fsm_state_d == S_RX_PAR && lcr_pen_i == 1'b0) begin
                    uart_rx_fsm_state_d = S_RX_STOP;
                end
            end

            S_RX_PAR: begin
                if(bit_tick == 1'b1) begin
                    uart_rx_fsm_state_d = S_RX_STOP;
                end
            end

            S_RX_STOP: begin
                if(bit_tick == 1'b1) begin
                    uart_rx_fsm_state_d = S_RX_IDLE;
                    if(lcr_stp2_i == 1'b1 && stp2_q == 1'b0) begin
                        uart_rx_fsm_state_d = S_RX_STOP;
                    end
                end
            end

            default: begin
                uart_rx_fsm_state_d = S_RX_IDLE;
            end

        endcase

    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) uart_rx_fsm_state_q <= S_RX_IDLE;
        else uart_rx_fsm_state_q <= uart_rx_fsm_state_d;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) stp2_q <= 1'b0;
        else begin
            if(bit_tick == 1'b1 && uart_rx_fsm_state_q == S_RX_STOP && lcr_stp2_i == 1'b1)  begin
                stp2_q <= ~stp2_q;
            end
        end
    end


    /*
     * UART BAUD TICK COUNTER LOGIC
     */

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) uart_rx_tick_cnt_q <= 4'h0;
        else begin
            if(bclk_tick_i == 1'b1 && uart_rx_tick_cnt_ena == 1'b1) begin
                uart_rx_tick_cnt_q <= uart_rx_tick_cnt_q + 4'h1;
            end
        end
    end


    /*
     * UART DATA BIT COUNTER LOGIC
     */

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) uart_rx_bit_cnt_q <= 4'h0;
        else begin
            if(bit_tick == 1'b1 && uart_rx_bit_cnt_ena == 1'b1) begin
                uart_rx_bit_cnt_q <= uart_rx_bit_cnt_q + 4'h1;
            end
            if(uart_rx_fsm_state_d == S_RX_STOP) begin
                uart_rx_bit_cnt_q <= 4'h0;
            end
        end
    end


    /*
     * UART DATA OVERSAMPLING LOGIC
     */

    // UART bits are oversampled by sampling each bit 3 times, then taking the majority vote.
    // 16x clock is used for reason, along with a 5 bit counter that determines sampling times.
    // Each bit is sampled on counter values 6, 8 and 10, where counting starts at the falling edge
    // of UART Rx signal.

    logic [2:0] uart_rx_os_data_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) uart_rx_os_data_q <= 3'b111;
        else if(bclk_tick_i == 1'b1) begin
            case(uart_rx_tick_cnt_q)
                5'd5: uart_rx_os_data_q[0] <= uart_rx_sync;
                5'd7: uart_rx_os_data_q[1] <= uart_rx_sync;
                5'd9: uart_rx_os_data_q[2] <= uart_rx_sync;
            endcase
        end
    end


    /*
     * UART OVERSAMPLED DATA MAJORITY VOTE LOGIC
     */

    logic uart_rx_bit_data;
    assign uart_rx_bit_data =
        uart_rx_os_data_q[0] == 1'b1 && uart_rx_os_data_q[1] == 1'b1 ||
        uart_rx_os_data_q[0] == 1'b1 && uart_rx_os_data_q[2] == 1'b1 ||
        uart_rx_os_data_q[1] == 1'b1 && uart_rx_os_data_q[2] == 1'b1;

    /*
     * UART DATA SHIFT REGISTER
     */

    logic [7:0] uart_rx_data_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) uart_rx_data_q <= 12'h0;
        else begin
            if(bit_tick == 1'b1 && uart_rx_fsm_state_q == S_RX_DATA) begin
                uart_rx_data_q <= {uart_rx_bit_data,uart_rx_data_q[7:1]};
            end
            if(uart_rx_fsm_state_q == S_RX_START) begin
                uart_rx_data_q <= 8'h0;
            end
        end
    end


    /*
     * OUTPUT DATA LOGIC
     */

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) begin
            uart_rx_data_rdy_o <= 1'b0;
            uart_rx_data_o     <= 12'h0;
        end
        else begin
            uart_rx_data_rdy_o <= 1'b1;

            if(uart_rx_fsm_state_q == S_RX_STOP && uart_rx_fsm_state_d == S_RX_IDLE) begin

                // TODO: add error flags

                case(lcr_wlen_i)
                    2'b00: uart_rx_data_o <= {3'b0, uart_rx_data_q[7:3]};
                    2'b01: uart_rx_data_o <= {2'b0, uart_rx_data_q[7:2]};
                    2'b10: uart_rx_data_o <= {1'b0, uart_rx_data_q[7:1]};
                    2'b11: uart_rx_data_o <= uart_rx_data_q;
                endcase

            end
            else uart_rx_data_rdy_o <= 1'b0;
        end
    end

endmodule : uart_rx
