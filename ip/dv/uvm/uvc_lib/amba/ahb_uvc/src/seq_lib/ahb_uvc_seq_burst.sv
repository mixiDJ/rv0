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
// Name: ahb_uvc_seq_burst.sv
// Auth: Nikola Lukić
// Date: 05.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef AHB_UVC_SEQ_BURST_SV
`define AHB_UVC_SEQ_BURST_SV

class ahb_uvc_seq_burst #(`AHB_UVC_PARAM_LST) extends uvm_sequence#(ahb_uvc_seq_base#(`AHB_UVC_PARAMS));

    typedef bit [ADDR_WIDTH-1:0]                    haddr_t;
    typedef bit [HBURST_WIDTH-1:0]                  hburst_t;
    typedef bit [HPROT_WIDTH-1:0]                   hprot_t;
    typedef bit [2:0]                               hsize_t;
    typedef bit [HMASTER_WIDTH-1:0]                 hmaster_t;
    typedef bit [1:0]                               htrans_t;
    typedef bit [DATA_WIDTH-1:0]                    hwdata_t;
    typedef bit [STRB_WIDTH-1:0]                    hwstrb_t;
    typedef bit [DATA_WIDTH-1:0]                    hrdata_t;
    typedef bit [USER_REQ_WIDTH-1:0]                hauser_t;
    typedef bit [USER_DATA_WIDTH-1:0]               hwuser_t;
    typedef bit [USER_DATA_WIDTH-1:0]               hruser_t;
    typedef bit [USER_RESP_WIDTH-1:0]               hbuser_t;
    typedef ahb_uvc_seq_base#(`AHB_UVC_PARAMS)   seq_base_t;

    /* SEQUENCE FIELDS */
    rand int            burst_len;

    rand haddr_t        haddr [$];
    rand hburst_t       hburst;
    rand bit            hmastlock [$];
    rand hprot_t        hprot;
    rand hsize_t        hsize;
    rand bit            hnonsec;
    rand hmaster_t      hmaster;
    rand hwdata_t       hwdata [$];
    rand hwstrb_t       hwstrb [$];
    rand bit            hwrite [$];
    rand bit            hsel;
    rand hauser_t       hauser [$];
    rand hwuser_t       hwuser [$];
    rand dly_typ_e      req_dly_typ [$];
    rand int            req_dly [$];

    /* SEQUENCE CONSTRAINTS */
    constraint c_burst_len {
        solve hburst before burst_len;

        (hburst == HBURST_SINGLE) -> burst_len == 1;
        (hburst == HBURST_WRAP4 ) -> burst_len == 4;
        (hburst == HBURST_INCR4 ) -> burst_len == 4;
        (hburst == HBURST_WRAP8 ) -> burst_len == 8;
        (hburst == HBURST_INCR8 ) -> burst_len == 8;
        (hburst == HBURST_WRAP16) -> burst_len == 16;
        (hburst == HBURST_INCR16) -> burst_len == 16;

        soft burst_len <= 16; burst_len > 1;
        soft $onehot(burst_len);
    }

    constraint c_haddr {
        solve burst_len before haddr;
        solve hsize before haddr;
        haddr.size() == burst_len;

        // TODO: add wrap burst
        foreach(haddr[i]) {
            (i > 0 && hsize == HSIZE_BYTE)   -> soft haddr[i] == haddr[i-1] + 'h1;
            (i > 0 && hsize == HSIZE_HALF)   -> soft haddr[i] == haddr[i-1] + 'h2;
            (i > 0 && hsize == HSIZE_WORD)   -> soft haddr[i] == haddr[i-1] + 'h4;
            (i > 0 && hsize == HSIZE_DOUBLE) -> soft haddr[i] == haddr[i-1] + 'h8;
        }
    }

    constraint c_hmastlock {
        solve burst_len before hmastlock;
        hmastlock.size() == burst_len;
        foreach(hmastlock[i]) { soft hmastlock[i] == hmastlock[0]; }
    }

    constraint c_hwdata {
        solve burst_len before hwdata;
        hwdata.size() == burst_len;
    }

    constraint c_hwstrb {
        solve burst_len before hwstrb;
        solve hwrite before hwstrb;
        hwstrb.size() == burst_len;
        foreach(hwstrb[i]) { hwrite[i] == 1'b0 -> soft hwstrb[i] == {STRB_WIDTH{1'b0}}; }
    }

    constraint c_hwrite {
        solve burst_len before hwrite;
        hwrite.size() == burst_len;
        foreach(hwrite[i]) { soft hwrite[i] == hwrite[0]; }
    }

    constraint c_hsel { soft hsel == 1'b1; }

    constraint c_hauser {
        solve burst_len before hauser;
        hauser.size() == burst_len;
    }

    constraint c_hwuser {
        solve burst_len before hwuser;
        hwuser.size() == burst_len;
    }

    constraint c_req_dly_typ {
        solve burst_len before req_dly_typ;
        req_dly_typ.size() == burst_len;
    }

    constraint c_req_dly {
        solve burst_len before req_dly;
        solve req_dly_typ before req_dly;
        req_dly.size() == burst_len;
        foreach(req_dly[i]) {
            `DELAY_RANGE_CONSTRAINT(req_dly[i], req_dly_typ[i])
            soft req_dly[i] <= 20; req_dly[i] >= 0;
        }
    }

    /* REGISTRATION MACRO */
    `uvm_object_param_utils_begin(ahb_uvc_seq_burst#(`AHB_UVC_PARAMS))
        `uvm_field_int       (           burst_len,   UVM_DEFAULT)
        `uvm_field_queue_int (           haddr,       UVM_DEFAULT)
        `uvm_field_int       (           hburst,      UVM_DEFAULT)
        `uvm_field_queue_int (           hmastlock,   UVM_DEFAULT)
        `uvm_field_int       (           hprot,       UVM_DEFAULT)
        `uvm_field_int       (           hsize,       UVM_DEFAULT)
        `uvm_field_int       (           hnonsec,     UVM_DEFAULT)
        `uvm_field_int       (           hmaster,     UVM_DEFAULT)
        `uvm_field_queue_int (           hwdata,      UVM_DEFAULT)
        `uvm_field_queue_int (           hwstrb,      UVM_DEFAULT)
        `uvm_field_queue_int (           hwrite,      UVM_DEFAULT)
        `uvm_field_int       (           hsel,        UVM_DEFAULT)
        `uvm_field_queue_int (           hauser,      UVM_DEFAULT)
        `uvm_field_queue_int (           hwuser,      UVM_DEFAULT)
        `uvm_field_queue_enum(dly_typ_e, req_dly_typ, UVM_DEFAULT)
        `uvm_field_queue_int (           req_dly,     UVM_DEFAULT)
    `uvm_object_utils_end
    `uvm_object_new
    `uvm_declare_p_sequencer(ahb_uvc_sequencer#(`AHB_UVC_PARAMS))

    /* SEQUENCE BODY TASK */
    extern virtual task body();

endclass : ahb_uvc_seq_burst

task ahb_uvc_seq_burst::body();
    seq_base_t seq_base;

    for(int i = 0; i < burst_len; ++i) begin

        `uvm_do_with(
            seq_base,
            {
                haddr       == local::haddr[i];
                hburst      == local::hburst;
                hmastlock   == local::hmastlock[i];
                hprot       == local::hprot;
                hsize       == local::hsize;
                hnonsec     == local::hnonsec;
                hexcl       == 1'b0;
                hmaster     == local::hmaster;
                htrans      == (i == 0 ? HTRANS_NONSEQ : HTRANS_SEQ);
                hwdata      == local::hwdata[i];
                hwstrb      == local::hwstrb[i];
                hwrite      == local::hwrite[i];
                hsel        == local::hsel;
                hauser      == local::hauser[i];
                hwuser      == local::hwuser[i];
                req_dly_typ == local::req_dly_typ[i];
                req_dly     == local::req_dly[i];
            }
        );

    end

endtask : body

`endif // AHB_UVC_SEQ_BURST_SV
