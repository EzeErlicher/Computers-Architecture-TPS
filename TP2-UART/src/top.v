module top#(
    parameter NB_DATA = 8,
    parameter NB_ALU_OP = 6
)
(
    input wire   i_clk,
    input wire   i_reset,
    input wire   i_rx,
    output wire  o_tx,
);

baud_gen #(
    .NB_DATA(NB_DATA)
) baud_unit (
    .i_clk(i_clk),
    .o_s_tick()
);

rx_mod #(
    .NB_DATA(NB_DATA),
    .NB_STOP(1)
) rx_unit (
    .i_clk(i_clk),
    .i_s_tick(),
    .i_rx(i_rx),
    .i_reset(i_reset),
    .o_dout(),
    .o_rx_done_tick()
);

// TX MODULE

interface #(
    .NB_DATA(NB_DATA),
    .NB_ALU_OP(NB_ALU_OP)
) interface_unit (
    .i_clk(i_clk),
    .i_rx_data(),
    .i_tx_done(),
    .i_alu_res(),
    .o_tx_start(),
    .o_tx_data(),
    .o_alu_OP(),
    .o_alu_A(),
    .o_alu_B()
);

alu #(
    .NB_DATA(NB_DATA),
    .NB_OP(NB_ALU_OP)
) alu_unit (
    .i_data_a(),
    .i_data_b(),
    .i_operation_code(),
    .o_result(),
    .o_overflow(),
    .o_zero()
);

endmodule