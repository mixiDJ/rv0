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
// Name: sync_pulse.sv
// Auth: Nikola Lukić
// Date: 15.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module sync_pulse #(
    parameter int unsigned  PULSE_WIDTH = 1,
    parameter int unsigned  SYNC_DEPTH  = 2,
    parameter logic         RST_VAL     = 1'b0
) (

    input  logic    clk_i,
    input  logic    rst_ni,

    input  logic    sig_i,
    output logic    sync_o

);

    /*
     * INPUT SIGNAL SYNCRHONIZATION
     */

    logic sig_sync_d;

    sync #(
        .SYNC_DEPTH (SYNC_DEPTH ),
        .RST_VAL    (RST_VAL    )
    )
    u_sync (
        .clk_i      (clk_i      ),
        .rst_ni     (rst_ni     ),
        .sig_i      (sig_i      ),
        .sync_o     (sig_sync_d )
    );


    /*
     * SYNCRHONIZED SIGNAL POSITIVE EDGE DETECTOR
     */

    logic sig_sync_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(rst_ni == 1'b0) sig_sync_q <= RST_VAL;
        else sig_sync_q <= sig_sync_d;
    end

    logic sig_sync_pe;
    assign sig_sync_pe = sig_sync_d == 1'b1 && sig_sync_q == 1'b0;


    /*
     * PULSE WIDTH CONTROL
     */

    if(PULSE_WIDTH > 1) begin

        logic [PULSE_WIDTH-2:0] sig_pulse_q;

        always_ff @(posedge clk_i or negedge rst_ni) begin
            if(rst_ni == 1'b0) sig_pulse_q <= {PULSE_WIDTH{RST_VAL}};
            else begin
                sig_pulse_q <= sig_pulse_q << 1;
                sig_pulse_q[0] <= sig_sync_pe;
            end
        end

        assign sync_o = |sig_pulse_q || sig_sync_pe;

    end
    else begin
        assign sync_o = sig_sync_pe;
    end

endmodule : sync_pulse
