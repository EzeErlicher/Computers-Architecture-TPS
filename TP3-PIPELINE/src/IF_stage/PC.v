module PC #(
    parameter NB_PC = 10
)
(
//Inputs
input wire             i_clk,
input wire             i_reset,
input wire             i_PC_enable,
input wire [NB_PC-1:0] i_address,

//Outputs
output wire [NB_PC-1:0] o_PC
);

reg [NB_PC-1:0] out_PC;

always@(posedge i_clk) begin
    
    if(i_reset) begin
        out_PC <= 0;
    end
    
    else begin
        if(i_PC_enable)begin
            out_PC<=i_address;
        end
    end    
end

assign o_PC=out_PC;

endmodule