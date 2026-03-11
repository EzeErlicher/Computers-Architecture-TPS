`timescale 1ns / 1ps

module instruction_memory_tb;

    localparam NB_ADDRESS = 10;
    localparam INSTR_WIDTH = 32;            // Instruction width (4 bytes)
    localparam IMEM_DEPTH = 2**NB_ADDRESS;

    reg                     i_clk;
    reg  [NB_ADDRESS-1:0]    i_read_address;
    reg                     i_write_enable;
    reg  [NB_ADDRESS-1:0]    i_write_address;
    reg  [INSTR_WIDTH-1:0]  i_write_instruction;
    reg  [1:0]              i_write_byte_enable;
    wire [INSTR_WIDTH-1:0]  o_instruction;

    reg  [INSTR_WIDTH-1:0]  expected_data;
    reg  [NB_ADDRESS-1:0]    addr;

    integer i;
    integer test_pass = 0;
    integer test_fail = 0;

    instruction_memory #(
        .NB_ADDRESS(NB_ADDRESS),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_read_address(i_read_address),
        .i_write_enable(i_write_enable),
        .i_write_address(i_write_address),
        .i_write_instruction(i_write_instruction),
        .i_write_byte_enable(i_write_byte_enable),
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
            i_write_byte_enable = 2'b00;
            #20;
            i_write_byte_enable = 2'b01;
            #20;
            i_write_byte_enable = 2'b10;
            #20;
            i_write_byte_enable = 2'b11;
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

        // TEST 2: Edge Cases (Address 0 and Max)
        $display("\n--- TEST 2: Edge Cases ---");
        
        // Test at address 0
        addr = 0;
        expected_data = $random;
        
        i_write_address = addr;
        i_write_instruction = expected_data;
        i_write_enable = 1;
        for (i = 0; i < 4; i = i + 1) begin
            i_write_byte_enable = i[1:0];
            #20;
        end
        i_write_enable = 0;
        i_read_address = addr;
        #20;
        
        $display("[MINVAL] Addr = %4d, Data = %h -> Read = %h | Status: %s", 
                 addr, expected_data, o_instruction, 
                 (o_instruction === expected_data) ? "OK" : "ERR");
        if (o_instruction === expected_data)
            test_pass = test_pass + 1;
        else
            test_fail = test_fail + 1;
        
        // Test at max address
        addr = (IMEM_DEPTH - 4);
        expected_data = $random;
        
        i_write_address = addr;
        i_write_instruction = expected_data;
        i_write_enable = 1;
        for (i = 0; i < 4; i = i + 1) begin
            i_write_byte_enable = i[1:0];
            #20;
        end
        i_write_enable = 0;
        i_read_address = addr;
        #20;
        
        $display("[MAXVAL] Addr = %4d, Data = %h -> Read = %h | Status: %s", 
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