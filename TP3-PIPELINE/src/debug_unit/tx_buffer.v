module tx_buffer #(

parameter INSTRUCT_MEM_WIDTH = 32
)

(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_tx_buffer_start,
input wire i_tx_done,
input wire [INSTRUCT_MEM_WIDTH-1:0]i_pipeline_info,

//Outputs
output wire o_tx_buffer_empty,
output wire o_tx_start,
output wire [7:0]o_tx_data
);

reg [INSTRUCT_MEM_WIDTH-1:0]tx_buffer_data;
reg tx_start;
reg [7:0]byte_to_send;
reg tx_buffer_empty;
reg [2:0]sent_bytes_counter;

always @(posedge i_clk,posedge i_reset)begin
    tx_start <= 1'b0;  
    
    if (i_reset)begin
        tx_buffer_data <= 0;
        byte_to_send <= 1'b0;
        tx_buffer_empty <= 1'b1;
        sent_bytes_counter <= 0;    
    end
    
    else if(i_tx_buffer_start) begin
        tx_buffer_empty <= 1'b0;
        tx_buffer_data <= i_pipeline_info;
        byte_to_send <= i_pipeline_info[0+:8]; 
        sent_bytes_counter <= 3'b001;
        tx_start <= 1'b1;              
    end
    
    else begin
        if(i_tx_done)begin
            if(sent_bytes_counter == 4) begin
                tx_buffer_data <= 0;
                tx_buffer_empty <= 1'b1;
                sent_bytes_counter <= 3'b000;
                byte_to_send <= 0;  
            end
            
            else begin
                byte_to_send <= tx_buffer_data[8*sent_bytes_counter+:8]; 
                sent_bytes_counter <= sent_bytes_counter + 1;
                tx_start <= 1'b1; 
            end
        end
    end  
end

assign o_tx_buffer_empty = tx_buffer_empty;
assign o_tx_data = byte_to_send;
assign o_tx_start = tx_start;

endmodule



