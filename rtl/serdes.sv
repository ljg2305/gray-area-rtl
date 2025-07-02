module serdes #(
    int DATA_WIDTH  = 8,
    int FIFO_DEPTH  = 0,
    bit HAS_ECC     = 0,
    bit HAS_SNIFFER = 0
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

    logic serial_out;
    logic enable;
    logic start;


    logic [DATA_WIDTH-1:0] data_to_serializer;
    logic valid_to_serializer;
    logic ready_from_serializer,ready_to_fifo, previous_ready;
    logic serial_from_serializer, serial_to_deserializer;
    logic enable_from_serializer, enable_to_deserializer;
    logic start_from_serializer, start_to_deserializer;

    generate
        if (FIFO_DEPTH == 0) begin : g_bypass_fifo
            // bypass fifo
            // hooking up the fifo could change the IO behavour
            assign data_to_serializer = parallel_in_i;
            assign valid_to_serializer = valid_in_i;
            assign ready_out_o = ready_from_serializer;
            assign fifo_full_o = 1'b0;
            assign fifo_empty_o = 1'b0;
        end else begin : g_fifo
            fifo #(.DATA_WIDTH(DATA_WIDTH),.FIFO_DEPTH(FIFO_DEPTH)) fifo_inst
                (
                    .clk_i(clk_i),
                    .rst_n_i(rst_n_i),
                    .full_o(fifo_full_o),
                    .empty_o(fifo_empty_o),
                    .data_in_i(parallel_in_i),
                    .data_out_o(data_to_serializer),
                    .write_valid_i(valid_in_i),
                    .write_ready_o(ready_out_o),
                    .read_valid_o(valid_to_serializer),
                    .read_ready_i(ready_to_fifo)
                );

            pulse_gen pulse_gen_inst (
                .clk_i(clk_i),
                .rst_n_i(rst_n_i),
                .signal_in_i(ready_from_serializer),
                .hold_i(fifo_empty_o),
                .pulse_out_o(ready_to_fifo)
            );


        end
    endgenerate

    serializer #(.DATA_WIDTH(DATA_WIDTH),.HAS_ECC(HAS_ECC)) serializer_inst
        (
            .clk_i(clk_i),
            .rst_n_i(rst_n_i),
            .serial_out_o(serial_from_serializer),
            .enable_o(enable),
            .start_o(start),
            .parallel_in_i(data_to_serializer),
            .valid_in_i(valid_to_serializer),
            .ready_o(ready_from_serializer)
        );


    generate
        if (HAS_SNIFFER) begin : g_sniffer

            sniffer siffer_inst
                (
                    .clk_i(clk_i),
                    .rst_n_i(rst_n_i),
                    .serial_in_i(serial_from_serializer),
                    .enable_i(enable_from_serializer),
                    .start_i(start_from_serializer),
                    .serial_out_o(serial_to_deserializer),
                    .enable_o(enable_to_deserializer),
                    .start_o(start_to_deserializer)
                );

        end else begin : g_no_sniffer

            assign serial_to_deserializer = serial_from_serializer;
            assign enable_to_deserializer = enable_from_serializer;
            assign start_to_deserializer  = start_from_serializer;

        end
    endgenerate


    deserializer #(.DATA_WIDTH(DATA_WIDTH),.HAS_ECC(HAS_ECC)) deserializer_inst
        (
            .clk_i(clk_i),
            .rst_n_i(rst_n_i),
            .serial_in_i(serial_to_deserializer),
            .enable_i(enable),
            .start_i(start),
            .parallel_out_o(parallel_out_o),
            .valid_o(valid_out_o),
            .fault_location_o(),
            .num_errors_o()
        );

`ifndef synthesis
//dump vcd

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,serdes);
end

`endif  // synthesis

endmodule