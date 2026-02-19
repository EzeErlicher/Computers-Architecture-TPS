module hazard_detection_unit
(
//Inputs
input wire i_ID_EX_MemRead,
input wire [4:0]i_ID_EX_rd,
input wire [4:0]i_IF_ID_rs1,
input wire [4:0]i_IF_ID_rs2,

//Outputs
output wire o_IF_ID_write,
output wire o_PC_write,
output wire o_mux_control
);

reg IF_ID_write;
reg PC_write;
reg mux_control;

always @(*)begin
    if (i_ID_EX_rd && ((i_ID_EX_rd == i_IF_ID_rs1)||(i_ID_EX_rd == i_IF_ID_rs2))  )begin
        // stall pipeline
        IF_ID_write = 1'b0;
        PC_write =1'b0;
        mux_control =1'b1;
    end
    
    else begin
        IF_ID_write = 1'b1;
        PC_write =1'b1;
        mux_control =1'b0;
    end
    
end

assign o_IF_ID_write = o_IF_ID_write;
assign o_PC_write = PC_write;
assign o_mux_control = mux_control;

endmodule