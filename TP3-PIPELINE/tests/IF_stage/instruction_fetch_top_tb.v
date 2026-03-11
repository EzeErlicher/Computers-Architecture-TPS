`timescale 1ns / 1ps

module instruction_fetch_top_tb;

    parameter NB_ADDRESS = 10;
    parameter NB_INSTRUCTION  = 32;

    reg                  i_clk;
    reg                  i_reset;
    reg                  i_PC_source;
    reg                  i_PC_enable;
    reg [NB_ADDRESS-1:0] i_EX_adder_result;

    reg                      i_instruct_mem_write_enable;
    reg [NB_ADDRESS-1:0]     i_instruct_mem_write_address;
    reg [NB_INSTRUCTION-1:0] i_instruct_mem_write_instruct;
    reg [1:0]                i_instruct_mem_write_byte_enable;

    wire [NB_ADDRESS-1:0]     o_PC;
    wire [NB_INSTRUCTION-1:0] o_instruction;

    instruction_fetch_top #(
        .NB_ADDRESS(NB_ADDRESS),
        .NB_INSTRUCTION(NB_INSTRUCTION)
    ) IF_module (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_PC_source(i_PC_source),
        .i_PC_enable(i_PC_enable),
        .i_EX_adder_result(i_EX_adder_result),
        .i_instruct_mem_write_enable(i_instruct_mem_write_enable),
        .i_instruct_mem_write_address(i_instruct_mem_write_address),
        .i_instruct_mem_write_instruct(i_instruct_mem_write_instruct),
        .i_instruct_mem_write_byte_enable(i_instruct_mem_write_byte_enable),
        .o_PC(o_PC),
        .o_instruction(o_instruction)
    );

    always #10 i_clk = ~i_clk;

    // Initialize Instruction Memory with test pattern
    task write_instruction(input [NB_ADDRESS-1:0] addr, input [NB_INSTRUCTION-1:0] instr);
        integer byte_idx;
        begin
            i_instruct_mem_write_enable = 1;
            i_instruct_mem_write_address = addr;
            i_instruct_mem_write_instruct = instr;
            for (byte_idx = 0; byte_idx < 4; byte_idx = byte_idx + 1) begin
                i_instruct_mem_write_byte_enable = byte_idx[1:0];
                #20;
            end
            i_instruct_mem_write_enable = 0;
            #20;
            $display("[WRITE] Addr = %d, Instruction = %h", addr, instr);
        end
    endtask

    reg [NB_INSTRUCTION-1:0] instructions [0:15];
    integer i;

    initial begin
        #40; // Initial delay for stabilization

        // Reset and initialize
        i_clk = 0;
        i_reset = 1;
        i_PC_source = 0;
        i_PC_enable = 0;
        i_EX_adder_result = 0;
        i_instruct_mem_write_enable = 0;
        i_instruct_mem_write_address = 0;
        i_instruct_mem_write_instruct = 0;
        #20;
        
        // Test 1: Initialize Instruction Memory
        // Write a sequence of known instructions to memory (e.g., addr 0->instr_0, addr 1->instr_1, etc.)
        // Verify all writes complete
        $display("\n===== INSTRUCTION FETCH TOP TESTBENCH =====\n");
        $display("--- TEST 1: Initialize Instruction Memory ---");
        for (i = 0; i < 12; i = i + 1) begin
            instructions[i] = $random;
            write_instruction(i*4, instructions[i]);
        end

        // Release reset and enable PC
        i_reset = 0;
        i_PC_enable = 1;
        i_PC_source = 0; // Increment from adder

        // Test 2: PC Sequential Increment
        // Enable PC, release reset, let PC increment on each clock cycle
        // Verify o_PC goes 0 -> 4 -> 8 -> 12... and o_instruction follows the written sequence
        $display("--- TEST 2: PC Sequential Increment ---");
        for (i = 0; i < 8; i = i + 1) begin
            $display("[FETCH] Cycle = %1d, PC = %d, Instruction = %h | Expected = %h | Match: %s", 
                     i, o_PC, o_instruction, instructions[i], (o_instruction == instructions[i]) ? "PASS" : "FAIL");
            #20; // Wait for PC to update and instruction to be fetched
        end

        // Test 3: PC Hold (i_PC_enable = 0)
        // Set i_PC_enable low, release reset
        // Verify o_PC stays at 0 and o_instruction remains constant (memory latency considered)
        $display("--- TEST 3: PC Hold (i_PC_enable = 0) ---");
        i_PC_enable = 0;
        $display("[HOLD] PC = %d, Instruction = %h (should remain constant)", o_PC, o_instruction);
        #20;
        $display("[HOLD] PC = %d, Instruction = %h (should remain constant)", o_PC, o_instruction);
        #20;
        $display("[HOLD] PC = %d, Instruction = %h (should remain constant)", o_PC, o_instruction);

        $display("Actual Time %t", $time);

        // Test 4: Branch (i_PC_source = 1)
        // Set i_PC_source=1, apply i_EX_adder_result (branch target), trigger PC update
        // Verify o_PC jumps to branch address and o_instruction reflects that memory location
        $display("--- TEST 4: Branch Jump (i_PC_source = 1) ---");
        i_EX_adder_result = 10'd0;
        #1;
        i_PC_source = 1;
        i_PC_enable = 1;
        #19;
        $display("Actual Time %t", $time);
        $display("[BRANCH] Target = %d, PC = %d, Instruction = %h | Expected = %h | Match: %s",
                 10'd0, o_PC, o_instruction, instructions[0], (o_instruction == instructions[0]) ? "PASS" : "FAIL");
        #1;
        $display("Actual Time %t", $time);
        $display("[BRANCH] Target = %d, PC = %d, Instruction = %h | Expected = %h | Match: %s",
                 10'd0, o_PC, o_instruction, instructions[0], (o_instruction == instructions[0]) ? "PASS" : "FAIL");


//
//        // Test 5: Sequential Fetch After Branch
//        // After branch, set i_PC_source=0 (return to normal increment)
//        // Verify PC resumes incrementing from branch target, fetching correct instruction sequence
//        $display("--- TEST 5: Sequential Fetch After Branch ---");
//        i_PC_source = 0;
//        #20;
//        for (i = 0; i < 4; i = i + 1) begin
//            //$display("[FETCH] Cycle = %1d, PC = %d, Instruction = %h | Expected = %h | Match: %s",
//            //         i, o_PC, o_instruction, instructions[4+i], (o_instruction == instructions[4+i]) ? "PASS" : "FAIL");
//            $display("[FETCH] PC = %d - Expected = %d | Instruction = %h - Expected = %h", o_PC, 10'd4 + i*4, o_instruction, instructions[4+i]);
//            #20;
//        end

        $finish;
    end
endmodule