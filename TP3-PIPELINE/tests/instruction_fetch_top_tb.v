`timescale 1ns / 1ps

module instruction_fetch_top_tb;

    parameter PC_BITS = 10,
    parameter NB_INSTRUCTION  = 32

    reg               i_clk;
    reg               i_reset;
    reg               i_PC_source;
    reg               i_PC_enable;
    reg [PC_BITS-1:0] i_EX_adder_result;

    reg                      i_instruct_mem_write_enable,
    reg [PC_BITS-1:0]        i_instruct_mem_write_address,
    reg [NB_INSTRUCTION-1:0] i_instruct_mem_write_instruct,

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

    // Initialization: write instructions to Instruction Memory

    // Test PC: 
    // 1. Write to PC and check if it updates correctly
    // 2. Check if PC increments correctly when i_PC_source=0 && i_PC_enable=1
    // 3. Check if PC updates to EX adder result when i_PC_source=1 && i_PC_enable=1
    // 4. Check if PC holds value when i_PC_enable=0
    // 5. Check reset

    // Integration test: Write n instructions to memory and read them back to check if the correct instruction is output based on the PC value


endmodule