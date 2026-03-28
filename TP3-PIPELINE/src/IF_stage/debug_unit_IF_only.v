module debug_unit_IF_only #(
    parameter INSTRUCT_MEM_WIDTH     = 32,
    parameter INSTRUCT_MEM_ADDR_BITS = 10,
    parameter IF_ID_SIZE             = 44
)
(
    input  wire        I_clk,
    input  wire        I_reset,
    // UART side
    input  wire [7:0]  I_rx_data,
    input  wire        I_rx_done,
    input  wire        I_tx_done,
    output wire [7:0]  O_tx_data,
    output wire        O_tx_start,
    
    // Pipeline side
    input  wire [IF_ID_SIZE-1:0] I_IF_ID_content,
    input  wire                  I_program_finished,
    output wire [7:0]                        O_instruct_byte_to_write,
    output wire [INSTRUCT_MEM_ADDR_BITS-1:0] O_instruct_to_write_addr,
    output wire                              O_instruct_mem_write_enable,
    output wire [1:0]                        O_instruct_mem_write_byte_enable,
    output wire [1:0]                        O_pipeline_exec_mode,
    output wire                              O_execute_instruct
);

// Internal wires
wire [INSTRUCT_MEM_WIDTH-1:0] instruct_or_command;
wire rx_buffer_done;
wire [INSTRUCT_MEM_WIDTH-1:0] pipeline_info;
wire tx_buffer_start;
wire tx_buffer_empty;

uart_pipeline_interface_IF_only #(
    .INSTRUCT_MEM_WIDTH     (INSTRUCT_MEM_WIDTH),
    .INSTRUCT_MEM_ADDR_BITS (INSTRUCT_MEM_ADDR_BITS),
    .IF_ID_SIZE             (IF_ID_SIZE)
) uart_pipeline_interface_block (
    .i_clk                        (I_clk),
    .i_reset                      (I_reset),
    .i_instruct_or_command        (instruct_or_command),
    .i_rx_buffer_done             (rx_buffer_done),
    .i_tx_buffer_empty            (tx_buffer_empty),
    .i_program_finished           (I_program_finished),
    .i_IF_ID_content              (I_IF_ID_content),
    .o_instruct_byte_to_write     (O_instruct_byte_to_write),
    .o_instruct_to_write_addr     (O_instruct_to_write_addr),
    .o_instruct_mem_write_enable  (O_instruct_mem_write_enable),
    .o_instruct_mem_write_byte_enable (O_instruct_mem_write_byte_enable),
    .o_pipeline_info              (pipeline_info),
    .o_tx_buffer_start            (tx_buffer_start),
    .o_pipeline_exec_mode         (O_pipeline_exec_mode),
    .o_execute_instruct           (O_execute_instruct)
);

rx_buffer #(
    .INSTRUCT_MEM_WIDTH(INSTRUCT_MEM_WIDTH)
) rx_buffer_block (
    .i_clk               (I_clk),
    .i_reset             (I_reset),
    .i_rx_done           (I_rx_done),
    .i_rx_data           (I_rx_data),
    .o_instruct_or_command(instruct_or_command),
    .o_rx_buffer_done    (rx_buffer_done)
);

tx_buffer #(
    .INSTRUCT_MEM_WIDTH(INSTRUCT_MEM_WIDTH)
) tx_buffer_block (
    .i_clk            (I_clk),
    .i_reset          (I_reset),
    .i_tx_buffer_start(tx_buffer_start),
    .i_tx_done        (I_tx_done),
    .i_pipeline_info  (pipeline_info),
    .o_tx_buffer_empty(tx_buffer_empty),
    .o_tx_data        (O_tx_data),
    .o_tx_start       (O_tx_start)
);

endmodule