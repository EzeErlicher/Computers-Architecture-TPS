`timescale 1ns/1ps

module rx_mod_tb;

    // Parameters
    localparam NB_DATA    = 8;
    localparam STOP_TICKS = 16;

    // Testbench signals
    reg i_clk;
    reg i_s_tick;
    reg i_rx;
    reg i_reset;
    wire [NB_DATA-1:0] o_rx_data;
    wire o_rx_done_tick;

    // Instantiate DUT (Device Under Test)
    rx_mod #(
        .NB_DATA(NB_DATA),
        .STOP_TICKS(STOP_TICKS)
    ) dut (
        .i_clk(i_clk),
        .i_s_tick(i_s_tick),
        .i_rx(i_rx),
        .i_reset(i_reset),
        .o_rx_data(o_rx_data),
        .o_rx_done_tick(o_rx_done_tick)
    );

    // Clock generation
    initial i_clk = 0;
    always #10 i_clk = ~i_clk; // 50 MHz clock (20 ns period)

    // Baud tick generator (same rate as transmitter)
    initial begin
        i_s_tick = 0;
        forever begin
            #160 i_s_tick = 1;
            #20  i_s_tick = 0;
        end
    end

    // Task to simulate a UART frame on i_rx
    task send_uart_byte;
        input [NB_DATA-1:0] data;
        integer i;
        begin
            // Start bit
            i_rx = 1'b0;
            repeat(16) @(posedge i_s_tick); // 1 bit duration

            // Send data bits (LSB first)
            for (i = 0; i < NB_DATA; i = i + 1) begin
                i_rx = data[i];
                repeat(16) @(posedge i_s_tick);
            end

            // Stop bit
            i_rx = 1'b1;
            repeat(16) @(posedge i_s_tick);
        end
    endtask

    // Main test sequence
    initial begin

        // Initial conditions
        i_reset = 1;
        i_rx = 1'b1; // line idle (logic high)
        #50;
        i_reset = 0;

        // Wait a bit
        #200;

        // Send byte 0x55 (01010101)
        $display("Sending byte 0x55...");
        send_uart_byte(8'h55);
        wait(o_rx_done_tick);
        #50;
        $display("Received byte: %h (expected 0x55)", o_rx_data);

        // Send another byte 0xA3
        $display("Sending byte 0xA3...");
        send_uart_byte(8'hA3);
        wait(o_rx_done_tick);
        #50;
        $display("Received byte: %h (expected 0xA3)", o_rx_data);

        #500;
        $finish;
    end

    // Monitor for debugging
    initial begin
        $monitor("Time=%0t | RX=%b | Data=%b | Done=%b | StateData=%h",
                 $time, i_rx, o_rx_data, o_rx_done_tick, o_rx_data);
    end

endmodule