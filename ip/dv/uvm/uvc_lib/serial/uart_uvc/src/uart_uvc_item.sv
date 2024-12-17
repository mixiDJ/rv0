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
// Name: uart_uvc_item.sv
// Auth: Nikola Lukić
// Date: 08.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef UART_UVC_ITEM_SV
`define UART_UVC_ITEM_SV

class uart_uvc_item extends uvm_sequence_item;

    /* ITEM FIELDS */
    bit [7:0] uart_data;
    rand bit [11:0] uart_frame;

    /* REGISTRATION MACRO */
    `uvm_object_utils_begin(uart_uvc_item)
        `uvm_field_int(uart_data,  UVM_DEFAULT)
        `uvm_field_int(uart_frame, UVM_DEFAULT | UVM_BIN)
    `uvm_object_utils_end
    `uvm_object_new

    /* METHODS */
    extern function bit         get_start_bit();
    extern function void        set_start_bit(bit start_bit=1'b0);

    extern function bit [7:0]   get_data_bits(uint len=0);
    extern function void        set_data_bits(bit [7:0] data_bits);

    extern function bit         get_par_bit();
    extern function void        set_par_bit(bit par_bit);

    extern function bit [1:0]   get_stop_bits();
    extern function void        set_stop_bits(bit [1:0] stop_bits=2'b11);

    extern function bit         get_data_par();

    /* LOCAL METHODS */
    extern local function uint  get_par_bit_idx();

endclass : uart_uvc_item

function bit uart_uvc_item::get_start_bit();
    return uart_frame[0];
endfunction : get_start_bit

function void uart_uvc_item::set_start_bit(bit start_bit=1'b0);
    uart_frame[0] = start_bit;
endfunction : set_start_bit

function bit [7:0] uart_uvc_item::get_data_bits(uint len=0);
    bit [7:0] data_bits;

    if(len == 0) begin
        uart_uvc_sequencer seqr;
        $cast(seqr, get_sequencer());
        len = seqr.m_cfg.data_bits;
    end

    for(uint i = 0; i < len; ++i) data_bits[i] = uart_frame[i + 1];
    return data_bits;
endfunction : get_data_bits

function void uart_uvc_item::set_data_bits(bit [7:0] data_bits);
    uart_uvc_sequencer seqr;
    $cast(seqr, get_sequencer());
    for(uint i = 0; i < seqr.m_cfg.data_bits; ++i) begin
        uart_frame[i + 1] = data_bits[i];
    end
endfunction : set_data_bits

function bit uart_uvc_item::get_par_bit();
    return uart_frame[get_par_bit_idx()];
endfunction : get_par_bit

function void uart_uvc_item::set_par_bit(bit par_bit);
    uart_frame[get_par_bit_idx()] = par_bit;
endfunction : set_par_bit

function void uart_uvc_item::set_stop_bits(bit [1:0] stop_bits=2'b11);
    uart_uvc_sequencer seqr;
    $cast(seqr, get_sequencer());
    for(uint i = 0; i < seqr.m_cfg.stop_bits; ++i) begin
        uart_frame[seqr.m_cfg.data_bits + seqr.m_cfg.par_bit + i + 1] = stop_bits[i];
    end
endfunction : set_stop_bits

function bit [1:0] uart_uvc_item::get_stop_bits();
    uart_uvc_sequencer seqr;
    bit [1:0] stop_bits;
    $cast(seqr, get_sequencer());
    for(uint i = 0; i < seqr.m_cfg.stop_bits; ++i) begin
        stop_bits[i] = uart_frame[seqr.m_cfg.data_bits + i + 1];
    end
    return stop_bits;
endfunction : get_stop_bits

function uint uart_uvc_item::get_par_bit_idx();
    uart_uvc_sequencer seqr;
    $cast(seqr, get_sequencer());
    return seqr.m_cfg.get_frame_size() - seqr.m_cfg.stop_bits - 1;
endfunction : get_par_bit_idx

function bit uart_uvc_item::get_data_par();
    uart_uvc_sequencer seqr;
    bit par = 1'b0;

    $cast(seqr, get_sequencer());

    for(uint i = 0; i < seqr.m_cfg.data_bits; ++i) begin
        par ^= uart_frame[i+1];
    end

    return seqr.m_cfg.par_typ == PAR_TYP_EVEN ? par : ~par;

endfunction : get_data_par

`endif // UART_UVC_ITEM_SV
