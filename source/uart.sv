module uart #(
    parameter int CLK_FREQ_HZ = 100_000_000,
    parameter int BAUD_RATE   = 9_600
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_busy,
    output logic       tx_done,
    output logic       tx,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_valid
);

    localparam int CLKS_PER_BIT = (CLK_FREQ_HZ + (BAUD_RATE / 2)) / BAUD_RATE;

    typedef enum logic [1:0] {
        TX_IDLE,
        TX_START,
        TX_DATA,
        TX_STOP
    } tx_state_t;

    typedef enum logic [1:0] {
        RX_IDLE,
        RX_START,
        RX_DATA,
        RX_STOP
    } rx_state_t;

    tx_state_t tx_state;
    rx_state_t rx_state;
    logic [7:0] tx_shift;
    logic [7:0] rx_shift;
    logic [2:0] tx_bit_idx;
    logic [2:0] rx_bit_idx;
    logic [$clog2(CLKS_PER_BIT)-1:0] tx_clk_cnt;
    logic [$clog2(CLKS_PER_BIT)-1:0] rx_clk_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_state   <= TX_IDLE;
            tx_shift   <= '0;
            tx_bit_idx <= '0;
            tx_clk_cnt <= '0;
            tx_busy    <= 1'b0;
            tx_done    <= 1'b0;
            tx         <= 1'b1;
        end
        else begin
            tx_done <= 1'b0;

            case (tx_state)
                TX_IDLE: begin
                    tx         <= 1'b1;
                    tx_busy    <= 1'b0;
                    tx_bit_idx <= '0;
                    tx_clk_cnt <= '0;
                    if (tx_start) begin
                        tx_state <= TX_START;
                        tx_shift <= tx_data;
                        tx       <= 1'b0;
                        tx_busy  <= 1'b1;
                    end
                end

                TX_START: begin
                    tx      <= 1'b0;
                    tx_busy <= 1'b1;
                    if (tx_clk_cnt == CLKS_PER_BIT - 1) begin
                        tx_state   <= TX_DATA;
                        tx_clk_cnt <= '0;
                        tx_bit_idx <= '0;
                        tx         <= tx_shift[0];
                    end
                    else begin
                        tx_clk_cnt <= tx_clk_cnt + 1'b1;
                    end
                end

                TX_DATA: begin
                    tx      <= tx_shift[tx_bit_idx];
                    tx_busy <= 1'b1;
                    if (tx_clk_cnt == CLKS_PER_BIT - 1) begin
                        tx_clk_cnt <= '0;
                        if (tx_bit_idx == 3'd7) begin
                            tx_state <= TX_STOP;
                            tx       <= 1'b1;
                        end
                        else begin
                            tx_bit_idx <= tx_bit_idx + 1'b1;
                            tx         <= tx_shift[tx_bit_idx + 1'b1];
                        end
                    end
                    else begin
                        tx_clk_cnt <= tx_clk_cnt + 1'b1;
                    end
                end

                TX_STOP: begin
                    tx      <= 1'b1;
                    tx_busy <= 1'b1;
                    if (tx_clk_cnt == CLKS_PER_BIT - 1) begin
                        tx_state   <= TX_IDLE;
                        tx_clk_cnt <= '0;
                        tx_busy    <= 1'b0;
                        tx_done    <= 1'b1;
                    end
                    else begin
                        tx_clk_cnt <= tx_clk_cnt + 1'b1;
                    end
                end

                default: begin
                    tx_state   <= TX_IDLE;
                    tx         <= 1'b1;
                    tx_busy    <= 1'b0;
                    tx_bit_idx <= '0;
                    tx_clk_cnt <= '0;
                end
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_state   <= RX_IDLE;
            rx_shift   <= '0;
            rx_bit_idx <= '0;
            rx_clk_cnt <= '0;
            rx_data    <= '0;
            rx_valid   <= 1'b0;
        end
        else begin
            rx_valid <= 1'b0;

            case (rx_state)
                RX_IDLE: begin
                    rx_bit_idx <= '0;
                    rx_clk_cnt <= '0;
                    if (rx == 1'b0) begin
                        rx_state <= RX_START;
                    end
                end

                RX_START: begin
                    if (rx_clk_cnt == ((CLKS_PER_BIT - 1) / 2)) begin
                        if (rx == 1'b0) begin
                            rx_state   <= RX_DATA;
                            rx_clk_cnt <= '0;
                            rx_bit_idx <= '0;
                        end
                        else begin
                            rx_state <= RX_IDLE;
                        end
                    end
                    else begin
                        rx_clk_cnt <= rx_clk_cnt + 1'b1;
                    end
                end

                RX_DATA: begin
                    if (rx_clk_cnt == CLKS_PER_BIT - 1) begin
                        rx_shift[rx_bit_idx] <= rx;
                        rx_clk_cnt <= '0;
                        if (rx_bit_idx == 3'd7) begin
                            rx_state <= RX_STOP;
                        end
                        else begin
                            rx_bit_idx <= rx_bit_idx + 1'b1;
                        end
                    end
                    else begin
                        rx_clk_cnt <= rx_clk_cnt + 1'b1;
                    end
                end

                RX_STOP: begin
                    if (rx_clk_cnt == CLKS_PER_BIT - 1) begin
                        rx_state   <= RX_IDLE;
                        rx_clk_cnt <= '0;
                        if (rx == 1'b1) begin
                            rx_data  <= rx_shift;
                            rx_valid <= 1'b1;
                        end
                    end
                    else begin
                        rx_clk_cnt <= rx_clk_cnt + 1'b1;
                    end
                end

                default: begin
                    rx_state   <= RX_IDLE;
                    rx_bit_idx <= '0;
                    rx_clk_cnt <= '0;
                end
            endcase
        end
    end

endmodule
