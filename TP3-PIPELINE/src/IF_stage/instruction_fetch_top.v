module instruction_fetch_top #(
    parameter PC_BITS = 10,
    parameter NB_INSTRUCTION  = 32
)
(
    input wire               i_clk,
    input wire               i_reset,
    input wire               i_PC_source,
    input wire               i_PC_enable,
    input wire [PC_BITS-1:0] i_EX_adder_result,

    input wire                      i_instruct_mem_write_enable,
    input wire [PC_BITS-1:0]        i_instruct_mem_write_address,
    input wire [NB_INSTRUCTION-1:0] i_instruct_mem_write_instruct,
         
    output wire [PC_BITS-1:0]        o_PC,
    output wire [NB_INSTRUCTION-1:0] o_instruction
);

wire [PC_BITS-1:0] out_IF_adder;
wire [PC_BITS-1:0] out_mux;

mux2to1 #(
    .NB_DATA(PC_BITS)
) mux_unit
(
    .i_data_A(out_IF_adder),
    .i_data_B(i_EX_adder_result),
    .i_select(i_PC_source),
    .o_data(out_mux)
);

PC #(
    .NB_PC(PC_BITS)
) pc_unit
(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_PC_enable(i_PC_enable),
    .i_address(out_mux),
    .o_address(o_PC)
);

adder #(
    .NB_DATA(PC_BITS)
) adder_unit
(
    .i_data_A(o_PC),
    .i_data_B({{(PC_BITS-3){1'b0}}, 3'd4}),
    .o_result(out_IF_adder)
);

instruction_memory #(
    .PC_BITS(PC_BITS),
    .IMEM_WIDTH(8)
) instruct_memory
(
    .i_clk(i_clk),
    .i_address(i_instruct_mem_write_address),
    .i_instruct_mem_write_enable(i_instruct_mem_write_enable),
    .i_instruction(i_instruct_mem_write_instruct),
    .o_instruction(o_instruction)
);

endmodule