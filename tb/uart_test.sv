`ifndef UART_TEST_SV
`define UART_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_env.sv"
`include "uart_sequence.sv"

class uart_base_test extends uvm_test;
    `uvm_component_utils(uart_base_test)

    uart_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
    endfunction

    virtual task run_test_seq();
        uart_sequence seq;

        seq = uart_sequence::type_id::create("seq");
        seq.start(env.agt.sqr);
    endtask

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        run_test_seq();
        repeat (4) @(env.agt.mon.u_if.mon_cb);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "uart_base_test completed", UVM_LOW)
    endtask
endclass

class uart_tx_test extends uart_base_test;
    `uvm_component_utils(uart_tx_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_seq();
        uart_tx_sequence seq;

        seq = uart_tx_sequence::type_id::create("seq");
        seq.start(env.agt.sqr);
    endtask
endclass

class uart_rx_test extends uart_base_test;
    `uvm_component_utils(uart_rx_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_seq();
        uart_rx_sequence seq;

        seq = uart_rx_sequence::type_id::create("seq");
        seq.start(env.agt.sqr);
    endtask
endclass

class uart_loopback_test extends uart_base_test;
    `uvm_component_utils(uart_loopback_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_test_seq();
        uart_loopback_sequence seq;

        seq = uart_loopback_sequence::type_id::create("seq");
        seq.start(env.agt.sqr);
    endtask
endclass

`endif
