module serdes_fifo #( 
    DATA_WIDTH = 8
    ) (
        input  logic clk,
        input  logic rst_n,

        input  logic [DATA_WIDTH-1:0] parallel_in,
        input  logic valid_in,
        output logic ready_out,

        output  logic [DATA_WIDTH-1:0] parallel_out,
        output  logic valid_out,

        // FIFO flags
        output logic fifo_full, 
        output logic fifo_empty
    ); 

    serdes #(.FIFO_DEPTH(16),.DATA_WIDTH(DATA_WIDTH)) serdes_inst 
        (
            .clk,
            .rst_n,
            .parallel_in,
            .valid_in,
            .ready_out,
            .parallel_out,
            .valid_out,
            .fifo_full, 
            .fifo_empty
        );


`ifndef synthesis 
// assertions

// dump vcd 
initial begin
  $dumpfile("dump.vcd");
  $dumpvars(1,serdes_fifo);
end

`endif //synthesis

endmodule