
module rx_buffer #(
parameter INSTRUCT_MEM_WIDTH = 32
)
(
//Inputs
input wire i_clk,
input wire i_reset,
input wire i_rx_done,
input wire [7:0]i_rx_data,

//Outputs
output [INSTRUCT_MEM_WIDTH-1:0]o_instruct_or_command,
output o_rx_buffer_done
);

reg [2:0]received_bytes_counter;
reg [INSTRUCT_MEM_WIDTH-1:0] instruct_or_command;
reg rx_buffer_done;

always @(posedge i_clk, posedge i_reset)begin
    
    if(i_reset)begin
        received_bytes_counter <= 0;
        instruct_or_command <= 0; 
        rx_buffer_done <= 1'b0;
    end

    else begin
        rx_buffer_done <= 1'b0;
              
        if(i_rx_done)begin
            if(received_bytes_counter == 3)begin
                instruct_or_command[8*received_bytes_counter+:8] <= i_rx_data;
                received_bytes_counter <= 0;
                rx_buffer_done <= 1'b1;
            end
            
            else begin
                instruct_or_command[8*received_bytes_counter+:8] <= i_rx_data;
                received_bytes_counter <= received_bytes_counter + 1;
            end
        end
    end
end

assign o_rx_buffer_done = rx_buffer_done;
assign o_instruct_or_command = instruct_or_command;

endmodule