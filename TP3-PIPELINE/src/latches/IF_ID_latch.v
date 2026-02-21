module IF_ID_latch #(
    parameter NB_INSTRUCT = 32,
    parameter NB_PC = 6,
    parameter IF_ID_SIZE = 38 + NB_PC
)
(
    //Inputs
    input wire i_clk,
    input wire i_reset,
    input wire i_IF_flush,
    input wire i_IF_ID_write,
    input wire [NB_PC-1:0] i_PC,
    input wire [NB_INSTRUCT-1:0] i_instruction,
    input wire [1:0] i_pipeline_mode, // 01: stepwise , 11: continuous
    input wire i_execute_instruct,
    
    //Outputs
    output wire [NB_PC-1:0] o_PC,
    output wire [NB_INSTRUCT-1:0] o_instruction,
    output wire  o_EOF_flag,
    output wire [IF_ID_SIZE-1:0]  o_IF_ID_data 
);

localparam [NB_INSTRUCT-1:0] instructs_eof = "ieof";
localparam CONT_MODE = 2'b01;
localparam STEP_MODE = 2'b11;

// Bit offsets 
localparam PC_LSB = 2;
localparam INSTR_LSB = PC_LSB + NB_PC;
localparam PIPEMODE_LSB = INSTR_LSB + NB_INSTRUCT;
localparam EXEC_INST_BIT = PIPEMODE_LSB + 2;
localparam EOF_BIT = EXEC_INST_BIT + 1;

// Registers
reg [NB_INSTRUCT-1:0] instruction;
reg [NB_PC-1:0] PC;
reg EOF_flag;
reg [IF_ID_SIZE-1:0] IF_ID_data;

  
always @(posedge i_clk or posedge i_reset) begin
    if (i_reset || i_IF_flush) begin
        instruction <= {NB_INSTRUCT{1'b0}};
        PC <= {NB_PC{1'b0}}; // review this
        EOF_flag <= 1'b0;
        
        if (i_reset) begin
            IF_ID_data <= {IF_ID_SIZE{1'b0}};
        end
        
        else begin
            IF_ID_data[0]<= i_IF_flush;
            IF_ID_data[1] <= i_IF_ID_write;
            IF_ID_data[PC_LSB +: NB_PC]<= i_PC;
            IF_ID_data[INSTR_LSB +: NB_INSTRUCT]<= i_instruction;
            IF_ID_data[PIPEMODE_LSB +: 2] <= i_pipeline_mode;
            IF_ID_data[EXEC_INST_BIT] <= i_execute_instruct;
            IF_ID_data[EOF_BIT]  <= (i_instruction == instructs_eof);
        end
    end
    
    else if (i_IF_ID_write && (i_pipeline_mode == CONT_MODE || (i_pipeline_mode == STEP_MODE && i_execute_instruct)) )begin
        
        IF_ID_data[0] <= i_IF_flush;
        IF_ID_data[1] <= i_IF_ID_write;
        IF_ID_data[PC_LSB +: NB_PC] <= i_PC;
        IF_ID_data[INSTR_LSB +: NB_INSTRUCT] <= i_instruction;
        IF_ID_data[PIPEMODE_LSB +: 2] <= i_pipeline_mode;
        IF_ID_data[EXEC_INST_BIT] <= i_execute_instruct;
        IF_ID_data[EOF_BIT] <= (i_instruction == instructs_eof);
        
        instruction <= i_instruction;
        PC          <= i_PC;
        EOF_flag    <= (i_instruction == instructs_eof);
    end
      
end

assign o_instruction = instruction;
assign o_PC = PC;
assign o_EOF_flag = EOF_flag;
assign o_IF_ID_data = IF_ID_data;

endmodule