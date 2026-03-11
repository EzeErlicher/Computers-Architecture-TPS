module instruction_fetch_top #(
    parameter NB_ADDRESS = 10,
    parameter NB_INSTRUCTION  = 32
)
(
    input wire               i_clk,
    input wire               i_reset,
    input wire               i_PC_source,
    input wire               i_PC_enable,
    input wire [NB_ADDRESS-1:0] i_EX_adder_result,

    input wire                      i_instruct_mem_write_enable,
    input wire [NB_ADDRESS-1:0]        i_instruct_mem_write_address,
    input wire [NB_INSTRUCTION-1:0] i_instruct_mem_write_instruct,
    input wire [1:0]                i_instruct_mem_write_byte_enable,
         
    output wire [NB_ADDRESS-1:0]        o_PC,
    output wire [NB_INSTRUCTION-1:0] o_instruction
);

wire [NB_ADDRESS-1:0] out_IF_adder;
wire [NB_ADDRESS-1:0] out_mux;

mux2to1 #(
    .NB_DATA(NB_INSTRUCTION)
) mux_unit
(
    .i_data_A(out_IF_adder),
    .i_data_B(i_EX_adder_result),
    .i_select(i_PC_source),
    .o_data(out_mux)
);

PC #(
    .NB_PC(NB_ADDRESS)
) pc_unit
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_PC_enable(i_PC_enable),
    .i_address(out_mux),
    .o_PC(o_PC)
);

adder #(
    .NB_DATA(NB_ADDRESS)
) adder_unit
(
    .i_data_A(o_PC),
    .i_data_B({{(NB_ADDRESS-3){1'b0}}, 3'd4}),
    .o_result(out_IF_adder)
);

instruction_memory #(
    .NB_ADDRESS(NB_ADDRESS),
    .INSTR_WIDTH(NB_INSTRUCTION)
) instruct_memory (
    .i_clk(i_clk),
    .i_read_address(o_PC),
    .i_write_enable(i_instruct_mem_write_enable),
    .i_write_address(i_instruct_mem_write_address),
    .i_write_instruction(i_instruct_mem_write_instruct),
    .i_write_byte_enable(i_instruct_mem_write_byte_enable),
    .o_instruction(o_instruction)
);

endmodule