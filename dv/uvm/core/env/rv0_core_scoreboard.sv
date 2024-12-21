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
// Source location: svn://lukic.sytes.net/rv0
//
// As per CERN-OHL-S v2 section 4.1, should You produce hardware based on
// these sources, You must maintain the Source Location visible on the
// external case of any product you make using this documentation.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: rv0_core_scoreboard.sv
// Auth: Nikola Lukić
// Date: 31.10.2024.
// Desc:
//
////////////////////////////////////////////////////////////////////////////////////////////////////
// Change History
// -------------------------------------------------------------------------------------------------
// Date         Author  Description
// -------------------------------------------------------------------------------------------------
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RV0_CORE_SCOREBOARD_SV
`define RV0_CORE_SCOREBOARD_SV

class rv0_core_scoreboard #(`RV0_CORE_ENV_PARAM_LST) extends uvm_scoreboard;

    typedef ahb_uvc_item#(`AHB_UVC_PARAMS)  ahb_item_t;
    typedef rv_uvc_item#(`RV_UVC_PARAMS)    rv_item_t;
    typedef rv0_core_cfg                    cfg_t;

    typedef bit unsigned [XLEN-1:0]         addr_t;     // address type
    typedef bit unsigned [XLEN-1:0]         idata_t;    // unsigned int data type
    typedef bit signed   [XLEN-1:0]         sdata_t;    // signed int data type
    typedef bit unsigned [FLEN-1:0]         fdata_t;    // floating-point data type
    typedef bit unsigned [4:0]              raddr_t;    // register address type

    typedef struct {
        int unsigned bp_hit_cnt;
        int unsigned bp_miss_cnt;
        int unsigned ifetch_cnt;
        int unsigned iret_cnt;
    } cpu_stats_t;

    /* SCOREBOARD CONFIG OBJECT */
    cfg_t m_cfg;

    /* SCOREBOARD ANALYSIS FIFOS */
    uvm_tlm_analysis_fifo#(ahb_item_t)      m_imem_afifo;
    uvm_tlm_analysis_fifo#(ahb_item_t)      m_dmem_afifo;
    uvm_tlm_analysis_fifo#(rv_item_t)       m_iret_afifo;

    /* SCOREBOARD ANALYSIS PORTS */
    uvm_analysis_port#(ahb_item_t)          m_ld_aport;
    uvm_analysis_port#(ahb_item_t)          m_st_aport;

    /* SCOREBOARD MODEL FIELDS */
    addr_t      m_npc       = PC_RST_VAL;
    idata_t     ireg [0:31] = '{default: 'h0};
    fdata_t     freg [0:31] = '{default: 'h0};

    rv_item_t   m_iret_queue [addr_t][$];

    cpu_stats_t m_stats;

    /* REGISTRATION MACRO */
    `uvm_component_param_utils(rv0_core_scoreboard#(`RV0_CORE_ENV_PARAMS))
    `uvm_component_new

    /* UVM PHASES */
    extern virtual function void            build_phase(uvm_phase phase);
    extern virtual task                     run_phase(uvm_phase phase);
    extern virtual function void            check_phase(uvm_phase phase);
    extern virtual function void            report_phase(uvm_phase phase);

    /* METHODS */
    extern virtual task                     cpu_state_predict();
    extern virtual task                     cpu_state_check();
    extern virtual function void            cpu_state_update(rv_item_t rv_item);
    extern virtual task                     cpu_state_predict_res(rv_item_t ifetch_item);

    extern virtual task                     cpu_set_exp_res(ref rv_item_t rv_item);
    extern virtual function void            cpu_set_exp_npc(rv_item_t rv_item);
    extern virtual task                     cpu_set_exp_ld_data(ref idata_t ld_data);

    extern virtual function bit             cpu_check_misfetch(rv_item_t rv_item);
    extern virtual function bit             cpu_check_trap(rv_item_t rv_item);

    extern virtual function void            cpu_stats_update_ifetch(rv_item_t ifetch_item);
    extern virtual function void            cpu_stats_update_iret(rv_item_t iret_item, rv_item_t ifetch_item);

    extern virtual function void            cpu_stats_report();
    extern virtual function void            cpu_stats_report_bp();
    extern virtual function void            cpu_stats_report_iret();
    extern virtual function void            cpu_stats_report_latency();

    extern virtual function void            set_ireg(raddr_t idx, idata_t val);
    extern virtual function idata_t         get_ireg(raddr_t idx);
    extern virtual function void            set_freg(raddr_t idx, fdata_t val);
    extern virtual function fdata_t         get_freg(raddr_t idx);

    extern virtual function idata_t         s_ext(idata_t data, int bits);
    extern virtual function idata_t         z_ext(idata_t data, int bits);

endclass : rv0_core_scoreboard

function void rv0_core_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // get scoreboard config object from DB
    `uvm_config_db_get(cfg_t, this, "", "m_cfg", m_cfg)

    // create analysis fifos
    m_imem_afifo = new("m_imem_afifo", this);
    m_dmem_afifo = new("m_dmem_afifo", this);
    m_iret_afifo = new("m_iret_afifo", this);

    // create analysis port
    m_ld_aport = new("m_ld_aport", this);
    m_st_aport = new("m_st_aport", this);

