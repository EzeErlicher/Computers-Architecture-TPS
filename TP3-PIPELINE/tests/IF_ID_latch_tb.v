`timescale 1ns / 1ps

module IF_ID_latch_tb;

    // Parameters
    localparam NB_INSTRUCT = 32;
    localparam NB_PC       = 6;
    localparam IF_ID_SIZE  = 38 + NB_PC;

    // DUT inputs
    reg i_clk;
    reg i_reset;
    reg i_IF_flush;
    reg i_IF_ID_write;
    reg [NB_PC-1:0] i_PC;
    reg [NB_INSTRUCT-1:0] i_instruction;
    reg [1:0] i_pipeline_mode;
    reg i_execute_instruct;

    // DUT outputs
    wire [NB_PC-1:0] o_PC;
    wire [NB_INSTRUCT-1:0] o_instruction;
    wire o_EOF_flag;
    wire [IF_ID_SIZE-1:0] o_IF_ID_data;

    // Pipeline modes
    localparam CONT_MODE = 2'b01;
    localparam STEP_MODE = 2'b11;

    // EOF instruction
    localparam [NB_INSTRUCT-1:0] EOF_INSTR = "ieof";

    // DUT
    IF_ID_latch #(
        .NB_INSTRUCT(NB_INSTRUCT),
        .NB_PC(NB_PC),
        .IF_ID_SIZE(IF_ID_SIZE)
    ) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_IF_flush(i_IF_flush),
        .i_IF_ID_write(i_IF_ID_write),
        .i_PC(i_PC),
        .i_instruction(i_instruction),
        .i_pipeline_mode(i_pipeline_mode),
        .i_execute_instruct(i_execute_instruct),
        .o_PC(o_PC),
        .o_instruction(o_instruction),
        .o_EOF_flag(o_EOF_flag),
        .o_IF_ID_data(o_IF_ID_data)
    );

    // Clock generator
    always #5 i_clk = ~i_clk;

    initial begin
        
        $display("------------------------------");
        $display("Starting IF/ID latch testbench");
        $display("------------------------------");

        // Initial values
        i_clk = 0;
        i_reset = 1;
        i_IF_flush = 0;
        i_IF_ID_write = 0;
        i_PC = 0;
        i_instruction = 0;
        i_pipeline_mode = CONT_MODE;
        i_execute_instruct = 0;

        //--------------------------------
        // Reset
        //--------------------------------
        #10;
        i_reset = 0;

        //--------------------------------
        // Continuous mode write
        //--------------------------------
        #10;
        i_IF_ID_write = 1;
        i_PC = 6'd10;
        i_instruction = 32'h12345678;
        i_pipeline_mode = CONT_MODE;

        #10;
        $display("* OUTPUT IN CONT MODE -> PC=%d INSTR=%h", o_PC, o_instruction);

        //--------------------------------
        // Flush test
        //--------------------------------
        #10;
        i_IF_flush = 1;

        #10;
        i_IF_flush = 0;

        $display("* OUTPUT AFTER FLUSH -> PC=%d INSTR=%h",o_PC,o_instruction);

        //--------------------------------
        // Step mode without execute
        //--------------------------------
        i_pipeline_mode = STEP_MODE;
        #10;
        i_PC = 6'd20;
        i_instruction = 32'hAAAAAAAA;
        i_execute_instruct = 0;

        #10;
        $display("* OUTPUT IN STEP MODE (no execute) -> PC=%d INSTR=%h",o_PC,o_instruction);

        //--------------------------------
        // Step mode with execute
        //--------------------------------
        #10;
        i_execute_instruct = 1;

        #10;
        $display("* OUTPUT IN STEP MODE (execute) -> PC=%d INSTR=%h", o_PC, o_instruction);

        //--------------------------------
        // EOF instruction test
        //--------------------------------
        #10;
        i_instruction = EOF_INSTR;
        i_PC = 6'd30;
        i_pipeline_mode = CONT_MODE;

        #10;
        $display("* OUTPUT WHEN i_instruction = EOF_INST-> EOF_flag=%b", o_EOF_flag);

        //--------------------------------
        // Finish simulation
        //--------------------------------
        #20;
        $display("------------------------------");
        $display("IF/ID latch testbench finished");
        $display("------------------------------");
        $finish;

    end

endmodule