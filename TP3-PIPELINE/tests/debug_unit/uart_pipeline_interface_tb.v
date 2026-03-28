`timescale 1ns / 1ps

module uart_pipeline_interface_tb;

    parameter REG_BANK_WIDTH = 32;
    parameter REG_BANK_ADDR_BITS = 5;
    parameter DATA_MEM_WIDTH = 32;
    parameter DATA_MEM_ADDR_BITS = 8;
    parameter INSTRUCT_MEM_WIDTH = 32;
    parameter INSTRUCT_MEM_ADDR_BITS = 10;
    parameter IF_ID_SIZE = 44;
    parameter ID_EX_SIZE = 156;
    parameter EX_MEM_SIZE = 85;
    parameter MEM_WB_SIZE = 75;

    // Commands
    localparam [INSTRUCT_MEM_WIDTH-1:0] RUN_CONTINUOUS           = 8'b00000001;
    localparam [INSTRUCT_MEM_WIDTH-1:0] RUN_STEPWISE             = 8'b00000010;
    localparam [INSTRUCT_MEM_WIDTH-1:0] EXECUTE_NEXT_INSTRUCTION = 8'b00000011;
    localparam [INSTRUCT_MEM_WIDTH-1:0] RECEIVE_INSTRUCTIONS     = 8'b00000100;
    localparam [INSTRUCT_MEM_WIDTH-1:0] FETCH_PIPELINE_DATA      = 8'b00000101;
    localparam [INSTRUCT_MEM_WIDTH-1:0] INSTRUCTS_EOF            = 8'b00000110;

    // Inputs
    reg i_clk;
    reg i_reset;
    reg [REG_BANK_WIDTH-1:0] i_register_value;
    reg [DATA_MEM_WIDTH-1:0] i_memory_value;
    reg [INSTRUCT_MEM_WIDTH-1:0] i_instruct_or_command;
    reg i_rx_buffer_done;
    reg i_tx_buffer_empty;
    reg i_program_finished;
    reg [IF_ID_SIZE-1:0] i_IF_ID_content;
    reg [ID_EX_SIZE-1:0] i_ID_EX_content;
    reg [EX_MEM_SIZE-1:0] i_EX_MEM_content;
    reg [MEM_WB_SIZE-1:0] i_MEM_WB_content;

    // Outputs
    wire [REG_BANK_ADDR_BITS-1:0] o_register_address;
    wire [DATA_MEM_ADDR_BITS-1:0] o_memory_address;
    wire o_instruct_mem_write_enable;
    wire [1:0] o_instruct_mem_write_byte_enable;
    wire [7:0] o_instruct_byte_to_write;
    wire [INSTRUCT_MEM_ADDR_BITS-1:0] o_instruct_to_write_addr;
    wire [INSTRUCT_MEM_WIDTH-1:0] o_pipeline_info;
    wire o_tx_buffer_start;
    wire [1:0] o_pipeline_exec_mode;
    wire o_execute_instruct;

    // Test counters
    integer test_pass = 0;
    integer test_fail = 0;
    reg pulse_observed;

    uart_pipeline_interface #(
        .REG_BANK_WIDTH(REG_BANK_WIDTH),
        .REG_BANK_ADDR_BITS(REG_BANK_ADDR_BITS),
        .DATA_MEM_WIDTH(DATA_MEM_WIDTH),
        .DATA_MEM_ADDR_BITS(DATA_MEM_ADDR_BITS),
        .INSTRUCT_MEM_WIDTH(INSTRUCT_MEM_WIDTH),
        .INSTRUCT_MEM_ADDR_BITS(INSTRUCT_MEM_ADDR_BITS),
        .IF_ID_SIZE(IF_ID_SIZE),
        .ID_EX_SIZE(ID_EX_SIZE),
        .EX_MEM_SIZE(EX_MEM_SIZE),
        .MEM_WB_SIZE(MEM_WB_SIZE)
    ) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_register_value(i_register_value),
        .i_memory_value(i_memory_value),
        .i_instruct_or_command(i_instruct_or_command),
        .i_rx_buffer_done(i_rx_buffer_done),
        .i_tx_buffer_empty(i_tx_buffer_empty),
        .i_program_finished(i_program_finished),
        .i_IF_ID_content(i_IF_ID_content),
        .i_ID_EX_content(i_ID_EX_content),
        .i_EX_MEM_content(i_EX_MEM_content),
        .i_MEM_WB_content(i_MEM_WB_content),
        .o_register_address(o_register_address),
        .o_memory_address(o_memory_address),
        .o_instruct_mem_write_enable(o_instruct_mem_write_enable),
        .o_instruct_mem_write_byte_enable(o_instruct_mem_write_byte_enable),
        .o_instruct_byte_to_write(o_instruct_byte_to_write),
        .o_instruct_to_write_addr(o_instruct_to_write_addr),
        .o_pipeline_info(o_pipeline_info),
        .o_tx_buffer_start(o_tx_buffer_start),
        .o_pipeline_exec_mode(o_pipeline_exec_mode),
        .o_execute_instruct(o_execute_instruct)
    );

    always #10 i_clk = ~i_clk;

    task send_command(input [INSTRUCT_MEM_WIDTH-1:0] cmd);
        begin
            i_instruct_or_command = cmd;
            i_rx_buffer_done = 1'b1;
            #30;
            i_rx_buffer_done = 1'b0;
            #20;
        end
    endtask

    initial begin
        i_clk = 0;
        i_reset = 1;
        i_register_value = 0;
        i_memory_value = 0;
        i_instruct_or_command = 0;
        i_rx_buffer_done = 0;
        i_tx_buffer_empty = 1;
        i_program_finished = 0;
        i_IF_ID_content = 0;
        i_ID_EX_content = 0;
        i_EX_MEM_content = 0;
        i_MEM_WB_content = 0;
        pulse_observed = 0;
        #40;
        i_reset = 0;
        #20;

        $display("\n===== UART PIPELINE INTERFACE TESTBENCH =====\n");

        // TEST 1: Instruction Reception and Programming
        $display("--- TEST 1: Instruction Reception and Programming ---");
        send_command(RECEIVE_INSTRUCTIONS);
        i_instruct_or_command = 32'hDEADBEEF; i_rx_buffer_done = 1; #20; i_rx_buffer_done = 0; #40;
        i_instruct_or_command = 32'hCAFEBABE; i_rx_buffer_done = 1; #20; i_rx_buffer_done = 0; #40;
        i_instruct_or_command = 32'h12345678; i_rx_buffer_done = 1; #20; i_rx_buffer_done = 0; #40;
        send_command(INSTRUCTS_EOF);
        #300;
        
        if (o_instruct_mem_write_enable === 0) begin
            $display("[PASS] Write enable cleared after programming");
            test_pass = test_pass + 1;
        end else begin
            $display("[FAIL] Write enable = %b (expected 0)", o_instruct_mem_write_enable);
            test_fail = test_fail + 1;
        end

        // TEST 2: Run Continuous Mode
        $display("\n--- TEST 2: Run Continuous Mode ---");
        send_command(RUN_CONTINUOUS);
        #40;
        if (o_pipeline_exec_mode === 2'b01) begin
            $display("[PASS] Exec mode = 01 (expected 01)");
            test_pass = test_pass + 1;
        end else begin
            $display("[FAIL] Exec mode = %b (expected 01)", o_pipeline_exec_mode);
            test_fail = test_fail + 1;
        end

        // TEST 3: Program Completion
        $display("\n--- TEST 3: Program Completion Handler ---");
        i_program_finished = 1;
        i_tx_buffer_empty = 1;
        #7000;  // Wait for SEND_REGISTERS (32x~20ns) + SEND_DATA_MEM (256x~20ns) + SEND_LATCHES (4x~20ns) = ~5840ns minimum
        if (o_pipeline_exec_mode === 2'b00) begin
            $display("[PASS] Exec mode = 00 (expected 00)");
            test_pass = test_pass + 1;
        end else begin
            $display("[FAIL] Exec mode = %b (expected 00)", o_pipeline_exec_mode);
            test_fail = test_fail + 1;
        end
        i_program_finished = 0;
        #200;  // Brief delay to ensure state settles back to WAIT_FOR_COMMAND
        i_tx_buffer_empty = 0;

        // TEST 4: Run Stepwise Mode
        $display("\n--- TEST 4: Run Stepwise Mode ---");
        send_command(RUN_STEPWISE);
        #40;
        if (o_pipeline_exec_mode === 2'b11) begin
            $display("[PASS] Exec mode = 11 (expected 11)");
            test_pass = test_pass + 1;
        end else begin
            $display("[FAIL] Exec mode = %b (expected 11)", o_pipeline_exec_mode);
            test_fail = test_fail + 1;
        end

        // TEST 5: Execute Single Instruction
        $display("\n--- TEST 5: Execute Single Instruction ---");
        pulse_observed = 0;
        i_instruct_or_command = EXECUTE_NEXT_INSTRUCTION;
        i_rx_buffer_done = 1;
        #10; if (o_execute_instruct) pulse_observed = 1;
        #10; if (o_execute_instruct) pulse_observed = 1;
        #10; i_rx_buffer_done = 0;
        #20;
        
        if (pulse_observed) begin
            $display("[PASS] Execute instruct pulsed HIGH");
            test_pass = test_pass + 1;
        end else begin
            $display("[FAIL] Execute instruct never pulsed");
            test_fail = test_fail + 1;
        end
        #500;

        // TEST 6: TX Buffer Flow Control
        $display("\n--- TEST 6: TX Buffer Flow Control ---");
        i_tx_buffer_empty = 0;
        send_command(FETCH_PIPELINE_DATA);
        #100;
        if (o_tx_buffer_start === 0) begin
            $display("[PASS] TX buffer start = 0 (buffer full backpressure)");
            test_pass = test_pass + 1;
        end else begin
            $display("[FAIL] TX buffer start = %b (expected 0)", o_tx_buffer_start);
            test_fail = test_fail + 1;
        end
        i_tx_buffer_empty = 1;
        #40;
        if (o_tx_buffer_start === 1) begin
            $display("[PASS] TX buffer start = 1 (buffer now empty)");
            test_pass = test_pass + 1;
        end else begin
            $display("[FAIL] TX buffer start = %b (expected 1)", o_tx_buffer_start);
            test_fail = test_fail + 1;
        end
        #1000;
        
        // TEST 7: Register Address Counter
        $display("\n--- TEST 7: Register Address Counter ---");
        if (o_register_address === 0) begin
            $display("[PASS] Register address = 0 (expected 0)");
            test_pass = test_pass + 1;
        end else begin
            $display("[FAIL] Register address = %d (expected 0)", o_register_address);
            test_fail = test_fail + 1;
        end

        $display("\n========================================");
        $display("SUMMARY: PASSED = %d | FAILED = %d", test_pass, test_fail);
        $display("========================================\n");

        $finish;
    end

endmodule