endfunction : build_phase

task rv0_core_scoreboard::run_phase(uvm_phase phase);
    super.run_phase(phase);

    fork
        begin
            // predict CPU state based on fetched instructions
            cpu_state_predict();
        end
        begin
            // check instruction retire based on model
            cpu_state_check();
        end
    join

endtask : run_phase

function void rv0_core_scoreboard::check_phase(uvm_phase phase);
    super.check_phase(phase);

    foreach(m_iret_queue[addr]) begin
        chk_iret_queue_empty : assert(m_iret_queue[addr].size() == 0)
        else begin
            `uvm_error(`gtn, $sformatf("\nIRET queue at [addr=%0h] not empty", addr))
        end
    end

endfunction : check_phase

function void rv0_core_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);
    cpu_stats_report();
endfunction : report_phase

task rv0_core_scoreboard::cpu_state_predict();

    forever begin
        ahb_item_t imem_item;
        rv_item_t  ifetch_item = rv_item_t::type_id::create("ifetch_item", this);

        // get fetched instruction from IMEM interface
        m_imem_afifo.get(imem_item);
        ifetch_item.addr = imem_item.haddr;
        ifetch_item.insn = imem_item.hrdata;
        ifetch_item.set_fields();

        `uvm_info(`gtn, $sformatf("\nIMEM FETCH\n%s", ifetch_item.sprint()), UVM_HIGH)

        // check if instruction has been speculatively fetched
        if(!cpu_check_misfetch(ifetch_item)) begin

            if(ROB_ENA == 1'b1) begin
                fork
                    cpu_state_predict_res(ifetch_item);
                join
            end
            else begin
                fork
                    cpu_state_predict_res(ifetch_item);
                join_none
            end

            // get expected next instruction address
            cpu_set_exp_npc(ifetch_item);

            // print fetched instruction item
            `uvm_info(`gtn, {"\nIFETCH:\n", ifetch_item.sprint()}, UVM_HIGH)
            `uvm_info(
                `gtn,
                $sformatf("\nREG: r1=%0h; r2=%0h", get_ireg(ifetch_item.rs1), get_ireg(ifetch_item.rs2)),
                UVM_HIGH
            )
            `uvm_info(`gtn, $sformatf("\nNPC: %0h", m_npc), UVM_HIGH)

        end
        else begin
            `uvm_info(`gtn, $sformatf("\nIMEM FETCH IGNORED:\n%s", ifetch_item.sprint()), UVM_HIGH)
        end

        // update instruction fetch statistics
        cpu_stats_update_ifetch(ifetch_item);

    end

endtask : cpu_state_predict

task rv0_core_scoreboard::cpu_state_predict_res(rv_item_t ifetch_item);

    // set expected instruction result
    cpu_set_exp_res(ifetch_item);

    // update CPU state
    cpu_state_update(ifetch_item);

    // insert instruction into IRET queue
    m_iret_queue[ifetch_item.addr].push_back(ifetch_item);

endtask : cpu_state_predict_res

task rv0_core_scoreboard::cpu_state_check();

    forever begin
        rv_item_t iret_item;
        rv_item_t iret_exp;

        // get retired instruction from IRET interface
        m_iret_afifo.get(iret_item);
        iret_item.set_fields();

        `uvm_info(`gtn, {"\nIRET:\n", iret_item.sprint()}, UVM_HIGH)

        // check if instruction retire is expected for given address
        chk_insn_addr : assert(m_iret_queue[iret_item.addr].size() > 0)
        else begin
            `uvm_error(`gtn, $sformatf("\nUNEXPECTED INSTRUCTION ADDESS\nGOT: %0h", iret_item.addr))
            continue;
        end

        // get expected instruction retire
        iret_exp = m_iret_queue[iret_item.addr].pop_front();

        chk_insn_cmp : assert(iret_exp.compare(iret_item))
        else begin
            `uvm_error(
                `gtn,
                $sformatf(
                    "\nINSTRUCTION RETIRE MISMATCH\nEXP:\n%s\nGOT:\n%s",
                    iret_exp.sprint(),
                    iret_item.sprint()
                )
            )
        end

        // update instruction retire statistics
        cpu_stats_update_iret(iret_item, iret_exp);

    end

