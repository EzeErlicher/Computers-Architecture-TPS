module top
#
(
    parameter N_SWITCHES=8,
    parameter N_BUTTONS=3,
    parameter NB_OPERATIONS=6,
    parameter N_LEDS=8
)

(
    input wire                   I_clk,
    input wire  [N_SWITCHES-1:0] I_sw,
    input wire  [N_BUTTONS-1:0]  I_button,
    input wire                   reset_button,
    output wire [N_LEDS-1:0]     O_led,
    output wire                  O_overflow,
    output wire                  O_zero
     
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
        .o_result(O_led),
        .o_overflow(O_overflow),
        .o_zero(O_zero)
    );

    always @(posedge I_clk) begin
        if (reset_button) begin
            I_data_a <= {(N_SWITCHES) {1'b0}};
            I_data_b <= {(N_SWITCHES) {1'b0}};
            I_operation_code <= {(NB_OPERATIONS) {1'b0}};
        end

        if(I_button[0]) begin //Pulsador 1 = Data A
            I_data_a <= I_sw;
        end
        if (I_button[1]) begin //Pulsador 2 = Data B
            I_data_b <= I_sw;
        end
        if (I_button[2]) begin //Pulsador 3 = Operation
            I_operation_code <= I_sw[NB_OPERATIONS-1:0]; 
        end
    end
