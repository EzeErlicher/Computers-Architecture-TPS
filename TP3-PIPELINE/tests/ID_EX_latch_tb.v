`timescale 1ns / 1ps

module ID_EX_latch_tb;

    // Parameters
    localparam NB_INSTRUCT = 32;
    localparam NB_PC       = 6;
    localparam ID_EX_SIZE  = 150 + NB_PC;

    // DUT inputs
    reg i_clk;
    reg i_reset;
    reg [8:0] i_control_bits;
    reg [NB_PC-1:0] i_PC;
    reg [NB_INSTRUCT-1:0] i_read_data1, i_read_data2;
    reg [63:0] i_imm_gen;
    reg [3:0] i_instruct_30_14_12;
    reg [4:0] i_instruct_11_7;
    reg i_EOF_flag;
    reg [1:0] i_pipeline_mode;
    reg i_execute_instruct;

    // DUT outputs
    wire [8:0] o_control_bits;
    wire [NB_PC-1:0] o_PC;
    wire [NB_INSTRUCT-1:0] o_read_data1;
    wire [NB_INSTRUCT-1:0] o_read_data2;
    wire [2*NB_INSTRUCT-1:0] o_imm_gen;
    wire [3:0] o_instruct_30_14_12;
    wire [4:0] o_instruct_11_7;
    wire o_EOF_flag;
    wire [ID_EX_SIZE-1:0] o_ID_EX_data;

    // Modes
    localparam CONT_MODE = 2'b01;
    localparam STEP_MODE = 2'b11;

    // DUT
    ID_EX_latch #(
        .NB_INSTRUCT(NB_INSTRUCT),
        .NB_PC(NB_PC),
        .ID_EX_SIZE(ID_EX_SIZE)
    ) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_control_bits(i_control_bits),
        .i_PC(i_PC),
        .i_read_data1(i_read_data1),
        .i_read_data2(i_read_data2),
        .i_imm_gen(i_imm_gen),
        .i_instruct_30_14_12(i_instruct_30_14_12),
        .i_instruct_11_7(i_instruct_11_7),
        .i_EOF_flag(i_EOF_flag),
        .i_pipeline_mode(i_pipeline_mode),
        .i_execute_instruct(i_execute_instruct),
        .o_control_bits(o_control_bits),
        .o_PC(o_PC),
        .o_read_data1(o_read_data1),
        .o_read_data2(o_read_data2),
        .o_imm_gen(o_imm_gen),
        .o_instruct_30_14_12(o_instruct_30_14_12),
        .o_instruct_11_7(o_instruct_11_7),
        .o_EOF_flag(o_EOF_flag),
        .o_ID_EX_data(o_ID_EX_data)
    );

    // Clock
    always #5 i_clk = ~i_clk;

    initial begin
        $display("------------------------------");
        $display("Starting ID/EX latch testbench");
        $display("------------------------------");
        // Init
        i_clk = 0;
        i_reset = 1;
        i_control_bits = 0;
        i_PC = 0;
        i_read_data1 = 0;
        i_read_data2 = 0;
        i_imm_gen = 0;
        i_instruct_30_14_12 = 0;
        i_instruct_11_7 = 0;
        i_EOF_flag = 0;
        i_pipeline_mode = CONT_MODE;
        i_execute_instruct = 0;

        //--------------------------------
        // Reset
        //--------------------------------
        #10;
        i_reset = 0;

        //--------------------------------
        // Continuous mode
        //--------------------------------
        #10;
        i_control_bits = 9'b101010101;
        i_PC = 6'd12;
        i_read_data1 = 32'hAAAA5555;
        i_read_data2 = 32'h12345678;
        i_imm_gen = 64'hDEADBEEFCAFEBABE;
        i_instruct_30_14_12 = 4'b1101;
        i_instruct_11_7 = 5'd17;
        i_EOF_flag = 0;

        #10;
        $display("OUTPUT IN CONT MODE:\n -PC=%d\n -RD1=%h\n -RD2=%h\n -i_imm_gen=%h\n -i_instruct_30_14_12=%b\n -i_instruct_11_7 =%d\n -i_EOF_flag =%d", 
        o_PC, o_read_data1, o_read_data2,i_imm_gen,i_instruct_30_14_12,i_instruct_11_7,i_EOF_flag);
        $display("------------------------------");
        //--------------------------------
        // Step mode without execute (STALL)
        //--------------------------------
        #10;
        i_PC = 6'd20;
        i_read_data1 = 32'hFFFFFFFF;
        i_read_data2 = 32'hEEEEEEEE;
        i_pipeline_mode = STEP_MODE;
        i_execute_instruct = 0;

        #10;
        $display("OUTPUT IN STEP MODE (no execute):\n -PC=%d\n -RD1=%h\n -RD2=%h\n -i_imm_gen=%h\n -i_instruct_30_14_12=%b\n -i_instruct_11_7 =%d\n -i_EOF_flag =%d", 
        o_PC, o_read_data1, o_read_data2,i_imm_gen,i_instruct_30_14_12,i_instruct_11_7,i_EOF_flag);
        $display("------------------------------");
        
        //--------------------------------
        // Step mode with execute
        //--------------------------------
        #10;
        i_execute_instruct = 1;

        #10;
        $display("OUTPUT IN STEP MODE (execute):\n -PC=%d\n -RD1=%h\n -RD2=%h\n -i_imm_gen=%h\n -i_instruct_30_14_12=%b\n -i_instruct_11_7 =%d\n -i_EOF_flag =%d", 
        o_PC, o_read_data1, o_read_data2,i_imm_gen,i_instruct_30_14_12,i_instruct_11_7,i_EOF_flag);
        $display("------------------------------");
        
        //--------------------------------
        // EOF propagation
        //--------------------------------
        #10;
        i_EOF_flag = 1;
        i_pipeline_mode = CONT_MODE;

        #10;
        $display("EOF_INST OUTPUT WHEN i_instruction = EOF_FLAG: %b", o_EOF_flag);

        //--------------------------------
        // Finish
        //--------------------------------
        #20;
        $display("------------------------------");
        $display("ID/EX latch testbench finished");
        $display("------------------------------");
        $finish;
    end

endmodule
