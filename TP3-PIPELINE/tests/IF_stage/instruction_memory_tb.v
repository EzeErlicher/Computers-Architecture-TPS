`timescale 1ns / 1ps

module instruction_memory_tb;

    parameter PC_BITS = 8;
    parameter IMEM_WIDTH = 32;
    parameter IMEM_DEPTH = 2**PC_BITS;

    reg                     i_clk;
    reg  [PC_BITS-1:0]      i_read_address;
    reg                     i_write_enable;
    reg  [PC_BITS-1:0]      i_write_address;
    reg  [IMEM_WIDTH-1:0]   i_write_instruction;
    wire [IMEM_WIDTH-1:0]   o_instruction;

    reg  [IMEM_WIDTH-1:0]   expected_data;
    reg  [PC_BITS-1:0]      addr;
    reg  [7:0]              i;
    reg  [31:0]             test_pass = 0;
    reg  [31:0]             test_fail = 0;

    instruction_memory #(
        .PC_BITS(PC_BITS),
        .IMEM_WIDTH(IMEM_WIDTH),
        .IMEM_DEPTH(IMEM_DEPTH)
    ) dut (
        .i_clk(i_clk),
        .i_read_address(i_read_address),
        .i_write_enable(i_write_enable),
        .i_write_address(i_write_address),
        .i_write_instruction(i_write_instruction),
        .o_instruction(o_instruction)
    );

    always #10 i_clk = ~i_clk;
    
    initial begin
        #80; // Initial delay for stabilization

        i_clk = 0;
        i_read_address = 0;
        i_write_enable = 0;
        i_write_address = 0;
        i_write_instruction = 0;

        #10;
        $display("\n===== INSTRUCTION MEMORY TESTBENCH =====\n");

        // TEST 1: Multiple Random Write/Read Operations
        $display("--- TEST 1: Random Write/Read Operations ---");
        for (i = 0; i < 10; i = i + 1) begin
            addr = $random % IMEM_DEPTH;
            expected_data = $random;
            
            i_write_address = addr;
            i_write_instruction = expected_data;
            i_write_enable = 1;
            #20;
            i_write_enable = 0;
            i_read_address = addr;
            #20;
            
            $display("[WRITE] Addr = %4d, Data = %h -> Read = %h | Status: %s", 
                     addr, expected_data, o_instruction, 
                     (o_instruction === expected_data) ? "OK" : "ERR");
            
            if (o_instruction === expected_data)
                test_pass = test_pass + 1;
            else
                test_fail = test_fail + 1;
        end

        // TEST 2: Address Range Verification
        $display("\n--- TEST 2: Address Range Verification ---");
        for (i = 0; i < 4; i = i + 1) begin
            addr = (i * 256);
            expected_data = {16'hAAAA, i[7:0], 8'h55};
            
            i_write_address = addr;
            i_write_instruction = expected_data;
            i_write_enable = 1;
            #20;
            i_write_enable = 0;
            i_read_address = addr;
            #20;
            
            $display("[RANGE] Addr = %4d, Data = %h -> Read = %h | Status: %s", 
                     addr, expected_data, o_instruction, 
                     (o_instruction === expected_data) ? "OK" : "ERR");
            
            if (o_instruction === expected_data)
                test_pass = test_pass + 1;
            else
                test_fail = test_fail + 1;
        end

        // TEST 3: Edge Cases
        $display("\n--- TEST 3: Edge Cases ---");
        
        // Test at address 0
        addr = 10'd0;
        expected_data = 32'hDEADBEEF;
        i_write_address = addr;
        i_write_instruction = expected_data;
        i_write_enable = 1;
        #20;
        i_write_enable = 0;
        i_read_address = addr;
        #20;
        $display("[EDGE] Addr = %4d, Data = %h -> Read = %h | Status: %s", 
                 addr, expected_data, o_instruction, 
                 (o_instruction === expected_data) ? "OK" : "ERR");
        if (o_instruction === expected_data)
            test_pass = test_pass + 1;
        else
            test_fail = test_fail + 1;
        
        // Test at max address
        addr = (IMEM_DEPTH - 1);
        expected_data = 32'hCAFEBABE;
        i_write_address = addr;
        i_write_instruction = expected_data;
        i_write_enable = 1;
        #20;
        i_write_enable = 0;
        i_read_address = addr;
        #20;
        $display("[EDGE] Addr = %4d, Data = %h -> Read = %h | Status: %s", 
                 addr, expected_data, o_instruction, 
                 (o_instruction === expected_data) ? "OK" : "ERR");
        if (o_instruction === expected_data)
            test_pass = test_pass + 1;
        else
            test_fail = test_fail + 1;

        $display("\n========================================");
        $display("SUMMARY: PASSED = %d | FAILED = %d", test_pass, test_fail);
        $display("========================================\n");

        $finish;
    end

endmodule