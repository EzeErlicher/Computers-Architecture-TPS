`timescale 1ns/1ps

module tx_mod_tb;

    // Parameters
    localparam NB_DATA    = 8;
    localparam STOP_TICKS = 16;

    // Signals
    reg i_clk;
    reg i_s_tick;
    reg i_tx_start;
    reg [NB_DATA-1:0] i_tx_data;
    reg i_reset;
    wire o_tx_done_tick;
    wire o_tx;

    // Instantiate the DUT (Device Under Test)
    tx_mod #(
        .NB_DATA(NB_DATA),
        .STOP_TICKS(STOP_TICKS)
    ) dut (
        .i_clk(i_clk),
        .i_s_tick(i_s_tick),
        .i_tx_start(i_tx_start),
        .i_tx_data(i_tx_data),
        .i_reset(i_reset),
        .o_tx_done_tick(o_tx_done_tick),
        .o_tx(o_tx)
    );

    // Clock generation (50 MHz for example)
    initial i_clk = 0;
    always #10 i_clk = ~i_clk; // 20 ns period

    // Tick generator (simulates baud rate ticks)
    initial begin
        i_s_tick = 0;
        forever begin
            #160 i_s_tick = 1; // shorter period so we can see transmission
            #20  i_s_tick = 0;
        end
    end

    // Test sequence
    initial begin
       
        // Initialization
        i_reset = 1;
        i_tx_start = 0;
        i_tx_data = 8'b0;
        #50;
        i_reset = 0;

        // Send first byte
        @(negedge i_clk);
        i_tx_data = 8'b10101010;  // Example pattern: 0xAA
        i_tx_start = 1;
        @(negedge i_clk);
        i_tx_start = 0;

        // Wait for transmission to finish
        wait(o_tx_done_tick);
        $display("Transmission complete at time %t", $time);

        // Send another byte for verification
        @(negedge i_clk);
        i_tx_data = 8'b11001100;  // Example pattern: 0xCC
        i_tx_start = 1;
        @(negedge i_clk);
        i_tx_start = 0;

        wait(o_tx_done_tick);
        $display("Second transmission complete at time %t", $time);

        #500;
        $finish;
    end

    // Monitor key signals
    initial begin
        $monitor("Time=%0t | TX=%b | TX_START=%b | DONE=%b | STATE_DATA=%b",
                 $time, o_tx, i_tx_start, o_tx_done_tick, i_tx_data);
    end

endmodule