module interface #(

    parameter NB_DATA = 8,
    parameter NB_ALU_OP = 6
)
(
    input wire                  i_clk,
    input wire  [NB_DATA-1:0]   i_rx_data,
    input wire                  i_tx_done,

    input wire  [NB_DATA-1:0]   i_alu_res,

    output wire                 o_tx_start,
    output wire [NB_DATA-1:0]   o_tx_data,

    output wire [NB_ALU_OP-1:0] o_alu_OP,
    output wire [NB_DATA-1:0]   o_alu_A,
    output wire [NB_DATA-1:0]   o_alu_B,
);



endmodule