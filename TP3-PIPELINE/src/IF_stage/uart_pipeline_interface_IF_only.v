module uart_pipeline_interface_IF_only #(

//parameter REG_BANK_WIDTH = 32,
//parameter REG_BANK_ADDR_BITS = 5,
//parameter DATA_MEM_WIDTH = 32,
//parameter DATA_MEM_ADDR_BITS = 8 ,
parameter INSTRUCT_MEM_WIDTH = 32,
parameter INSTRUCT_MEM_ADDR_BITS = 10,
parameter IF_ID_SIZE = 44
//parameter ID_EX_SIZE = 156,
//parameter EX_MEM_SIZE = 85,
//parameter MEM_WB_SIZE = 75
)
(
//Inputs
input wire i_clk,
input wire i_reset,
//input wire [REG_BANK_WIDTH-1:0]i_register_value,
//input wire [DATA_MEM_WIDTH-1:0]i_memory_value,
input wire [INSTRUCT_MEM_WIDTH-1:0]i_instruct_or_command,
input wire i_rx_buffer_done, 
input wire i_tx_buffer_empty,
input wire i_program_finished,
input wire [IF_ID_SIZE-1:0]i_IF_ID_content,
//input wire [ID_EX_SIZE-1:0]i_ID_EX_content,
//input wire [EX_MEM_SIZE-1:0]i_EX_MEM_content,
//input wire [MEM_WB_SIZE-1:0]i_MEM_WB_content,

//Outputs
//output wire [REG_BANK_ADDR_BITS-1:0]o_register_address,
//output wire [DATA_MEM_ADDR_BITS-1:0]o_memory_address,
output wire o_instruct_mem_write_enable,
output wire [1:0]o_instruct_mem_write_byte_enable,
output wire [7:0]o_instruct_byte_to_write,
output wire [INSTRUCT_MEM_ADDR_BITS-1:0]o_instruct_to_write_addr,
output wire [INSTRUCT_MEM_WIDTH-1:0]o_pipeline_info,
output wire o_tx_buffer_start,
output wire [1:0]o_pipeline_exec_mode,
output wire o_execute_instruct
);

//States (one hot encoding)
localparam WAIT_FOR_COMMAND = 6'b000001;
localparam INTERPRET_COMMAND = 6'b000010;
localparam RECEIVE_INSTRUCTS = 6'b000100;
localparam PROGRAM_INSTRUCT_MEM = 6'b001000;
localparam SEND_LATCHES = 6'b010000;
localparam RUN_STEPWISE = 6'b100000;

//Commands
localparam [INSTRUCT_MEM_WIDTH-1:0] run_stepwise             = 8'b00000010;
localparam [INSTRUCT_MEM_WIDTH-1:0] execute_next_instruction = 8'b00000011;
localparam [INSTRUCT_MEM_WIDTH-1:0] receive_instructions     = 8'b00000100;
localparam [INSTRUCT_MEM_WIDTH-1:0] fetch_pipeline_data      = 8'b00000101;
localparam [INSTRUCT_MEM_WIDTH-1:0] instructs_eof            = 8'b00000110;

// Auxiliar variables
reg [INSTRUCT_MEM_WIDTH-1:0] instructions [2**INSTRUCT_MEM_ADDR_BITS-1:0];
reg [5:0]state;
reg [INSTRUCT_MEM_ADDR_BITS-1:0] inst_counter;
reg [7:0] instruct_byte_to_write;
//reg [REG_BANK_ADDR_BITS:0] register_address;
//reg [DATA_MEM_ADDR_BITS:0] memory_address;
reg instruct_mem_write_enable;
reg [1:0] instruct_mem_write_byte_enable;
//reg send_mem_index_or_value;
reg [7:0] latch_words_sent;
reg [31:0] current_latch_size;
reg [INSTRUCT_MEM_WIDTH-1:0] pipeline_info;
reg tx_buffer_start;
reg [1:0] pipeline_exec_mode;
reg execute_instruct;
reg send_pipeline_data_flag;
//reg return_to_run_stepwise; 

