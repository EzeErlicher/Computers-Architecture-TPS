module ID_EX_latch #(

parameter NB_INSTRUCT = 32,
parameter NB_PC = 6,
parameter ID_EX_SIZE = 150 + NB_PC
)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire [8:0]i_control_bits,
input wire [NB_PC-1:0]i_PC,
input wire [NB_INSTRUCT-1:0]i_read_data1,i_read_data2,
input wire [63:0] i_imm_gen,
input wire [3:0] i_instruct_30_14_12,
input wire [4:0] i_instruct_11_7, 
input wire i_EOF_flag,
input wire [1:0] i_pipeline_mode, // 01: continuos, 11: stepwise
input wire i_execute_instruct,

//Outputs
output wire [8:0]o_control_bits,
output wire [NB_PC-1:0] o_PC,
output wire [NB_INSTRUCT-1:0] o_read_data1,
output wire [NB_INSTRUCT-1:0] o_read_data2,
output wire [2*NB_INSTRUCT-1:0] o_imm_gen,
output wire [3:0] o_instruct_30_14_12,
output wire [4:0] o_instruct_11_7, 
output wire o_EOF_flag,
output wire [ID_EX_SIZE-1:0] o_ID_EX_data 

);

localparam CONT_MODE = 2'b01;
localparam STEP_MODE = 2'b11; 

//Bit offsets
localparam CTRL_LSB = 0;
localparam PC_LSB = CTRL_LSB + 9;
localparam RD1_LSB = PC_LSB + NB_PC;
localparam RD2_LSB = RD1_LSB + NB_INSTRUCT;
localparam IMM_LSB = RD2_LSB + NB_INSTRUCT;
localparam FUNCT_LSB = IMM_LSB + 64;
localparam RD_LSB = FUNCT_LSB + 4;
localparam PIPEMODE_LSB = RD_LSB + 5;
localparam EXEC_INST_BIT = PIPEMODE_LSB + 2;
localparam EOF_BIT = EXEC_INST_BIT + 1;

//Auxiliar variables
reg [8:0]control_bits;
reg [NB_PC-1:0] PC;
reg [NB_INSTRUCT-1:0]read_data2,read_data1;
reg [63:0]imm_gen;
reg [3:0] instruct_30_14_12;
reg [4:0] instruct_11_7;
reg EOF_flag; 
reg [ID_EX_SIZE-1:0] ID_EX_data; 

always@(posedge i_clk,posedge i_reset)begin
    if(i_reset)begin
        control_bits <= 0;
        PC <= 0;
        read_data1 <= 0;
        read_data2 <= 0;
        imm_gen <= 0;
        instruct_30_14_12 <= 0;
        instruct_11_7 <= 0; 
        EOF_flag <= 0;
        ID_EX_data <= 0;
    end
    
    else if(i_pipeline_mode == CONT_MODE || (i_pipeline_mode == STEP_MODE && i_execute_instruct) ) begin
        ID_EX_data[CTRL_LSB +: 9] <= i_control_bits;
        ID_EX_data[PC_LSB +: NB_PC] <= i_PC;
        ID_EX_data[RD1_LSB +: NB_INSTRUCT] <= i_read_data1;
        ID_EX_data[RD2_LSB +: NB_INSTRUCT] <= i_read_data2;
        ID_EX_data[IMM_LSB +: 64] <= i_imm_gen;
        ID_EX_data[FUNCT_LSB +: 4] <= i_instruct_30_14_12;
        ID_EX_data[RD_LSB +: 5] <= i_instruct_11_7;
        ID_EX_data[PIPEMODE_LSB +: 2] <= i_pipeline_mode;
        ID_EX_data[EXEC_INST_BIT] <= i_execute_instruct;
        ID_EX_data[EOF_BIT] <= i_EOF_flag;
        
        control_bits <= i_control_bits;
        PC <= i_PC;
        read_data1 <= i_read_data1;
        read_data2 <= i_read_data2;
        imm_gen <= i_imm_gen;
        instruct_30_14_12 <= i_instruct_30_14_12;
        instruct_11_7 <= i_instruct_11_7; 
        EOF_flag <= i_EOF_flag;
    end
end


assign o_control_bits = control_bits;
assign o_PC = PC;
assign o_read_data1 = read_data1;
assign o_read_data2 = read_data2;
assign o_imm_gen = imm_gen;
assign o_instruct_30_14_12 = instruct_30_14_12;
assign o_instruct_11_7 = instruct_11_7;
assign o_EOF_flag = EOF_flag;
assign o_ID_EX_data = ID_EX_data;

endmodule