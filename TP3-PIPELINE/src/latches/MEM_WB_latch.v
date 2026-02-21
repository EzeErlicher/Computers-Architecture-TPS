module MEM_WB_latch #(

parameter NB_INSTRUCT = 32,
parameter NB_PC = 6,
parameter MEM_WB_SIZE = 75
)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire [1:0]i_control_bits,
input wire [NB_INSTRUCT-1:0] i_read_data,
input wire [NB_INSTRUCT-1:0] i_alu_result,
input wire [4:0] i_instruct_11_7,
input wire i_EOF_flag,
input wire [1:0] i_pipeline_mode, // 01: continuos, 11: stepwise
input wire i_execute_instruct,

//Outputs
output wire [1:0]o_control_bits,
output wire [NB_INSTRUCT-1:0] o_read_data,
output wire [NB_INSTRUCT-1:0] o_alu_result,
output wire [4:0] o_instruct_11_7,
output wire o_EOF_flag,
output wire [MEM_WB_SIZE-1:0] o_MEM_WB_data
);

//localparam
localparam CONT_MOD = 2'b01;
localparam STEP_MOD = 2'b11;

//Bit offsets
localparam CTRL_LSB = 0;
localparam RD_DATA_LSB = CTRL_LSB + 2;
localparam ALU_LSB = RD_DATA_LSB + NB_INSTRUCT;
localparam RD_LSB = ALU_LSB + NB_INSTRUCT;
localparam PIPEMODE_LSB = RD_LSB + 5;
localparam EXEC_INST_BIT = PIPEMODE_LSB + 2;
localparam EOF_BIT = EXEC_INST_BIT + 1;

//Auxiliar variables;
reg [1:0]control_bits;
reg [NB_INSTRUCT-1:0] read_data;
reg [NB_INSTRUCT-1:0] alu_result;
reg [4:0] instruct_11_7;
reg EOF_flag;
reg [MEM_WB_SIZE-1:0]MEM_WB_data; 


always@(posedge i_clk,posedge i_reset)begin
    if(i_reset)begin
        control_bits <= 0;
        read_data <= 0;
        alu_result <= 0;
        instruct_11_7 <= 0;
        EOF_flag <= 0;
        MEM_WB_data <= 0;
    end
    
    else if(i_pipeline_mode == CONT_MOD || (i_pipeline_mode == STEP_MOD && i_execute_instruct))begin
        MEM_WB_data[CTRL_LSB +: 2] <= i_control_bits;
        MEM_WB_data[RD_DATA_LSB +: NB_INSTRUCT] <= i_read_data;
        MEM_WB_data[ALU_LSB +: NB_INSTRUCT] <= i_alu_result;
        MEM_WB_data[RD_LSB +: 5] <= i_instruct_11_7;
        MEM_WB_data[PIPEMODE_LSB +: 2] <= i_pipeline_mode;
        MEM_WB_data[EXEC_BIT] <= i_execute_instruct;
        MEM_WB_data[EOF_BIT] <= i_EOF_flag;
        
        control_bits <= i_control_bits;
        read_data <= i_read_data;
        alu_result <= i_alu_result; 
        instruct_11_7 <= i_instruct_11_7;
        EOF_flag <= i_EOF_flag;     
    end
end

assign o_control_bits = control_bits;
assign o_read_data = read_data;
assign o_alu_result = alu_result; 
assign o_instruct_11_7 = instruct_11_7;
assign o_EOF_flag = EOF_flag;
assign o_MEM_WB_data = MEM_WB_data;

endmodule