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
// Name: ahb_uvc_pkg.sv
// Auth: Nikola Lukić
// Date: 29.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef AHB_UVC_PKG_SV
`define AHB_UVC_PKG_SV

`timescale 1ns/1ps
package ahb_uvc_pkg;

`include "uvm_macros.svh"
`include "uvm_utils.svh"
import uvm_pkg::*;

`include "ahb_uvc_common.sv"
`include "ahb_uvc_item.sv"
`include "ahb_uvc_agent_cfg.sv"
`include "ahb_uvc_master_driver.sv"
`include "ahb_uvc_slave_driver.sv"
`include "ahb_uvc_monitor.sv"
`include "ahb_uvc_sequencer.sv"
`include "ahb_uvc_seq_lib.sv"
`include "ahb_uvc_master_agent.sv"
`include "ahb_uvc_slave_agent.sv"
`include "ahb_uvc_cfg.sv"
`include "ahb_uvc_env.sv"

endpackage : ahb_uvc_pkg

`include "ahb_uvc_if.sv"

`endif // AHB_UVC_PKG_SV
