// =============================================================
// Top-level module for the RISC-V pipeline's ID (Instruction Decode) stage
//
// Submodules instantiated: hazard_detection_unit, control_unit,
//                           register_bank, imm_gen
//
// =============================================================

module id_stage #(
    parameter NB_INSTRUCT = 32,
    parameter NB_PC       = 10,
    parameter NB_REG      = 5
)
(
    // ---------------------------------------------------------
    // Global
    // ---------------------------------------------------------
    input  wire                    i_clk,
    input  wire                    i_reset,

    // ---------------------------------------------------------
    // From IF/ID latch
    // ---------------------------------------------------------
    input  wire [NB_PC-1:0]        i_PC,
    input  wire [NB_INSTRUCT-1:0]  i_instruction,
    input  wire                    i_EOF_flag,

    // ---------------------------------------------------------
    // From ID/EX latch (feedback for hazard detection)
    // ---------------------------------------------------------
    input  wire                    i_ID_EX_MemRead,
    input  wire [4:0]              i_ID_EX_rd,

    // ---------------------------------------------------------
    // From WB stage
    // ---------------------------------------------------------
    input  wire [NB_REG-1:0]       i_write_reg,
    input  wire [NB_INSTRUCT-1:0]  i_write_data,
    input  wire                    i_write_enable,

    // ---------------------------------------------------------
    // To IF stage / IF-ID latch
    // ---------------------------------------------------------
    output wire                    o_PC_write,
    output wire                    o_IF_ID_write,

    // ---------------------------------------------------------
    // To ID/EX latch
    // ---------------------------------------------------------
    output wire                    o_flush_ctrl_signals,
    output wire [10:0]             o_ctrl_bits,
    output wire [NB_PC-1:0]        o_PC,
    output wire [NB_INSTRUCT-1:0]  o_data1,
    output wire [NB_INSTRUCT-1:0]  o_data2,
    output wire [NB_INSTRUCT-1:0]  o_sign_extended_immediate,
    output wire [3:0]              o_instruct_30_14_12, 
    output wire [4:0]              o_instruct_11_7,
    output wire                    o_EOF_flag
);

    // ---------------------------------------------------------
    // Instruction field extraction (from i_instruction)
    // ---------------------------------------------------------
    wire [4:0] w_rs1 = i_instruction[19:15];
    wire [4:0] w_rs2 = i_instruction[24:20];

    assign o_instruct_11_7     = i_instruction[11:7];
    assign o_instruct_30_14_12 = {i_instruction[30], i_instruction[14:12]};

    // ---------------------------------------------------------
    // Passthroughs
    // ---------------------------------------------------------
    assign o_PC       = i_PC;
    assign o_EOF_flag = i_EOF_flag;

    // ---------------------------------------------------------
    // Hazard Detection Unit
    // ---------------------------------------------------------
    hazard_detection_unit u_hazard_detection_unit (
        .i_ID_EX_MemRead      (i_ID_EX_MemRead),
        .i_ID_EX_rd           (i_ID_EX_rd),
        .i_IF_ID_rs1          (w_rs1),
        .i_IF_ID_rs2          (w_rs2),

        .o_IF_ID_write        (o_IF_ID_write),
        .o_PC_write           (o_PC_write),
        .o_flush_ctrl_signals (o_flush_ctrl_signals)
    );

    // ---------------------------------------------------------
    // Control Unit
    // ---------------------------------------------------------
    control_unit #(
        .NB_INSTRUCT (NB_INSTRUCT)
    ) u_control_unit (
        .i_instruction (i_instruction),
        .o_ctrl_bits   (o_ctrl_bits)
    );

    // ---------------------------------------------------------
    // Register Bank
    // ---------------------------------------------------------
    register_bank #(
        .NB_DATA (NB_INSTRUCT),
        .NB_REG  (NB_REG)
    ) u_register_bank (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_read_reg1    (w_rs1),
        .i_read_reg2    (w_rs2),
        .i_write_reg    (i_write_reg),
        .i_write_data   (i_write_data),
        .i_write_enable (i_write_enable),

        .o_data1        (o_data1),
        .o_data2        (o_data2)
    );

    // ---------------------------------------------------------
    // Immediate Generator
    // ---------------------------------------------------------
    imm_gen #(
        .INSTR_WIDTH   (NB_INSTRUCT),
        .IMMEDIATE_LEN (NB_INSTRUCT)
    ) u_imm_gen (
        .i_instruction             (i_instruction),
        .o_sign_extended_immediate (o_sign_extended_immediate)
    );

endmodule