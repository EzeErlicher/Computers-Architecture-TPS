module top
#
(
    parameter N_SWITCHES=8,
    parameter N_BUTTONS=3,
    parameter NB_OPERATIONS=6,
    parameter N_LEDS=8
)

(
    input wire                   i_clk,
    input wire  [N_SWITCHES-1:0] i_sw,
    input wire  [N_BUTTONS-1:0]  i_button,
    output wire [N_LEDS-1:0]     o_led
     
);

    reg signed I_data_a, I_data_b;
    reg I_operation_code;

    alu #(
        .NB_DATA(N_SWITCHES),
        .NB_OP(NB_OPERATIONS)
    ) alu_unit (
        .i_data_a(I_data_a),
        .i_data_b(I_data_b),
        .i_operation_code(I_operation_code),
        .o_result(o_led)
    );

    always @(posedge i_clk) begin
        // ToDo: Añadir boton de reset

        if(i_button[0]) begin //Pulsador 1
            I_data_a <= i_sw;
        end
        if (i_button[1]) begin //Pulsador 2
            I_data_b <= i_sw;
        end
        if (i_button[2]) begin //Pulsador 3
            I_operation_code <= i_sw[NB_OPERATIONS-1:0]; 
        end
    end

endmodule
