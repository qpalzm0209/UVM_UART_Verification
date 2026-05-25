`ifndef UART_MONITOR_SV
`define UART_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_interface.sv"
`include "uart_mon_item.sv"

class uart_monitor extends uvm_monitor;
    `uvm_component_utils(uart_monitor)

    virtual uart_if u_if;
    uvm_analysis_port #(uart_mon_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "u_if", u_if))
            `uvm_fatal(get_type_name(), "u_if not found in config_db")
    endfunction

    task automatic wait_mon_clks(int count);
        repeat (count) @(u_if.mon_cb);
    endtask

    task automatic monitor_tx();
        uart_mon_item item;
        logic [7:0]   data_byte;

        forever begin
            do @(u_if.mon_cb); while (u_if.mon_cb.rst_n !== 1'b1 || u_if.mon_cb.tx !== 1'b0);

            wait_mon_clks(u_if.half_clks_per_bit);
            if (u_if.mon_cb.tx !== 1'b0) continue;

            data_byte = '0;
            for (int i = 0; i < 8; i++) begin
                wait_mon_clks(u_if.clks_per_bit);
                data_byte[i] = u_if.mon_cb.tx;
            end

            wait_mon_clks(u_if.clks_per_bit);
            if (u_if.mon_cb.tx === 1'b1) begin
                item = uart_mon_item::type_id::create("tx_evt_item");
                item.evt  = UART_TX_EVT;
                item.data = data_byte;
                ap.write(item);
            end
        end
    endtask

    task automatic monitor_rx();
        uart_mon_item item;

        forever begin
            @(u_if.mon_cb);
            if (u_if.mon_cb.rst_n !== 1'b1) continue;
            if (u_if.mon_cb.rx_valid === 1'b1) begin
                item = uart_mon_item::type_id::create("rx_evt_item");
                item.evt  = UART_RX_EVT;
                item.data = u_if.mon_cb.rx_data;
                ap.write(item);
            end
        end
    endtask

    virtual task run_phase(uvm_phase phase);
        fork
            monitor_tx();
            monitor_rx();
        join
    endtask
endclass

`endif
