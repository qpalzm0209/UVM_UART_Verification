`ifndef UART_SEQ_ITEM_SV
`define UART_SEQ_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum logic {
    UART_TX_OP,
    UART_RX_OP
} uart_op_e;

class uart_seq_item extends uvm_sequence_item;
    rand uart_op_e   op;
    rand logic [7:0] data;
    rand bit         loopback;

    constraint c_loopback {
        if (op == UART_RX_OP) loopback == 1'b0;
    }

    `uvm_object_utils_begin(uart_seq_item)
        `uvm_field_enum(uart_op_e, op, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(loopback, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uart_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("op=%s data=0x%02h loopback=%0b",
                         (op == UART_TX_OP) ? "TX" : "RX",
                         data,
                         loopback);
    endfunction
endclass

`endif
