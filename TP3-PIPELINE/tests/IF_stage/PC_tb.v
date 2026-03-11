`timescale 1ns / 1ps

module PC_tb;

    parameter NB_DATA = 10;

    reg                i_clk;
    reg                i_reset;
    reg                i_PC_enable;
    reg  [NB_DATA-1:0] i_address;
    wire [NB_DATA-1:0] o_PC;

    reg  [NB_DATA-1:0] expected_address;
    reg  [NB_DATA-1:0] prev_address;

    PC #(
        .NB_DATA(NB_DATA)
    ) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_PC_enable(i_PC_enable),
        .i_address(i_address),
        .o_PC(o_PC)
    );

    always #5 i_clk = ~i_clk;

    initial begin
        i_clk = 0; i_reset = 1;
        i_PC_enable = 0;
        i_address = 0;

        #10;
        i_reset = 0;

        // Test multiple writes
        for (integer i = 0; i < 10; i = i + 1) begin
            expected_address = $random & 10'h3FF;
            i_address = expected_address;
            i_PC_enable = 1;
            #10;
            i_PC_enable = 0;
            #10;
            $display("[WRITE] i_address = %10d -> o_PC = %10d | Status: %s", expected_address, o_PC, (o_PC === expected_address) ? "OK" : "ERR");

            // Test no write (PC should hold)
            prev_address = o_PC;
            i_address = $random & 10'h3FF; // Change input but no write
            #10;
            $display("[HOLD] o_PC = %10d | Expected: %10d | Status: %s", o_PC, prev_address, (o_PC === prev_address) ? "OK" : "ERR");
        end

        // Test reset
        i_reset = 1; #10;
        $display("[RESET] o_PC = %10d | Expected: 0 | Status: %s", o_PC, (o_PC === 0) ? "OK" : "ERR");
        i_reset = 0; #10;

        $finish;
    end

endmodule