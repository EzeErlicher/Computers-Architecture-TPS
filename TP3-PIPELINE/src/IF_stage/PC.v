module PC #(
parameter NB_PC = 10
)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_PCWrite,
input wire [NB_PC-1:0]i_PC,
input wire [1:0]i_pipeline_exec_mode,
input wire i_execute_instruct,

//Outputs
output wire[NB_PC-1:0]o_PC
);

localparam CONT_MODE = 2'b01;
localparam STEP_MODE = 2'b11;

reg [NB_PC-1:0] out_PC;

always@(posedge i_clk,posedge i_reset) begin
    
    if(i_reset) begin
        out_PC <= 0;
    end
    
    else begin
        if((i_pipeline_exec_mode == CONT_MODE || (i_pipeline_exec_mode == STEP_MODE && i_execute_instruct)) && i_PCWrite)begin
            out_PC<=i_PC;    
        end
    end    
end

assign o_PC=out_PC;

endmodule