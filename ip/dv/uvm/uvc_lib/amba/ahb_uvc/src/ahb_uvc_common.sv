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
// Name: ahb_uvc_common.sv
// Auth: Nikola Lukić
// Date: 28.09.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef AHB_UVC_COMMON_SV
`define AHB_UVC_COMMON_SV

`define AHB_UVC_PARAM_LST                                                                           \
    parameter  int unsigned ADDR_WIDTH      = 32,                                                   \
    parameter  int unsigned DATA_WIDTH      = 32,                                                   \
    parameter  int unsigned HBURST_WIDTH    = 4,                                                    \
    parameter  int unsigned HPROT_WIDTH     = 4,                                                    \
    parameter  int unsigned HMASTER_WIDTH   = 1,                                                    \
    parameter  int unsigned USER_REQ_WIDTH  = 1,                                                    \
    parameter  int unsigned USER_DATA_WIDTH = 1,                                                    \
    parameter  int unsigned USER_RESP_WIDTH = 1,                                                    \
    localparam int unsigned STRB_WIDTH = DATA_WIDTH / 8

`define AHB_UVC_PARAMS                                                                              \
    .ADDR_WIDTH         (ADDR_WIDTH         ),                                                      \
    .DATA_WIDTH         (DATA_WIDTH         ),                                                      \
    .HBURST_WIDTH       (HBURST_WIDTH       ),                                                      \
    .HPROT_WIDTH        (HPROT_WIDTH        ),                                                      \
    .HMASTER_WIDTH      (HMASTER_WIDTH      ),                                                      \
    .USER_REQ_WIDTH     (USER_REQ_WIDTH     ),                                                      \
    .USER_DATA_WIDTH    (USER_DATA_WIDTH    ),                                                      \
    .USER_RESP_WIDTH    (USER_RESP_WIDTH    )

typedef enum bit [1:0] {
    HTRANS_IDLE,
    HTRANS_BUSY,
    HTRANS_NONSEQ,
    HTRANS_SEQ
} ahb_uvc_htrans_e;

typedef enum bit [2:0] {
    HSIZE_BYTE,     // 8 bits
    HSIZE_HALF,     // 16 bits
    HSIZE_WORD,     // 32 bits
    HSIZE_DOUBLE,   // 64 bits
    HSIZE_4WL,      // 4-word line
    HSIZE_8WL,      // 8-word line
    HSIZE_16WL,     // 16-word line
    HSIZE_32WL      // 32-word line
} ahb_uvc_hsize_e;

typedef enum bit [2:0] {
    HBURST_SINGLE,
    HBURST_INCR,
    HBURST_WRAP4,
    HBURST_INCR4,
    HBURST_WRAP8,
    HBURST_INCR8,
    HBURST_WRAP16,
    HBURST_INCR16
} ahb_uvc_hburst_e;

`ifndef HBURST_WRAP
`define HBURST_WRAP(__hburst) \
    ((__hburst) inside {HBURST_WRAP4, HBURST_WRAP8, HBURST_WRAP16})
`endif // HBURST_WRAP

`ifndef HBURST_INCR
`define HBURST_INCR(__hburst) \
    ((__hburst) inside {HBURST_INCR4, HBURST_INCR8, HBURST_INCR16})
`endif // HBURST_INCR

typedef enum bit {
    HRESP_OKAY,
    HRESP_ERROR
} ahb_uvc_hresp_e;

`ifndef HSIZE_BITS
`define HSIZE_BITS(__hsize)                     \
    (                                           \
        ((__hsize) == HSIZE_BYTE)   ? 8    :    \
        ((__hsize) == HSIZE_HALF)   ? 16   :    \
        ((__hsize) == HSIZE_WORD)   ? 32   :    \
        ((__hsize) == HSIZE_DOUBLE) ? 64   :    \
        ((__hsize) == HSIZE_4WL)    ? 128  :    \
        ((__hsize) == HSIZE_8WL)    ? 256  :    \
        ((__hsize) == HSIZE_16WL)   ? 512  :    \
        ((__hsize) == HSIZE_32WL)   ? 1024 :    \
        0                                       \
    )
`endif // HSIZE_BITS

`ifndef HBURST_SIZE
`define HBURST_SIZE(__hburst)                   \
    (                                           \
        ((__hburst) == HBURST_SINGLE) ? 1  :    \
        ((__hburst) == HBURST_WRAP4)  ? 4  :    \
        ((__hburst) == HBURST_INCR4)  ? 4  :    \
        ((__hburst) == HBURST_WRAP8)  ? 8  :    \
        ((__hburst) == HBURST_INCR8)  ? 8  :    \
        ((__hburst) == HBURST_WRAP16) ? 16 :    \
        ((__hburst) == HBURST_INCR16) ? 16 :    \
        0                                       \
    )
`endif // HBURST_SIZE

`ifndef BURST_ADDRESS_BOUNDARY_SIZE
`define BURST_ADDRESS_BOUNDARY_SIZE(__hsize, __hburst) \
    (`HSIZE_BITS(__hsize) * `HBURST_SIZE(__hburst))
`endif // BURST_ADDRESS_BOUNDARY_SIZE

`ifndef BURST_ADDRESS_BOUNDARY_MASK
`define BURST_ADDRESS_BOUNDARY_MASK(__hsize, __hburst, __addr_width) \
    ((~{__addr_width{1'b0}}) << $clog2(`BURST_ADDRESS_BOUNDARY_SIZE(__hsize, __hburst)))
`endif // BURST_ADDRESS_MASK

`endif // AHB_UVC_COMMON_SV