endtask : cpu_state_check

function void rv0_core_scoreboard::cpu_state_update(rv_item_t rv_item);
    case(rv_item.opcode)
        BRANCH:  return;
        STORE:   return;
        default: set_ireg(rv_item.rd, rv_item.res);
    endcase
endfunction : cpu_state_update

task rv0_core_scoreboard::cpu_set_exp_res(ref rv_item_t rv_item);
    idata_t r1     = get_ireg(rv_item.rs1);
    idata_t r2     = get_ireg(rv_item.rs2);
    idata_t imm    = rv_item.imm;
    addr_t  addr   = rv_item.addr;
    bit     mod    = rv_item.insn[30];

    case(rv_item.opcode)
        LUI: begin
            rv_item.res = imm;
        end
        AUIPC: begin
            rv_item.res = imm + addr;
        end
        JAL: begin
            rv_item.res = addr + 'h4;
        end
        JALR: begin
            rv_item.res = addr + 'h4;
        end
        LOAD: begin
            idata_t ld_data;
            cpu_set_exp_ld_data(ld_data);
            case(rv_item.funct3)
                LB:  rv_item.res = s_ext(ld_data,  8);
                LH:  rv_item.res = s_ext(ld_data, 16);
                LW:  rv_item.res = s_ext(ld_data, 32);
                LD:  rv_item.res = s_ext(ld_data, 64);
                LBU: rv_item.res = z_ext(ld_data,  8);
                LHU: rv_item.res = z_ext(ld_data, 16);
                LWU: rv_item.res = z_ext(ld_data, 32);
                default: rv_item.res = 'hX;
            endcase
        end
        OP_IMM: begin
            bit [5:0] shamt  = imm & ((XLEN == 64) ? 'h3f : 'h1f);
            bit [4:0] shamtw = imm & 'h1f;
            idata_t   sra    = $signed(r1) >>> shamt;

            case(rv_item.funct3)
                ADDI:  rv_item.res = r1 + imm;
                SLLI:  rv_item.res = r1 << shamt;
                SLTI:  rv_item.res = $signed(r1) < $signed(imm);
                SLTIU: rv_item.res = r1 < imm;
                XORI:  rv_item.res = r1 ^ imm;
                SRLI:  rv_item.res = mod ? sra : (r1 >> shamt);
                ORI:   rv_item.res = r1 | imm;
                ANDI:  rv_item.res = r1 & imm;
                default: rv_item.res = 'hX;
            endcase
        end
        OP: begin
            bit [5:0] shamt  = r2 & ((XLEN == 64) ? 'h3f : 'h1f);
            bit [4:0] shamtw = r2 & 'h1f;
            idata_t   sra    = $signed(r1) >>> shamt;

            case(rv_item.funct3)
                ADD:  rv_item.res = mod ? r1 - r2 : r1 + r2;
                SLL:  rv_item.res = r1 << shamt;
                SLT:  rv_item.res = $signed(r1) < $signed(r2);
                SLTU: rv_item.res = r1 < r2;
                XOR:  rv_item.res = r1 ^ r2;
                SRL:  rv_item.res = mod ? sra : (r1 >> shamt);
                OR:   rv_item.res = r1 | r2;
                AND:  rv_item.res = r1 & r2;
                default: rv_item.res = 'hX;
            endcase
        end
        default: rv_item.res = 'h0;
    endcase

endtask : cpu_set_exp_res

