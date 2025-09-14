module alu
#(
    parameter in_data_length=8,
    parameter op_code_length=6             
)

(
    input wire signed [in_data_length-1:0] operand_1,
    input wire signed [in_data_length-1:0] operand_2,
    input wire [op_code_length-1:0] operation_code,
    output wire signed [in_data_length-1:0] result
);


endmodule
