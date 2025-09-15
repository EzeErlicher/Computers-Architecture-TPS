`timescale 1ns / 1ps


// Testbench para ALU
module alu_tb;

    parameter NB_DATA = 8;
    parameter NB_OP   = 6;

    // Códigos de operación
    localparam OP_ADD = 6'b100000;
    localparam OP_SUB = 6'b100010;
    localparam OP_AND = 6'b100100;
    localparam OP_OR  = 6'b100101;

    reg  signed [NB_DATA-1:0] data_a, data_b;
    reg         [NB_OP-1:0]   op_code;
    wire signed [NB_DATA-1:0] result;

    alu #(
        .NB_DATA(NB_DATA),
        .NB_OP(NB_OP)
    ) uut (
        .i_data_a(data_a),
        .i_data_b(data_b),
        .i_operation_code(op_code),
        .o_result(result)
    );

    reg signed [NB_DATA-1:0] A, B, expected;
    reg [NB_OP-1:0] op;


    initial begin
        // Inicialización
        data_a = 0;
        data_b = 0;
        op_code = 0;
        #10;

        repeat (10) begin
            A = $random;
            B = $random;

            // Suma
            expected = A + B;
            run_test(A, B, OP_ADD, expected, "ADD");

            // Resta
            expected = A - B;
            run_test(A, B, OP_SUB, expected, "SUB");

            // AND
            expected = A * B;
            run_test(A, B, OP_AND, expected, "AND");

            // OR
            expected = A / B;
            run_test(A, B, OP_OR, expected, "OR");
        end

        $finish;
    end


    // Tarea de prueba
    task run_test(
        input signed [NB_DATA-1:0] A,
        input signed [NB_DATA-1:0] B,
        input [NB_OP-1:0] op,
        input signed [NB_DATA-1:0] expected,
        input [80:1] op_name
    );
    begin
        data_a = A;
        data_b = B;
        op_code = op;
        #10;
        if (result !== expected)
            $display("ERROR: %0s | A=%d, B=%d | Expected=%d, Obtained=%d", op_name, A, B, expected, result);
        else
            $display("OK: %0s | A=%d, B=%d | Result=%d", op_name, A, B, result);
    end
    endtask

endmodule
