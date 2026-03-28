module IF_test_module #(
    parameter NB_ADDRESS     = 10,
    parameter NB_INSTRUCTION = 32,
    parameter NB_PC          = 10,
    parameter IF_ID_SIZE     = 38 + NB_PC
)
(
    // Clock / Reset
    input wire i_clk,
    input wire i_reset,

    // IF stage control
    input wire i_PC_source,
    input wire i_PC_enable,
    input wire [NB_ADDRESS-1:0] i_EX_adder_result,

    // Instruction memory write interface (for debug loading)
    input wire [NB_ADDRESS-1:0]     i_instruct_to_write_addr,
    input wire [NB_INSTRUCTION-1:0] i_instruct_to_write,
    input wire                      i_instruct_mem_write_enable,
    input wire [1:0]                i_instruct_mem_write_byte_enable,

    // Pipeline control
    input wire [1:0] i_pipeline_mode,
    input wire       i_execute_instruct,

    // IF/ID latch control
    input wire i_IF_flush,
    input wire i_IF_ID_write,

    // Outputs
    output wire [IF_ID_SIZE-1:0] o_IF_ID_data
);

////////////////////////////////////////////////////////////
// Internal wiring
////////////////////////////////////////////////////////////

wire [NB_ADDRESS-1:0] IF_PC;
wire [NB_INSTRUCTION-1:0] IF_instruction;

////////////////////////////////////////////////////////////
// IF STAGE
////////////////////////////////////////////////////////////

instruction_fetch_top #(
    .NB_ADDRESS(NB_ADDRESS),
    .NB_INSTRUCTION(NB_INSTRUCTION)
) IF_stage (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_PC_source(i_PC_source),
    .i_PC_enable(i_PC_enable),
    .i_EX_adder_result(i_EX_adder_result),

    .i_instruct_to_write_addr(i_instruct_to_write_addr),
    .i_instruct_to_write(i_instruct_to_write),
    .i_instruct_mem_write_enable(i_instruct_mem_write_enable),
    .i_instruct_mem_write_byte_enable(i_instruct_mem_write_byte_enable),

    .i_pipeline_exec_mode(i_pipeline_mode),
    .i_execute_instruct(i_execute_instruct),

    .o_PC(IF_PC),
    .o_instruction(IF_instruction)
);

////////////////////////////////////////////////////////////
// IF / ID LATCH
////////////////////////////////////////////////////////////

IF_ID_latch_IF_only #(
    .NB_INSTRUCT(NB_INSTRUCTION),
    .NB_PC(NB_PC)
) IF_ID_latch (
    .i_clk(i_clk),
    .i_reset(i_reset),

    .i_IF_flush(i_IF_flush),
    .i_IF_ID_write(i_IF_ID_write),

    .i_PC(IF_PC),
    .i_instruction(IF_instruction),

    .i_pipeline_mode(i_pipeline_mode),
    .i_execute_instruct(i_execute_instruct),

    .o_IF_ID_data(o_IF_ID_data)
);

////////////////////////////////////////////////////////////
// Optional direct visibility of IF outputs
////////////////////////////////////////////////////////////


endmodule