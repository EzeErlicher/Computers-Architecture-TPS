module instruction_memory #(

// memoria  de 256 slots =256*32bits= 8192bits
    parameter PC_BITS = 8, 
    parameter IMEM_WIDTH = 32,
    parameter IMEM_DEPTH = 2**PC_BITS
)
(
input wire                  i_clk,
input wire [PC_BITS-1:0]    i_read_address,

input wire                  i_write_enable,
input wire [PC_BITS-1:0]    i_write_address,
input wire [IMEM_WIDTH-1:0] i_write_instruction,

output wire [IMEM_WIDTH-1:0] o_instruction
);

reg [IMEM_WIDTH-1:0] ram_mem [IMEM_DEPTH-1:0];
reg [IMEM_WIDTH-1:0] instruction;

always @(posedge i_clk) begin
    if(i_write_enable)begin
        ram_mem[i_write_address] <= i_write_instruction;
    end

    else begin
        instruction <= ram_mem[i_read_address];
    end
end

assign o_instruction = instruction;

endmodule