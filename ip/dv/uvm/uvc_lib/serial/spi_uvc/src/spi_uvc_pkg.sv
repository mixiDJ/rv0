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
// Name: spi_uvc_pkg.sv
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

`ifndef SPI_UVC_PKG_SV
`define SPI_UVC_PKG_SV

package spi_uvc_pkg;

`include "uvm_macros.svh"
`include "uvm_utils.svh"
import uvm_pkg::*;

`include "spi_uvc_common.sv"
`include "spi_uvc_item.sv"
`include "spi_uvc_agent_cfg.sv"
`include "spi_uvc_driver.sv"
`include "spi_uvc_monitor.sv"
`include "spi_uvc_sequencer.sv"
`include "spi_uvc_agent.sv"
`include "spi_uvc_seq_lib.sv"
`include "spi_uvc_cfg.sv"
`include "spi_uvc_env.sv"

endpackage : spi_uvc_pkg

`endif // SPI_UVC_PKG_SV
