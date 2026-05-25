`ifndef UART_SCOREBOARD_SV
`define UART_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"
`include "uart_mon_item.sv"

`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)

class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    uvm_analysis_imp_exp #(uart_seq_item, uart_scoreboard) exp_imp;
    uvm_analysis_imp_act #(uart_mon_item, uart_scoreboard) act_imp;

    logic [7:0] exp_tx_q[$];
    logic [7:0] exp_rx_q[$];

    int tx_pass_cnt = 0;
    int tx_fail_cnt = 0;
    int rx_pass_cnt = 0;
    int rx_fail_cnt = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_imp = new("exp_imp", this);
        act_imp = new("act_imp", this);
    endfunction

    virtual function void write_exp(uart_seq_item item);
        case (item.op)
            UART_TX_OP: begin
                exp_tx_q.push_back(item.data);
                if (item.loopback) exp_rx_q.push_back(item.data);
                `uvm_info(get_type_name(),
                          $sformatf("EXPECT TX data=0x%02h loopback=%0b", item.data, item.loopback),
                          UVM_MEDIUM)
            end

            UART_RX_OP: begin
                exp_rx_q.push_back(item.data);
                `uvm_info(get_type_name(),
                          $sformatf("EXPECT RX data=0x%02h", item.data),
                          UVM_MEDIUM)
            end

            default: `uvm_fatal(get_type_name(), "Unknown expected UART operation")
        endcase
    endfunction

    virtual function void write_act(uart_mon_item item);
        logic [7:0] expected;

        case (item.evt)
            UART_TX_EVT: begin
                if (exp_tx_q.size() == 0) begin
                    tx_fail_cnt++;
                    `uvm_error(get_type_name(),
                               $sformatf("Unexpected TX byte observed: 0x%02h", item.data))
                    return;
                end

                expected = exp_tx_q.pop_front();
                if (expected === item.data) begin
                    tx_pass_cnt++;
                    `uvm_info(get_type_name(),
                              $sformatf("TX PASS exp=0x%02h data=0x%02h", expected, item.data),
                              UVM_MEDIUM)
                end
                else begin
                    tx_fail_cnt++;
                    `uvm_error(get_type_name(),
                               $sformatf("TX FAIL exp=0x%02h data=0x%02h", expected, item.data))
                end
            end

            UART_RX_EVT: begin
                if (exp_rx_q.size() == 0) begin
                    rx_fail_cnt++;
                    `uvm_error(get_type_name(),
                               $sformatf("Unexpected RX byte observed: 0x%02h", item.data))
                    return;
                end

                expected = exp_rx_q.pop_front();
                if (expected === item.data) begin
                    rx_pass_cnt++;
                    `uvm_info(get_type_name(),
                              $sformatf("RX PASS exp=0x%02h data=0x%02h", expected, item.data),
                              UVM_MEDIUM)
                end
                else begin
                    rx_fail_cnt++;
                    `uvm_error(get_type_name(),
                               $sformatf("RX FAIL exp=0x%02h data=0x%02h", expected, item.data))
                end
            end

            default: `uvm_fatal(get_type_name(), "Unknown actual UART event")
        endcase
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), "===== UART Scoreboard Summary =====", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("TX Pass: %0d", tx_pass_cnt), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("TX Fail: %0d", tx_fail_cnt), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("RX Pass: %0d", rx_pass_cnt), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("RX Fail: %0d", rx_fail_cnt), UVM_LOW)
        `uvm_info(get_type_name(),
                  $sformatf("Pending expected TX bytes: %0d", exp_tx_q.size()),
                  UVM_LOW)
        `uvm_info(get_type_name(),
                  $sformatf("Pending expected RX bytes: %0d", exp_rx_q.size()),
                  UVM_LOW)
    endfunction
endclass

`endif
