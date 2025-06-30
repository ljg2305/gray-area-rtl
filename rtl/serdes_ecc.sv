module serdes_ecc #(
    DATA_WIDTH = 8
    ) (
        input  logic clk_i,
        input  logic rst_n_i,

        input  logic [DATA_WIDTH-1:0] parallel_in_i,
        input  logic valid_in_i,
        output logic ready_out_o,

        output  logic [DATA_WIDTH-1:0] parallel_out_o,
        output  logic valid_out_o,

        // FIFO flags
        output logic fifo_full_o,
        output logic fifo_empty_o

    );

    serdes #(.FIFO_DEPTH(16),.DATA_WIDTH(DATA_WIDTH),.HAS_ECC(1)) serdes_inst
        (
            .clk_i,
            .rst_n_i,
            .parallel_in_i,
            .valid_in_i,
            .ready_out_o,
            .parallel_out_o,
            .valid_out_o,
            .fifo_full_o,
            .fifo_empty_o
        );


`ifndef synthesis
// assertions

// dump vcd
initial begin
  $dumpfile("dump.vcd");
  $dumpvars(1,serdes_ecc);
end

`endif //synthesis

endmodule