`ifndef UART_ENV_SV
`define UART_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_agent.sv"
`include "uart_scoreboard.sv"

class uart_env extends uvm_env;
    `uvm_component_utils(uart_env)

    uart_agent      agt;
    uart_scoreboard scb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = uart_agent::type_id::create("agt", this);
        scb = uart_scoreboard::type_id::create("scb", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.drv.ap.connect(scb.exp_imp);
        agt.mon.ap.connect(scb.act_imp);
    endfunction
endclass

`endif



class className extends uvm_object;
    `uvm_object_utils(className)
    
    function new(string name, uvm_object parent);
        super.new(name, parent);
    endfunction
endclass