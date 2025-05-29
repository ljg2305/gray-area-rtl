
module pulse_gen (
        input  logic clk,
        input  logic rst_n,
        input  logic signal_in, 
        input  logic hold, 
        output logic pulse_out
    ); 

    logic previous_in, hold_latched;
    logic raw_pulse, held_pulse;

    //pulse generator 
    //ready in : 0000011111000
    //empty    : 0000000000000
    //ready out: 0000010000000

    //ready in : 0000011111000
    //empty    : 0001111000000
    //ready out: 0000011000000

    // this adds the requirement for one extra flop to track if pulse has been sent 
    //ready in : 0000011111000
    //empty    : 0000000111000
    //ready out: 0000010000000

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

    // hold_latched && hold ensures that the pulse is not held for a cycle longer than it should be 
    assign held_pulse = (!previous_in || hold_latched && hold) && signal_in;
    assign pulse_out = held_pulse;

`ifndef synthesis 

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,pulse_gen);
end

`endif 

endmodule