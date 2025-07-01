
module sniffer (
        input  logic clk_i,
        input  logic rst_n_i,
        input  logic serial_in_i,
        input  logic start_i,
        input  logic enable_i, 
        output logic serial_out_o,
        output logic start_o,
        output logic enable_o
    );

    assign serial_out_o = serial_in_i;
    assign start_o      = start_i;
    assign enable_o     = enable_i;

    // registers used for state machines can look for multiple bytes at the same time
    // state machines flag to corrupt/flip bits of a packet. 

    //logic [4:0] byte_check; 

    //always_ff @( clk_i ) begin : byte_parser
    //    
    //    
    //end



`ifndef synthesis

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,sniffer);
end

`endif  // synthesis

endmodule