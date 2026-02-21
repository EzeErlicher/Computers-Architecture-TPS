module EX_MEM_latch #(

parameter NB_INSTRUCT = 32,
parameter NB_PC = 6,
parameter EX_MEM_SIZE = 79 + NB_PC
)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire [4:0]i_control_bits,
input wire i_zero,
input wire [NB_PC-1:0] i_sum,
input wire [NB_INSTRUCT-1:0] i_alu_result,
input wire [NB_INSTRUCT-1:0] i_read_data2,
input wire [4:0] i_instruct_11_7,
input wire i_EOF_flag,
input wire [1:0] i_pipeline_mode, // 01: continuos, 11: stepwise
input wire i_execute_instruct,

//Outputs
output wire [4:0]o_control_bits,
output wire o_zero,
output wire [NB_PC-1:0] o_sum,
output wire [NB_INSTRUCT-1:0] o_alu_result,
output wire [NB_INSTRUCT-1:0] o_read_data2,
output wire [4:0] o_instruct_11_7,
output wire o_EOF_flag,
output wire [EX_MEM_SIZE-1:0] o_EX_MEM_data 

);

localparam CONT_MODE = 2'b01;
localparam STEP_MODE = 2'b11; 

//Bit offsets
localparam CTRL_LSB = 0;
localparam ZERO_LSB = CTRL_LSB + 5;
localparam SUM_LSB = ZERO_LSB + 1;
localparam ALU_LSB = SUM_LSB + NB_PC;
localparam RD2_LSB = ALU_LSB + NB_INSTRUCT;
localparam RD_LSB = RD2_LSB + NB_INSTRUCT;
localparam PIPEMODE_LSB = RD_LSB + 5;
localparam EXEC_INST_BIT = PIPEMODE_LSB + 2;
localparam EOF_BIT = EXEC_INST_BIT + 1;

//Auxiliar variables;
reg [4:0]control_bits;
reg zero;
reg [NB_PC-1:0] sum;
reg [NB_INSTRUCT-1:0] alu_result;
reg [NB_INSTRUCT-1:0] read_data2;
reg [4:0] instruct_11_7;
reg EOF_flag;
reg [EX_MEM_SIZE-1:0]EX_MEM_data; 


always@(posedge i_clk,posedge i_reset)begin
    if(i_reset)begin
        control_bits <= 0; 
        zero <= 0;
        sum <= 0;
        alu_result <= 0;
        read_data2 <= 0;
        instruct_11_7 <= 0;
        EOF_flag <= 0;
        EX_MEM_data <=0;
    end
    
    else if (i_pipeline_mode == CONT_MODE || (i_pipeline_mode == STEP_MODE && i_execute_instruct)) begin
        EX_MEM_data[CTRL_LSB +: 5] <= i_control_bits; 
        EX_MEM_data[ZERO_LSB] <= i_zero;
        EX_MEM_data[SUM_LSB +: NB_PC] <= i_sum;
        EX_MEM_data[ALU_LSB +: NB_INSTRUCT] <= i_alu_result;
        EX_MEM_data[RD2_LSB +: NB_INSTRUCT] <= i_read_data2;
        EX_MEM_data[RD_LSB +: 5] <= i_instruct_11_7;
        EX_MEM_data[PIPEMODE_LSB +: 2] <= i_pipeline_mode;
        EX_MEM_data[EXEC_INST_BIT] <= i_execute_instruct;
        EX_MEM_data[EOF_BIT] <= i_EOF_flag;
        
        control_bits <= i_control_bits;
        zero <= i_zero;
        sum <= i_sum;
        alu_result <= i_alu_result; 
        read_data2 <= i_read_data2;
        instruct_11_7 <= i_instruct_11_7;
        EOF_flag <= i_EOF_flag;
    end
end

assign o_control_bits = control_bits;
assign o_zero = zero;
assign o_sum = sum;
assign o_alu_result = alu_result; 
assign o_read_data2 = read_data2;
assign o_instruct_11_7 = instruct_11_7;
assign o_EOF_flag = EOF_flag;
assign o_EX_MEM_data = EX_MEM_data;

endmodule