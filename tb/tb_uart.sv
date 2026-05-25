`ifndef TB_UART_SV
`define TB_UART_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_interface.sv"
`include "uart_test.sv"

module tb_uart;
    localparam int CLK_FREQ_HZ  = 100_000_000;
    localparam int BAUD_RATE    = 9_600;
    localparam int CLK_PERIODNS = 10;
    localparam int CLKS_PER_BIT = (CLK_FREQ_HZ + (BAUD_RATE / 2)) / BAUD_RATE;

    logic clk;

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIODNS / 2) clk = ~clk;
    end

    uart_if #(CLKS_PER_BIT) u_if(clk);

    initial begin
        u_if.rst_n       = 1'b0;
        u_if.tx_start    = 1'b0;
        u_if.tx_data     = '0;
        u_if.rx_drv      = 1'b1;
        u_if.loopback_en = 1'b0;
        repeat (10) @(posedge clk);
        u_if.rst_n = 1'b1;
    end

    uart #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .BAUD_RATE  (BAUD_RATE)
    ) dut (
        .clk     (clk),
        .rst_n   (u_if.rst_n),
        .tx_start(u_if.tx_start),
        .tx_data (u_if.tx_data),
        .tx_busy (u_if.tx_busy),
        .tx_done (u_if.tx_done),
        .tx      (u_if.tx),
        .rx      (u_if.rx),
        .rx_data (u_if.rx_data),
        .rx_valid(u_if.rx_valid)
    );

    initial begin
        uvm_config_db#(virtual uart_if)::set(null, "*", "u_if", u_if);
        run_test();
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, tb_uart, "+all");
    end
endmodule

`endif
