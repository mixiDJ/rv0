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
// Name: sideband_uvc_driver.sv
// Auth: Nikola Lukić
// Date: 03.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef SIDEBAND_UVC_DRIVER_SV
`define SIDEBAND_UVC_DRIVER_SV

class sideband_uvc_driver extends uvm_driver#(sideband_uvc_item);

    typedef virtual sideband_uvc_if     vif_t;
    typedef sideband_uvc_agent_cfg      cfg_t;

    /* DRIVER CONFIG REF */
    cfg_t m_cfg;

    /* DRIVER VIRTUAL INTERFACE */
    vif_t m_vif;

    /* DRIVER SEQUENCE ITEM */
    REQ m_req;

    /* REGISTRATION MACRO */
    `uvm_component_utils(sideband_uvc_driver)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    /* METHODS */

endclass : sideband_uvc_driver

function void sideband_uvc_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase

task sideband_uvc_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask : run_phase

`endif // SIDEBAND_UVC_DRIVER_SV
