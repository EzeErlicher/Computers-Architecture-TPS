module pipeline #(
    parameter NB_ADDRESS             = 10,
    parameter NB_INSTRUCTION         = 32,
    parameter NB_PC                  = 10,
    parameter IF_ID_SIZE             = 38 + NB_PC,
    parameter INSTRUCT_MEM_ADDR_BITS = 10
)
(
    input  wire i_clk,
    input  wire i_reset,

    // UART pins to PC
    input wire i_rx_data,
    output wire o_tx_data
    
);

////////////////////////////////////////////////
// UART <-> Debug wires
////////////////////////////////////////////////

wire [7:0] rx_data;
wire       rx_done;

wire [7:0] tx_data;
wire       tx_done;
wire       tx_start;


////////////////////////////////////////////////
// IF stage wires
////////////////////////////////////////////////

wire [IF_ID_SIZE-1:0]     IF_ID_content;

////////////////////////////////////////////////
// Debug -> IF control signals
////////////////////////////////////////////////

wire [7:0]                        instruct_byte_to_write;
wire [INSTRUCT_MEM_ADDR_BITS-1:0] instruct_to_write_addr;
wire                              instruct_mem_write_enable;
wire [1:0]                        instruct_mem_write_byte_enable;
wire [1:0]                        pipeline_exec_mode;
wire                              execute_instruct;

////////////////////////////////////////////////
// Additional control signals
////////////////////////////////////////////////

wire program_finished;

assign program_finished = 1'b0;

////////////////////////////////////////////////
// UART module
////////////////////////////////////////////////

uart_mod uart_unit
(
    .i_clk_in       (i_clk),
    .i_reset        (i_reset),

    .i_rx (i_rx_data),
    .o_tx (o_tx_data),

    .o_rx_data      (rx_data),
    .o_rx_done_tick (rx_done),

    .i_tx_start     (tx_start),
    .i_tx_data      (tx_data),
    .o_tx_done_tick (tx_done)
);

////////////////////////////////////////////////
// Debug Unit
////////////////////////////////////////////////

debug_unit_IF_only #(
    .INSTRUCT_MEM_WIDTH     (NB_INSTRUCTION),
    .INSTRUCT_MEM_ADDR_BITS (INSTRUCT_MEM_ADDR_BITS),
    .IF_ID_SIZE             (IF_ID_SIZE)
)
debug_unit
(
    .I_clk      (i_clk),
    .I_reset    (i_reset),

    // UART side
    .I_rx_data  (rx_data),
    .I_rx_done  (rx_done),
    .I_tx_done  (tx_done),
    .O_tx_data  (tx_data),
    .O_tx_start (tx_start),

    // Pipeline side
    .I_IF_ID_content (IF_ID_content),
    .I_program_finished(program_finished),

    .O_instruct_byte_to_write      (instruct_byte_to_write),
    .O_instruct_to_write_addr      (instruct_to_write_addr),
    .O_instruct_mem_write_enable   (instruct_mem_write_enable),
    .O_instruct_mem_write_byte_enable (instruct_mem_write_byte_enable),
    .O_pipeline_exec_mode          (pipeline_exec_mode),
    .O_execute_instruct            (execute_instruct)
);

////////////////////////////////////////////////
// IF stage + IF/ID latch module
////////////////////////////////////////////////

IF_test_module #(
    .NB_ADDRESS     (NB_ADDRESS),
    .NB_INSTRUCTION (NB_INSTRUCTION),
    .NB_PC          (NB_PC),
    .IF_ID_SIZE     (IF_ID_SIZE)
)
IF_block
(
    .i_clk(i_clk),
    .i_reset(i_reset),

    .i_PC_source(1'b0),
    .i_PC_enable(1'b1),
    .i_EX_adder_result({NB_ADDRESS{1'b0}}),

    .i_instruct_to_write_addr(instruct_to_write_addr),
    .i_instruct_to_write({24'b0, instruct_byte_to_write}),
    .i_instruct_mem_write_enable(instruct_mem_write_enable),
    .i_instruct_mem_write_byte_enable(instruct_mem_write_byte_enable),

    .i_pipeline_mode(pipeline_exec_mode),
    .i_execute_instruct(execute_instruct),

    .i_IF_flush(1'b0),
    .i_IF_ID_write(1'b1),

    .o_IF_ID_data(IF_ID_content)
);

endmodule