
module pulse_gen (
        input  logic clk,
        input  logic rst_n,
        input  logic signal_in, 
        input  logic hold, 
        output logic pulse_out
    ); 

    logic previous_in, hold_latched;
    logic raw_pulse, held_pulse;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            previous_in <= 1'b0;
            hold_latched <= 1'b0;
        end else begin
            previous_in <= signal_in;
            // hold should be captured at the first pulse 
            // trasition to prevent the act of empting a 
            // fifo creating a new data request
            if (raw_pulse && hold)
                hold_latched <= 1'b1;
            else if (!hold || !signal_in)
                hold_latched <= 1'b0;
        end
    end

    assign raw_pulse = (!previous_in && signal_in);

    assign held_pulse = (!previous_in || hold_latched ) && signal_in;
    assign pulse_out = held_pulse;

`ifndef synthesis 

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,pulse_gen);
end

`endif 

endmodule