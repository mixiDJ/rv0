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
// Name: uart_apb_tb_top.sv
// Auth: Nikola Lukić
// Date: 24.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_APB_TB_TOP_SV
`define UART_APB_TB_TOP_SV

module uart_apb_tb_top;

    localparam int unsigned ADDR_WIDTH      = 32;
    localparam int unsigned DATA_WIDTH      = 32;
    localparam int unsigned USER_REQ_WIDTH  = 0;
    localparam int unsigned USER_DATA_WIDTH = 0;
    localparam int unsigned USER_RESP_WIDTH = 0;

    `include "uvm_macros.svh"
    `include "uvm_utils.svh"
    import uvm_pkg::*;

    `include "clk_uvc_pkg.sv"
    import clk_uvc_pkg::*;
    `include "apb_uvc_pkg.sv"
    import apb_uvc_pkg::*;
    `include "uart_uvc_pkg.sv"
    import uart_uvc_pkg::*;

    `include "uart_apb_test_pkg.sv"
    import uart_apb_test_pkg::*;

    clk_uvc_if
    clk_if ();

    apb_uvc_if #(`APB_UVC_PARAM_LST)
    apb_if (clk_if.clk, clk_if.rst_n);

    uart_uvc_if
    uart_if ();

    uart_apb_top #(`APB_UVC_PARAM_LST)
    DUT (
        .pclk_i         (apb_if.pclk    ),
        .prst_ni        (apb_if.prst_n  ),
        .paddr_i        (apb_if.paddr   ),
        .pprot_i        (apb_if.pprot   ),
        .pnse_i         (apb_if.pnse    ),
        .psel_i         (apb_if.psel    ),
        .penable_i      (apb_if.penable ),
        .pwrite_i       (apb_if.pwrite  ),
        .pwdata_i       (apb_if.pwdata  ),
        .pstrb_i        (apb_if.pstrb   ),
        .pready_o       (apb_if.pready  ),
        .prdata_o       (apb_if.prdata  ),
        .pslverr_o      (apb_if.pslverr ),
        .pwakeup_i      (apb_if.pwakeup ),
        .pauser_i       (apb_if.pauser  ),
        .pwuser_i       (apb_if.pwuser  ),
        .pruser_o       (apb_if.pruser  ),
        .pbuser_o       (apb_if.pbuser  ),
        .irq_o          (               ),
        .uart_rx_i      (uart_if.tx     ),
        .uart_tx_o      (uart_if.rx     ),
        .uart_ri_ni     (1              ),
        .uart_cts_ni    (1              ),
        .uart_dsr_ni    (1              ),
        .uart_dcd_ni    (1              ),
        .uart_dtr_no    (               ),
        .uart_rts_no    (               ),
        .uart_out1_no   (               ),
        .uart_out2_no   (               )
    );

    initial begin : tb_top_vif_config_blk

        `uvm_config_db_set(
            virtual clk_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_clk_env.m_agent_0",
            "m_vif",
            clk_if
        )

        `uvm_config_db_set(
            virtual apb_uvc_if#(`APB_UVC_PARAM_LST),
            uvm_root::get(),
            "uvm_test_top.m_env.m_apb_env.m_master_agent",
            "m_vif",
            apb_if
        )

        `uvm_config_db_set(
            virtual uart_uvc_if,
            uvm_root::get(),
            "uvm_test_top.m_env.m_uart_env.m_agent",
            "m_vif",
            uart_if
        )

    end // tb_top_vif_config_blk

    initial begin : tb_top_run_test_blk
        run_test();
    end // tb_top_run_test_blk

endmodule : uart_apb_tb_top

`endif // UART_APB_TB_TOP_SV