function void rv0_core_scoreboard::cpu_set_exp_npc(rv_item_t rv_item);
    idata_t r1   = get_ireg(rv_item.rs1);
    idata_t r2   = get_ireg(rv_item.rs2);
    sdata_t sr1  = $signed(r1);
    sdata_t sr2  = $signed(r2);
    idata_t imm  = rv_item.imm;
    addr_t  addr = rv_item.addr;

    case(rv_item.opcode)
        JAL:  m_npc = addr + imm;
        JALR: m_npc = (r1 + imm) & {{XLEN-1{1'b1}}, 1'b0};
        BRANCH: begin
            case(rv_item.funct3)
                BEQ:  m_npc = (r1  == r2)  ? addr + imm : addr + 'h4;
                BNE:  m_npc = (r1  != r2)  ? addr + imm : addr + 'h4;
                BLT:  m_npc = (sr1 <  sr2) ? addr + imm : addr + 'h4;
                BGE:  m_npc = (sr1 >= sr2) ? addr + imm : addr + 'h4;
                BLTU: m_npc = (r1  <  r2)  ? addr + imm : addr + 'h4;
                BGEU: m_npc = (r1  >= r2)  ? addr + imm : addr + 'h4;
            endcase
        end
        default: m_npc = addr + 'h4;
    endcase

    // TODO:
    // if(cpu_check_trap())

endfunction : cpu_set_exp_npc

task rv0_core_scoreboard::cpu_set_exp_ld_data(ref idata_t ld_data);
    ahb_item_t ahb_item;
    do begin
        m_dmem_afifo.get(ahb_item);
    end while(ahb_item.hwrite != 1'b0);
    ld_data = ahb_item.hrdata;
endtask : cpu_set_exp_ld_data

function bit rv0_core_scoreboard::cpu_check_misfetch(rv_item_t rv_item);
    static int misfetch_cnt = 0;

    // check if misfetches are allowed
    if(misfetch_cnt == 0) begin
        // no misfetch expected, check fetch address
        chk_ifetch_addr : assert(rv_item.addr == m_npc)
        else begin
            `uvm_warning(
                `gtn,
                $sformatf(
                    "\nUNEXPECTED FETCH ADDRESS\nEXP: %0h\nGOT: %0h",
                    m_npc,
                    rv_item.addr
                )
            )
        end
    end
    else begin
        if(rv_item.addr == m_npc) misfetch_cnt = 0;
        else misfetch_cnt--;
    end

    // allow a number of misfetches to account for flow control delay
    if(rv_item.addr == m_npc && rv_item.opcode inside {JAL, JALR, BRANCH}) begin
        misfetch_cnt = 20;
    end

    return rv_item.addr != m_npc;

endfunction : cpu_check_misfetch

function bit rv0_core_scoreboard::cpu_check_trap(rv_item_t rv_item);
    // TODO
    return 0;
endfunction : cpu_check_trap

function void rv0_core_scoreboard::set_ireg(raddr_t idx, idata_t val);
    if(idx == 0) return;
    ireg[idx] = val;
endfunction : set_ireg

function idata_t rv0_core_scoreboard::get_ireg(raddr_t idx);
    if(idx == 0) return 'h0;
    return ireg[idx];
endfunction : get_ireg

function void rv0_core_scoreboard::set_freg(raddr_t idx, fdata_t val);
    freg[idx] = val;
endfunction : set_freg

function fdata_t rv0_core_scoreboard::get_freg(raddr_t idx);
    return freg[idx];
endfunction : get_freg

function idata_t rv0_core_scoreboard::s_ext(idata_t data, int bits);
    case(bits)
        8:  return {{ XLEN-8{data[7]}},  data[7:0]};
        16: return {{XLEN-16{data[15]}}, data[15:0]};
        32: return {{XLEN-32{data[31]}}, data[31:0]};
        64: return data;
    endcase
endfunction : s_ext

function idata_t rv0_core_scoreboard::z_ext(idata_t data, int bits);
    case(bits)
        8:  return {{ XLEN-8{1'b0}}, data[7:0]};
        16: return {{XLEN-16{1'b0}}, data[15:0]};
        32: return {{XLEN-32{1'b0}}, data[31:0]};
        64: return data;
    endcase
endfunction : z_ext

function void rv0_core_scoreboard::cpu_stats_update_ifetch(rv_item_t ifetch_item);
    m_stats.ifetch_cnt++;
endfunction : cpu_stats_update_ifetch

function void rv0_core_scoreboard::cpu_stats_update_iret(rv_item_t iret_item, rv_item_t ifetch_item);
    m_stats.iret_cnt++;
endfunction : cpu_stats_update_iret

function void rv0_core_scoreboard::cpu_stats_report();
    cpu_stats_report_bp();
    cpu_stats_report_iret();
    cpu_stats_report_latency();
endfunction : cpu_stats_report

function void rv0_core_scoreboard::cpu_stats_report_bp();
    `uvm_info(
        `gtn,
        $sformatf(
            "\nBRANCH PREDICTION STATS:\nhit_cnt:  %0d\nmiss_cnt: %0d\nhit_%%: %f",
            m_stats.bp_hit_cnt,
            m_stats.bp_miss_cnt,
            m_stats.bp_hit_cnt / real'(m_stats.bp_hit_cnt + m_stats.bp_miss_cnt)
        ),
        UVM_LOW
    )
endfunction : cpu_stats_report_bp

function void rv0_core_scoreboard::cpu_stats_report_iret();
    `uvm_info(
        `gtn,
        $sformatf(
            "\nINSTRUCTION RETIRE STATS:\ntotal fetched: %0d\ntotal retired: %0d",
            m_stats.ifetch_cnt,
            m_stats.iret_cnt
        ),
        UVM_LOW
    )
endfunction : cpu_stats_report_iret

function void rv0_core_scoreboard::cpu_stats_report_latency();
endfunction : cpu_stats_report_latency

`endif // RV0_CORE_SCOREBOARD_SV
