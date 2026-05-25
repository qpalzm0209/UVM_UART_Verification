`ifndef UART_MON_ITEM_SV
`define UART_MON_ITEM_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum logic {
    UART_TX_EVT,
    UART_RX_EVT
} uart_evt_e;

class uart_mon_item extends uvm_sequence_item;
    uart_evt_e      evt;
    logic [7:0]     data;

    `uvm_object_utils_begin(uart_mon_item)
        `uvm_field_enum(uart_evt_e, evt, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uart_mon_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("evt=%s data=0x%02h",
                         (evt == UART_TX_EVT) ? "TX_EVT" : "RX_EVT",
                         data);
    endfunction
endclass

`endif