always @(posedge i_clk,posedge i_reset)begin
    if (i_reset) begin
        state <= WAIT_FOR_COMMAND;
        inst_counter <= 0;
        instruct_byte_to_write <= 0;
        //register_address <= 0;
        //memory_address <= 0;
        instruct_mem_write_enable <= 0;
        instruct_mem_write_byte_enable <= 2'b00;
        //send_mem_index_or_value <= 0;
        latch_words_sent <= 0;
        pipeline_info <= 0;
        tx_buffer_start <= 1'b0;
        pipeline_exec_mode <= 2'b0;
        execute_instruct <= 1'b0; 
        send_pipeline_data_flag <= 1'b0; 
        //return_to_run_stepwise <= 1'b0;
    end
    
    else begin
        tx_buffer_start <= 1'b0;
        
        case(state)
            WAIT_FOR_COMMAND:begin
                if(i_rx_buffer_done == 1'b1)begin
                    instructions[0] <= i_instruct_or_command;
                    state <= INTERPRET_COMMAND;
                end
                
                else begin
                    state <= WAIT_FOR_COMMAND;
                end
            end
            
            INTERPRET_COMMAND:begin
                if (instructions[0] == receive_instructions)begin
                    state <= RECEIVE_INSTRUCTS;
                    inst_counter <= {INSTRUCT_MEM_ADDR_BITS{1'b0}};
                end
                
                else if(instructions[0] == fetch_pipeline_data) begin
                    latch_words_sent <= 0;
                    state <= SEND_LATCHES;
                end
                
                else if (instructions[0] == run_stepwise)begin
                    state <= RUN_STEPWISE;
                    pipeline_exec_mode <= 2'b11;
                    execute_instruct <= 1'b0;
                    send_pipeline_data_flag <= 1'b0;
                end
                
                else begin
                    state <= WAIT_FOR_COMMAND;
                end
            end
            
            RECEIVE_INSTRUCTS: begin
                if(i_rx_buffer_done)begin
                    instructions[inst_counter] <= i_instruct_or_command;
                    
                    if(i_instruct_or_command == instructs_eof)begin
                        inst_counter <= {INSTRUCT_MEM_ADDR_BITS{1'b0}};
                        state <= PROGRAM_INSTRUCT_MEM;
                        instruct_mem_write_enable <= 1'b1;
                        instruct_mem_write_byte_enable <= 2'b00;
                    end
                    
                    else begin
                        inst_counter <= inst_counter+1;
                    end
                end  
            end
            
            PROGRAM_INSTRUCT_MEM: begin
                instruct_byte_to_write <= instructions[inst_counter][instruct_mem_write_byte_enable*8 +: 8];

                if(instructions[inst_counter] == instructs_eof)begin
                    inst_counter <= {INSTRUCT_MEM_ADDR_BITS{1'b0}};
                    state <= WAIT_FOR_COMMAND;
                    instruct_mem_write_enable <= 1'b0;
                    instruct_mem_write_byte_enable <= 2'b00;
                end
            
                else begin
                    if(instruct_mem_write_byte_enable == 2'b11)begin
                        instruct_mem_write_byte_enable <= 2'b00;
                        inst_counter <= inst_counter + 1;
                    end
                    
                    else begin
                        instruct_mem_write_byte_enable <= instruct_mem_write_byte_enable + 1;
                    end
                end   
            end
            
            SEND_LATCHES:begin
                if (latch_words_sent >= current_latch_size)begin
                    state <= WAIT_FOR_COMMAND;
                    latch_words_sent <= 0;
                end
                
                else begin
                    if(i_tx_buffer_empty)begin
                        pipeline_info <= i_IF_ID_content[latch_words_sent*32 +: 32];
                        tx_buffer_start <= 1'b1;
                        latch_words_sent <= latch_words_sent + 1;
                    end  
                end
            end
           
            RUN_STEPWISE:begin
                pipeline_exec_mode <= 2'b11;
                execute_instruct <= 1'b0;
                
                if (i_program_finished)begin
                    pipeline_exec_mode <= 2'b00;
                    pipeline_info <= 32'hffffffff;
                    execute_instruct <= 1'b0; 
                    state <= WAIT_FOR_COMMAND;
                end
                
                else if(send_pipeline_data_flag)begin
                    latch_words_sent <= 0;
                    state <= SEND_LATCHES;
                    send_pipeline_data_flag <= 1'b0;
                end
                
                else if(i_rx_buffer_done == 1'b1 && i_instruct_or_command == execute_next_instruction )begin
                     execute_instruct <= 1'b1;
                     send_pipeline_data_flag <= 1'b1;                     
                end
                       
            end
            
            default: state <= WAIT_FOR_COMMAND;
        endcase 
    end
end


always @(*)begin
    current_latch_size = (IF_ID_SIZE+31)/32;
end

assign o_instruct_byte_to_write = instruct_byte_to_write; 
assign o_instruct_to_write_addr = inst_counter;
//assign o_register_address = register_address[REG_BANK_ADDR_BITS-1:0];
//assign o_memory_address = memory_address[DATA_MEM_ADDR_BITS-1:0];
assign o_instruct_mem_write_enable = instruct_mem_write_enable;
assign o_instruct_mem_write_byte_enable = instruct_mem_write_byte_enable;
assign o_pipeline_info = pipeline_info;
assign o_tx_buffer_start = tx_buffer_start;
assign o_pipeline_exec_mode = pipeline_exec_mode;
assign o_execute_instruct = execute_instruct;

endmodule