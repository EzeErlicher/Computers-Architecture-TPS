module alu

#(
    parameter NB_DATA=8,
    parameter NB_OP=6             
)

(
    input wire signed  [NB_DATA-1:0] i_data_a,
    input wire signed  [NB_DATA-1:0] i_data_b,
    input wire         [NB_OP-1:0]   i_operation_code,
    output wire signed [NB_DATA-1:0] o_result,
    output wire o_overflow,
    output wire o_zero
);


reg signed [NB_DATA-1:0] result; 
reg ovflw;
reg z;



always @(*) begin


    result  = {NB_DATA{1'b0}};
    ovflw   = 1'b0; 

    case (i_operation_code)


        6'b100000: // ADD

            begin
                result = i_data_a + i_data_b; 
                ovflw = (i_data_a[NB_DATA-1]== i_data_b[NB_DATA-1]) & (i_data_a[NB_DATA-1]!=result[NB_DATA-1]);
            end  

        6'b100010: // SUB

            begin
                result = i_data_a - i_data_b;
                ovflw = (i_data_a[NB_DATA-1]!= i_data_b[NB_DATA-1]) & (i_data_a[NB_DATA-1]!=result[NB_DATA-1]);
            end


        6'b100100: result = i_data_a & i_data_b; // AND

        6'b100101: result = i_data_a | i_data_b; // OR

        6'b100110: result = i_data_a ^ i_data_b; //XOR

        6'b000011: result = i_data_a >>> i_data_b; //SRA

        6'b000010: result = i_data_a >> i_data_b; //SRL

        6'b100111: result = ~(i_data_a | i_data_b); //NOR

        default: result = {NB_DATA{1'b0}};


    endcase

    z = (result == {NB_DATA{1'b0}});


end


assign o_result = result;
assign o_overflow = ovflw;
assign o_zero = z;


endmodule
