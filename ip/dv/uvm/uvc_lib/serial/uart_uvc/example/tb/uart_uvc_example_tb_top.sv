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
// Name: uart_uvc_example_tb_top.sv
// Auth: Nikola Lukić
// Date: 22.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_UVC_EXAMPLE_TB_TOP_SV
`define UART_UVC_EXAMPLE_TB_TOP_SV

module uart_uvc_example_tb_top;

    `include "uvm_macros.svh"
    `include "uvm_utils.svh"
    import uvm_pkg::*;

    `include "uart_uvc_example_test_pkg.sv"
    import uart_uvc_example_test_pkg::*;

    uart_uvc_if uart_if[2]();

    assign uart_if[0].rx = uart_if[1].tx;
    assign uart_if[1].rx = uart_if[0].tx;

    initial begin : tb_top_vif_config_blk

        `uvm_config_db_set(
            virtual uart_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_uart_env_0.m_agent",
            "m_vif",
            uart_if[0]
        )

        `uvm_config_db_set(
            virtual uart_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_uart_env_1.m_agent",
            "m_vif",
            uart_if[1]
        )

    end // tb_top_vif_config_blk

    initial begin : tb_top_run_test_blk
        run_test();
    end // tb_top_run_test_blk

endmodule : uart_uvc_example_tb_top

`endif // UART_UVC_EXAMPLE_TB_TOP_SV
