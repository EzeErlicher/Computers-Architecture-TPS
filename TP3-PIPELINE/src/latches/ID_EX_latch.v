module ID_EX_latch #(

parameter NB_INSTRUCT = 32,
parameter NB_PC = 6,
parameter ID_EX_SIZE = 156
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

//localparam
localparam CONT_MODE = 2'b01;
localparam STEP_MODE = 2'b11; 

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
        ID_EX_data[8:0] <= i_control_bits;
        ID_EX_data[14:9] <= i_PC;
        ID_EX_data[46:15] <= i_read_data1;
        ID_EX_data[78:47] <= i_read_data2;
        ID_EX_data[142:79] <= i_imm_gen;
        ID_EX_data[146:143] <= i_instruct_30_14_12;
        ID_EX_data[151:147] <= i_instruct_11_7;
        ID_EX_data[153:152] <= i_pipeline_mode;
        ID_EX_data[154] <= i_execute_instruct;
        ID_EX_data[155] <= i_EOF_flag;
        
    
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
assign o_imm_Gen = imm_gen;
assign o_instruct_30_14_12 = instruct_30_14_12;
assign o_instruct_11_7 = instruct_11_7;
assign o_EOF_flag = EOF_flag;
assign o_ID_EX_data = ID_EX_data;

endmodule