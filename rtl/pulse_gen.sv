
module pulse_gen (
        input  logic clk_i,
        input  logic rst_n_i,
        input  logic signal_in_i,
        input  logic hold_i,
        output logic pulse_out_o
    );

    logic previous_in, hold_latched;
    logic raw_pulse, held_pulse;

    always_ff @(posedge clk_i) begin
        if (!rst_n_i) begin
            previous_in <= 1'b0;
            hold_latched <= 1'b0;
        end else begin
            previous_in <= signal_in_i;
            // hold_i should be captured at the first pulse
            // trasition to prevent the act of empting a
            // fifo creating a new data request
            if (raw_pulse && hold_i)
                hold_latched <= 1'b1;
            else if (!hold_i || !signal_in_i)
                hold_latched <= 1'b0;
        end
    end

    assign raw_pulse = (!previous_in && signal_in_i);

    assign held_pulse = (!previous_in || hold_latched ) && signal_in_i;
    assign pulse_out_o = held_pulse;

`ifndef synthesis

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,pulse_gen);
end

`endif  // synthesis

endmodule