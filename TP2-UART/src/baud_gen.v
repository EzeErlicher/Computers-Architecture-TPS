module baud_rate_gen 
  #( 
        parameter  NB_COUNTER =   9,
        parameter  MOD = 163
    )
    ( 
        input  wire    i_clk,
        input  wire    i_reset,
        output wire    o_tick
    ); 

    reg  [NB_COUNTER-1:0]  r_counter;
    wire [NB_COUNTER-1:0] r_next;

    always @ (posedge clk)begin
        if (reset)
            r_counter <= 0; 
        else 
            r_counter <= r_next;
    end

    // Alcanzó el valor máximo del contador?
    wire last_value = (r_counter == MOD-1);
    // Siguiente valor del contador
    assign r_next = last_value ? 0 : r_counter + 1; 
    // Tick pulse
    assign tick = last_value ? 1'b1 : 1'b0; 

endmodule 