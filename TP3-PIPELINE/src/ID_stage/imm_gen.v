module imm_gen
#(
    parameter INSTR_WIDTH = 32,
    parameter IMMEDIATE_LEN = 32
)
(
    input wire [INSTR_WIDTH-1:0] i_instruction,
    output wire [IMMEDIATE_LEN-1:0] o_sign_extended_immediate
);

//SLL, SRL, SRA, SLL, SRL, SRA, ADD, 
//SUB, AND, OR, XOR, NOR, SLT, SLTU 
localparam R_TYPE_OP_CODE = 7'b0110011;

//SB, SH, SW
localparam S_TYPE_OP_CODE = 7'b0100011;

// LB, LH, LW, LWU, LBU, LHU, 
localparam I_TYPE_1_OP_CODE = 7'b0000011;

//ADDI, ANDI, ORI, XORI, SLTI, SLTIU
localparam I_TYPE_2_OP_CODE = 7'b0010011;

//JALR
localparam I_JALR_OP_CODE = 7'b1100111;

// LUI
localparam U_TYPE_OP_CODE = 7'b0110111;

// JAL
localparam UJ_TYPE_OP_CODE = 7'b1101111;

// BEQ,BNE
localparam SB_TYPE_OP_CODE = 7'b1100011;


reg[6:0] opcode;
reg [IMMEDIATE_LEN-1:0] sign_extended_immediate; 


always@(*) begin
    opcode = i_instruction[6:0];
    sign_extended_immediate = {IMMEDIATE_LEN{1'b0}}; // safe default

    if (opcode == S_TYPE_OP_CODE) begin
        sign_extended_immediate = {{(IMMEDIATE_LEN-12){i_instruction[31]}}, i_instruction[31:25], i_instruction[11:7]};
    end
    else if (opcode == I_TYPE_1_OP_CODE || opcode == I_TYPE_2_OP_CODE || opcode == I_JALR_OP_CODE) begin
        sign_extended_immediate = {{(IMMEDIATE_LEN-12){i_instruction[31]}}, i_instruction[31:20]};
    end
    else if (opcode == SB_TYPE_OP_CODE) begin
        sign_extended_immediate = {{(IMMEDIATE_LEN-13){i_instruction[31]}}, i_instruction[31], i_instruction[7], i_instruction[30:25], i_instruction[11:8], 1'b0};
    end
    else if (opcode == U_TYPE_OP_CODE) begin
        sign_extended_immediate = {i_instruction[31:12], 12'b0};
    end
    else if (opcode == UJ_TYPE_OP_CODE) begin
        sign_extended_immediate = {{(IMMEDIATE_LEN-20){i_instruction[31]}}, i_instruction[19:12], i_instruction[20], i_instruction[30:21], 1'b0};
    end
end

assign o_sign_extended_immediate = sign_extended_immediate;


endmodule