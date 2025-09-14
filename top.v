module top
#
(
    parameter switches_array_len=8,
    parameter buttons_array_len=3,
    parameter led_array_len=8
)

(
    input wire clk,
    input wire [switches_array_len-1:0] i_sw,
    input wire [buttons_array_len-1:0] i_button,
    output wire [led_array_len-1:0] o_led
     
);

    assign o_led = i_sw;

/*    always @(posedge clk) 
    begin
       reg o_led = i_sw;
    end
 */
endmodule
