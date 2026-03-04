module instruction_memory #(
// Memoria  de 1024 bytes por defecto ((2**10)*8 bits) --> Hasta 256 instrucciones de 32 bits
    parameter PC_BITS = 10, 
    parameter IMEM_WIDTH = 8,
    parameter IMEM_DEPTH = 2**PC_BITS
)
(
input wire                     i_clk,
input wire  [PC_BITS-1:0]      i_address,

output wire [4*IMEM_WIDTH-1:0] o_instruction

// Extra inputs for initialization
input wire                    i_write_enable,
input wire [PC_BITS-1:0]      i_write_address,
input wire [4*IMEM_WIDTH-1:0] i_write_instruction,
);

reg [4*IMEM_WIDTH-1:0] instruction;
reg [IMEM_WIDTH-1:0] ram_mem [IMEM_DEPTH-1:0];

// Force word alignment
wire [PC_BITS-1:0] address = {i_address[PC_BITS-1:2], 2'b00};

always @(posedge i_clk) begin
    if(i_write_enable)begin
        ram_mem[i_write_address]   <= i_write_instruction[IMEM_WIDTH-1:0];
        ram_mem[i_write_address+1] <= i_write_instruction[2*IMEM_WIDTH-1:0];
        ram_mem[i_write_address+2] <= i_write_instruction[3*IMEM_WIDTH-1:0];
        ram_mem[i_write_address+3] <= i_write_instruction[4*IMEM_WIDTH-1:0];
    end
    
    else begin
        instruction <= {ram_mem[address + 3], ram_mem[address + 2], ram_mem[address + 1], ram_mem[address]};
    end
end

assign o_instruction = instruction;

endmodule