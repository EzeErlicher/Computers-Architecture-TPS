module hazard_detection_unit
(
//Inputs
input wire i_ID_EX_MemRead,
input wire [4:0]i_ID_EX_rd,  // rd in EX
input wire [4:0]i_IF_ID_rs1, // rs1 in ID
input wire [4:0]i_IF_ID_rs2, // rs2 in ID

//Outputs
output wire o_IF_ID_write,
output wire o_PC_write,
output wire o_flush_ctrl_signals
);

reg IF_ID_write;
reg PC_write;
reg flush_ctrl_signals;

always @(*)begin
    if (i_ID_EX_rd && ((i_ID_EX_rd == i_IF_ID_rs1)||(i_ID_EX_rd == i_IF_ID_rs2))  )begin
        // stall pipeline
        IF_ID_write = 1'b0;
        PC_write =1'b0;
        flush_ctrl_signals =1'b1;
    end
    
    else begin
        IF_ID_write = 1'b1;
        PC_write =1'b1;
        flush_ctrl_signals =1'b0;
    end
    
end

assign o_IF_ID_write = o_IF_ID_write;
assign o_PC_write = PC_write;
assign o_flush_ctrl_signals = flush_ctrl_signals;

endmodule