`timescale 1ns / 1ps

module instruction_fetch_top_tb;

    parameter PC_BITS = 10;
    parameter NB_INSTRUCTION  = 32;

    reg               i_clk;
    reg               i_reset;
    reg               i_PC_source;
    reg               i_PC_enable;
    reg [PC_BITS-1:0] i_EX_adder_result;

    reg                      i_instruct_mem_write_enable;
    reg [PC_BITS-1:0]        i_instruct_mem_write_address;
    reg [NB_INSTRUCTION-1:0] i_instruct_mem_write_instruct;

    wire [PC_BITS-1:0]        o_PC;
    wire [NB_INSTRUCTION-1:0] o_instruction;

    instruction_fetch_top #(
        .PC_BITS(PC_BITS),
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
        .o_PC(o_PC),
        .o_instruction(o_instruction)
    );

    always #10 i_clk = ~i_clk;

    // Test 1: Initialize Instruction Memory
    // Write a sequence of known instructions to memory (e.g., addr 0->instr_0, addr 1->instr_1, etc.)
    // Verify all writes complete

    // Test 2: PC Sequential Increment
    // Enable PC, release reset, let PC increment on each clock cycle
    // Verify o_PC goes 0 -> 1 -> 2 -> 3... and o_instruction follows the written sequence

    // Test 3: PC Hold (i_PC_enable = 0)
    // Set i_PC_enable low, release reset
    // Verify o_PC stays at 0 and o_instruction remains constant (memory latency considered)

    // Test 4: Branch (i_PC_source = 1)
    // Set i_PC_source=1, apply i_EX_adder_result (branch target), trigger PC update
    // Verify o_PC jumps to branch address and o_instruction reflects that memory location

    // Test 5: Sequential Fetch After Branch
    // After branch, set i_PC_source=0 (return to normal increment)
    // Verify PC resumes incrementing from branch target, fetching correct instruction sequence

endmodule