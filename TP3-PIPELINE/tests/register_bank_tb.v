`timescale 1ns / 1ps

module register_bank_tb;

    parameter NB_DATA = 32;
    parameter NB_REG  = 5;

    reg                  i_clk;
    reg                  i_reset;
    reg                  i_write_enable;
    reg  [NB_REG-1:0]    i_write_reg;
    reg  [NB_DATA-1:0]   i_write_data;
    reg  [NB_REG-1:0]    i_read_reg1;
    reg  [NB_REG-1:0]    i_read_reg2;
    wire [NB_DATA-1:0]   o_register1;
    wire [NB_DATA-1:0]   o_register2;

    reg  [NB_DATA-1:0]   exp0;
    reg  [NB_DATA-1:0]   exp7;

    register_bank #(
        .NB_DATA(NB_DATA),
        .NB_REG (NB_REG)
    ) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_read_reg1(i_read_reg1),
        .i_read_reg2(i_read_reg2),
        .i_write_reg(i_write_reg),
        .i_write_data(i_write_data),
        .i_write_enable(i_write_enable),
        .o_register1(o_register1),
        .o_register2(o_register2)
    );

    always #5 i_clk = ~i_clk;

    initial begin
        i_clk = 0; i_reset = 1; i_write_enable = 0;
        
        i_write_reg = 0; i_write_data = 0;
        i_read_reg1 = 0; i_read_reg2 = 0;

        #10;
        i_reset = 0;

        exp0 = 32'hA5A5A5A5;
        i_write_reg = 5'd0;
        i_write_data = exp0;
        i_write_enable = 1;

        #10;
        $display("[DBG] Internal reg0: %h", dut.registers[0]);
        i_write_enable = 0; #10;
        i_read_reg1 = 5'd0; #10;
        $display("[WRITE] reg0 = %0d | [READ] reg0 = %0d | Status: %s", exp0, o_register1, (o_register1 === exp0) ? "OK" : "ERR");

        exp7 = 32'hA3A3A3A3;
        i_write_reg = 5'd7; 
        i_write_data = exp7;
        i_write_enable = 1;

        #10;
        $display("[DBG] Internal reg7: %h", dut.registers[7]);
        i_write_enable = 0; #10;
        i_read_reg1 = 5'd7; #10;

        $display("[WRITE] reg7 = %0d | [READ] reg7 = %0d | Status: %s", exp7, o_register1, (o_register1 === exp7) ? "OK" : "ERR");

        i_read_reg1 = 5'd0; i_read_reg2 = 5'd7; #10;
        $display("[DOUBLE READ] reg0 = %0d (Expected: %0d) | Status: %s", o_register1, exp0, (o_register1 === exp0) ? "OK" : "ERR");
        $display("[DOUBLE READ] reg7 = %0d (Expected: %0d) | Status: %s", o_register2, exp7, (o_register2 === exp7) ? "OK" : "ERR");

        #10 $finish;
    end

endmodule