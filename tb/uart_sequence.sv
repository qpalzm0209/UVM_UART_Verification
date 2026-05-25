`ifndef UART_SEQUENCE_SV
`define UART_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_seq_item.sv"

class uart_sequence extends uvm_sequence #(uart_seq_item);
    `uvm_object_utils(uart_sequence)

    function new(string name = "uart_sequence");
        super.new(name);
    endfunction

    virtual task body();
        uart_seq_item item;

        `uvm_info(get_type_name(), "Starting UART smoke sequence", UVM_LOW)

        item = uart_seq_item::type_id::create("tx_item_0");
        start_item(item);
        item.op = UART_TX_OP; item.data = 8'h55; item.loopback = 1'b0;
        finish_item(item);

        item = uart_seq_item::type_id::create("tx_item_1");
        start_item(item);
        item.op = UART_TX_OP; item.data = 8'hA3; item.loopback = 1'b0;
        finish_item(item);

        item = uart_seq_item::type_id::create("rx_item_0");
        start_item(item);
        item.op = UART_RX_OP; item.data = 8'hA5; item.loopback = 1'b0;
        finish_item(item);

        item = uart_seq_item::type_id::create("rx_item_1");
        start_item(item);
        item.op = UART_RX_OP; item.data = 8'h3C; item.loopback = 1'b0;
        finish_item(item);

        item = uart_seq_item::type_id::create("loop_item_0");
        start_item(item);
        item.op = UART_TX_OP; item.data = 8'h96; item.loopback = 1'b1;
        finish_item(item);

        item = uart_seq_item::type_id::create("loop_item_1");
        start_item(item);
        item.op = UART_TX_OP; item.data = 8'h0F; item.loopback = 1'b1;
        finish_item(item);
    endtask
endclass

class uart_tx_sequence extends uvm_sequence #(uart_seq_item);
    `uvm_object_utils(uart_tx_sequence)

    function new(string name = "uart_tx_sequence");
        super.new(name);
    endfunction

    virtual task body();
        uart_seq_item item;

        `uvm_info(get_type_name(), "Starting UART TX sequence", UVM_LOW)

        item = uart_seq_item::type_id::create("tx_item_0");
        start_item(item);
        item.op = UART_TX_OP; item.data = 8'h55; item.loopback = 1'b0;
        finish_item(item);

        item = uart_seq_item::type_id::create("tx_item_1");
        start_item(item);
        item.op = UART_TX_OP; item.data = 8'hA3; item.loopback = 1'b0;
        finish_item(item);
    endtask
endclass

class uart_rx_sequence extends uvm_sequence #(uart_seq_item);
    `uvm_object_utils(uart_rx_sequence)

    function new(string name = "uart_rx_sequence");
        super.new(name);
    endfunction

    virtual task body();
        uart_seq_item item;

        `uvm_info(get_type_name(), "Starting UART RX sequence", UVM_LOW)

        item = uart_seq_item::type_id::create("rx_item_0");
        start_item(item);
        item.op = UART_RX_OP; item.data = 8'hA5; item.loopback = 1'b0;
        finish_item(item);

        item = uart_seq_item::type_id::create("rx_item_1");
        start_item(item);
        item.op = UART_RX_OP; item.data = 8'h3C; item.loopback = 1'b0;
        finish_item(item);
    endtask
endclass

class uart_loopback_sequence extends uvm_sequence #(uart_seq_item);
    `uvm_object_utils(uart_loopback_sequence)

    function new(string name = "uart_loopback_sequence");
        super.new(name);
    endfunction

    virtual task body();
        uart_seq_item item;

        `uvm_info(get_type_name(), "Starting UART loopback sequence", UVM_LOW)

        item = uart_seq_item::type_id::create("loop_item_0");
        start_item(item);
        item.op = UART_TX_OP; item.data = 8'h96; item.loopback = 1'b1;
        finish_item(item);

        item = uart_seq_item::type_id::create("loop_item_1");
        start_item(item);
        item.op = UART_TX_OP; item.data = 8'h0F; item.loopback = 1'b1;
        finish_item(item);
    endtask
endclass

`endif
