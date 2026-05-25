`ifndef UART_DRIVER_SV
`define UART_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_interface.sv"
`include "uart_seq_item.sv"

class uart_driver extends uvm_driver #(uart_seq_item);
    `uvm_component_utils(uart_driver)

    virtual uart_if u_if;
    uvm_analysis_port #(uart_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual uart_if)::get(this, "", "u_if", u_if))
            `uvm_fatal(get_type_name(), "u_if not found in config_db")
    endfunction

    task automatic wait_tx_idle();
        int timeout_cycles;

        timeout_cycles = u_if.clks_per_bit * 12;
        repeat (timeout_cycles) begin
            if (u_if.drv_cb.tx_busy !== 1'b1) return;
            @(u_if.drv_cb);
        end

        `uvm_fatal(get_type_name(),
                   $sformatf("Timeout waiting for tx_busy to drop after %0d drv_cb cycles",
                             timeout_cycles))
    endtask

    task automatic wait_tx_done();
        int timeout_cycles;

        timeout_cycles = u_if.clks_per_bit * 12;
        repeat (timeout_cycles) begin
            @(u_if.drv_cb);
            if (u_if.drv_cb.tx_done === 1'b1) return;
        end

        `uvm_fatal(get_type_name(),
                   $sformatf("Timeout waiting for tx_done after %0d drv_cb cycles",
                             timeout_cycles))
    endtask

    task automatic wait_rx_valid();
        int timeout_cycles;

        timeout_cycles = u_if.clks_per_bit * 14;
        repeat (timeout_cycles) begin
            @(u_if.drv_cb);
            if (u_if.drv_cb.rx_valid === 1'b1) return;
        end

        `uvm_fatal(get_type_name(),
                   $sformatf("Timeout waiting for rx_valid after %0d drv_cb cycles",
                             timeout_cycles))
    endtask

    task automatic publish_expected(uart_seq_item item);
        uart_seq_item exp_item;

        exp_item = uart_seq_item::type_id::create("exp_item");
        exp_item.copy(item);
        ap.write(exp_item);
    endtask

    task automatic drive_tx(uart_seq_item item);
        wait_tx_idle();
        publish_expected(item);

        `uvm_info(get_type_name(),
                  $sformatf("DRIVE TX data=0x%02h loopback=%0b", item.data, item.loopback),
                  UVM_LOW)

        @(u_if.drv_cb);
        u_if.drv_cb.loopback_en <= item.loopback;
        u_if.drv_cb.rx_drv      <= 1'b1;
        u_if.drv_cb.tx_data     <= item.data;
        u_if.drv_cb.tx_start    <= 1'b1;

        @(u_if.drv_cb);
        u_if.drv_cb.tx_start <= 1'b0;

        if (item.loopback) begin
            fork
                wait_tx_done();
                wait_rx_valid();
            join
        end
        else begin
            wait_tx_done();
        end

        `uvm_info(get_type_name(),
                  $sformatf("DONE TX data=0x%02h loopback=%0b", item.data, item.loopback),
                  UVM_LOW)
    endtask

    task automatic drive_rx(uart_seq_item item);
        wait_tx_idle();
        publish_expected(item);

        `uvm_info(get_type_name(),
                  $sformatf("DRIVE RX data=0x%02h", item.data),
                  UVM_LOW)

        @(negedge u_if.clk);
        u_if.loopback_en <= 1'b0;
        u_if.tx_start    <= 1'b0;
        u_if.rx_drv      <= 1'b1;

        repeat (u_if.clks_per_bit) @(negedge u_if.clk);
        u_if.rx_drv <= 1'b0;
        repeat (u_if.clks_per_bit) @(negedge u_if.clk);

        for (int i = 0; i < 8; i++) begin
            u_if.rx_drv <= item.data[i];
            repeat (u_if.clks_per_bit) @(negedge u_if.clk);
        end

        u_if.rx_drv <= 1'b1;
        wait_rx_valid();

        `uvm_info(get_type_name(),
                  $sformatf("DONE RX data=0x%02h", item.data),
                  UVM_LOW)
    endtask

    virtual task run_phase(uvm_phase phase);
        uart_seq_item item;

        u_if.tx_start    = 1'b0;
        u_if.tx_data     = '0;
        u_if.rx_drv      = 1'b1;
        u_if.loopback_en = 1'b0;

        wait (u_if.rst_n === 1'b1);

        forever begin
            seq_item_port.get_next_item(item);

            case (item.op)
                UART_TX_OP: drive_tx(item);
                UART_RX_OP: drive_rx(item);
                default: `uvm_fatal(get_type_name(), "Unknown UART operation")
            endcase

            seq_item_port.item_done();
        end
    endtask
endclass

`endif
