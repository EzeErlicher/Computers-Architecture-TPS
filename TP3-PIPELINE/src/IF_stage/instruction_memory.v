module instruction_memory #(
// Memoria de 
    parameter PC_BITS = 10, 
    parameter IMEM_WIDTH = 32,
    parameter IMEM_DEPTH = 2**PC_BITS
)
(
input wire                  i_clk,
input wire [PC_BITS-1:0]    i_read_address,

input wire                  i_write_enable,
input wire [PC_BITS-1:0]    i_write_address,
input wire [IMEM_WIDTH-1:0] i_write_instruction,
input wire [1:0]            i_write_byte_enable,

output wire [IMEM_WIDTH-1:0] o_instruction
);

localparam BYTE_WIDTH = 8;

reg [BYTE_WIDTH-1:0] ram_mem [IMEM_DEPTH-1:0];
reg [IMEM_WIDTH-1:0] instruction;

always @(posedge i_clk) begin

    if(i_write_enable) begin
        case(i_write_byte_enable)
            2'b00: ram_mem[i_write_address]   <= i_write_instruction[BYTE_WIDTH-1:0];
            2'b01: ram_mem[i_write_address+1] <= i_write_instruction[2*BYTE_WIDTH-1:BYTE_WIDTH];
            2'b10: ram_mem[i_write_address+2] <= i_write_instruction[3*BYTE_WIDTH-1:2*BYTE_WIDTH];
            2'b11: ram_mem[i_write_address+3] <= i_write_instruction[4*BYTE_WIDTH-1:3*BYTE_WIDTH];
            default: ; // No write
        endcase
    end

    else begin
        instruction <= {ram_mem[i_read_address + 3], ram_mem[i_read_address + 2], ram_mem[i_read_address + 1], ram_mem[i_read_address]};
    end
end

assign o_instruction = instruction;

endmodule