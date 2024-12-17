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
// Name: spi_uvc_sequencer.sv
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

`ifndef SPI_UVC_SEQUENCER_SV
`define SPI_UVC_SEQUENCER_SV

class spi_uvc_sequencer extends uvm_sequencer;

    typedef spi_uvc_agent_cfg   cfg_t;

    /* SEQUENCER CONFIG OBJECT */
    cfg_t m_cfg;

    /* REGISTRATION MACRO */
    `uvm_component_utils(spi_uvc_sequencer)
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void build_phase(uvm_phase phase);

endclass : spi_uvc_sequencer

function void spi_uvc_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

endfunction : build_phase

`endif // SPI_UVC_SEQUENCER_SV
