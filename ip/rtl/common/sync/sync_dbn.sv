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
// Name: sync_dbn.sv
// Auth: Nikola Lukić
// Date: 08.09.2024.
// Desc: Configurable width debouncer
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module sync_dbn #(
    parameter int unsigned           DATA_WIDTH = 1,
    parameter int unsigned           SYNC_DEPTH = 2,
    parameter int unsigned           DBN_WIDTH  = 4,
    parameter logic [DATA_WIDTH-1:0] RST_VAL    = {DATA_WIDTH{1'b0}}
) (

    input  logic                    clk_i,
    input  logic                    rst_ni,

    input  logic [DATA_WIDTH-1:0]   sig_i,
    output logic [DATA_WIDTH-1:0]   sig_dbn_o,

    // signal positive edge
    output logic                    sig_pe_o,
    // signal negative edge
    output logic                    sig_ne_o,
    // signal any edge
    output logic                    sig_ae_o

);

    /*
     * INPUT SYNCHRONIZER
     */

    logic [DATA_WIDTH-1:0] sig_sync_d;
    logic [DATA_WIDTH-1:0] sig_sync_q;

    sync #(
        .SYNC_DEPTH (SYNC_DEPTH     ),
        .DATA_WIDTH (DATA_WIDTH     ),
        .RST_VAL    (RST_VAL        )
    )
    u_dbn_sync (
        .clk_i      (clk_i          ),
        .rst_ni     (rst_ni         ),
        .sig_i      (sig_i          ),
        .sig_sync_o (sig_sync_d     )
    );

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) sig_sync_q <= RST_VAL;
        else sig_sync_q <= sig_sync_d;
    end


    /*
     * DEBOUNCE COUNTER LOGIC
     */

    logic [DBN_WIDTH-1:0] dbn_cnt_q;
    logic [DBN_WIDTH-1:0] dbn_cnt_d;

    logic dbn_stable;
    assign dbn_stable = &dbn_cnt_q;

    always_comb begin
        dbn_cnt_d = dbn_cnt_q;

        // debouncer is still not in stable state, increment counter
        if(dbn_stable == 1'b0) begin
            dbn_cnt_d = dbn_cnt_q + {{DBN_WIDTH-1{1'b0}}, 1'b1};
        end

        // new synchronized value differs from value currently in
        // sig_sync_q register, which means synchronized
        // input signal changed from previous clock edge
        if(sig_sync_d != sig_sync_q) begin
            dbn_cnt_d = {DBN_WIDTH{1'b0}};
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) dbn_cnt_q <= {DBN_WIDTH{1'b0}};
        else dbn_cnt_q <= dbn_cnt_d;
    end


    /*
     * DEBOUNCE DATA LOGIC
     */

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) sig_dbn_o <= RST_VAL;
        else if(dbn_stable) sig_dbn_o <= sig_sync_q;
    end


    /*
     * EDGE DETECTOR LOGIC
     */

    logic sig_pe_d;

    always_comb begin
        sig_pe_d = 1'b0;
        for(int i = 0; i < DATA_WIDTH; ++i) begin
            if(dbn_stable == 1'b1 && sig_dbn_o[i] == 1'b0 && sig_sync_q[i] == 1'b1) begin
                sig_pe_d = 1'b1;
            end
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) sig_pe_o <= 1'b0;
        else sig_pe_o <= sig_pe_d;
    end

    logic sig_ne_d;

    always_comb begin
        sig_ne_d = 1'b0;
        for(int i = 0; i < DATA_WIDTH; ++i) begin
            if(dbn_stable == 1'b1 && sig_dbn_o[i] == 1'b1 && sig_sync_q[i] == 1'b0) begin
                sig_ne_d = 1'b1;
            end
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) sig_ne_o <= 1'b0;
        else sig_ne_o <= sig_ne_d;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) sig_ae_o <= 1'b0;
        else sig_ae_o <= sig_pe_d || sig_ne_d;
    end

endmodule : sync_dbn
