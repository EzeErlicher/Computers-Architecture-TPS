module alu
#(
    parameter NB_DATA=8,
    parameter NB_OP=6             
)
(
    input wire signed  [NB_DATA-1:0] i_data_a,
    input wire signed  [NB_DATA-1:0] i_data_b,
    input wire         [NB_OP-1:0]   i_operation_code,
    output wire signed [NB_DATA-1:0] o_result
);

reg signed [NB_DATA-1:0] result;

always @(*) begin
    case (i_operation_code)
        6'b100000: result = i_data_a + i_data_b; // ADD
        6'b100010: result = i_data_a - i_data_b; // SUB
        6'b100100: result = i_data_a * i_data_b; // AND
        6'b100101: result = i_data_a / i_data_b; // OR
        default: result = {NB_DATA{1'b0}};
    endcase
end

assign o_result = result;

endmodule

// ToDo: Add more operations
// ToDo: Bit de Carry? Bit de Zero?