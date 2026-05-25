`ifndef UART_INTERFACE_SV
`define UART_INTERFACE_SV

interface uart_if #(parameter int CLKS_PER_BIT = 10417) (input logic clk);
    logic       rst_n;
    logic       tx_start;
    logic [7:0] tx_data;
    logic       tx_busy;
    logic       tx_done;
    logic       tx;
    logic       rx_drv;
    logic       loopback_en;
    logic       rx;
    logic [7:0] rx_data;
    logic       rx_valid;

    int clks_per_bit      = CLKS_PER_BIT;
    int half_clks_per_bit = (CLKS_PER_BIT - 1) / 2;

    assign rx = loopback_en ? tx : rx_drv;

    clocking drv_cb @(posedge clk);
        default input #1 output #0;
        output tx_start, tx_data, rx_drv, loopback_en;
        input  rst_n, tx_busy, tx_done, tx, rx, rx_data, rx_valid;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #0 output #0;
        input rst_n, tx_start, tx_data, tx_busy, tx_done, tx;
        input rx_drv, loopback_en, rx, rx_data, rx_valid;
    endclocking
endinterface

`endif
