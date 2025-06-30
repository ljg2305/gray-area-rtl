module deserializer #(
    int DATA_WIDTH = 8,
    bit HAS_ECC    = 0
    ) (
    input   logic                   clk_i,
    input   logic                   rst_n_i,
    input   logic                   serial_in_i,
    input   logic                   enable_i,
    input   logic                   start_i,
    output  logic [DATA_WIDTH-1:0]  parallel_out_o,
    output  logic                   valid_o,
    output logic [ADDR_WIDTH-1:0]   fault_location_o,
    output logic [1:0]              num_errors_o
    );

    `include "hamming_defines.svh"

    parameter PARALLEL_DATA_WIDTH = (HAS_ECC == 0) ? DATA_WIDTH : CODED_WIDTH;
    parameter COUNTER_WIDTH = $clog2(PARALLEL_DATA_WIDTH);

    logic [PARALLEL_DATA_WIDTH-1:0] parallel_regs;
    logic [PARALLEL_DATA_WIDTH-1:0] parallel_regs_padded;
    logic [DATA_WIDTH-1:0] parallel_regs_ecc;
    logic [COUNTER_WIDTH:0] bit_counter;
    logic in_packet;
    logic valid;
    logic [DATA_WIDTH-1:0] parallel_out;

    assign parallel_out = valid ? parallel_regs_ecc : '0;

    always_ff @( posedge clk_i ) begin
        if (!rst_n_i) begin
            parallel_regs <= '0;
            bit_counter <= '0;
            in_packet <= '0;
            valid <= '0;
        end else begin

            if (enable_i) begin
                parallel_regs <= {parallel_regs[PARALLEL_DATA_WIDTH-2:0],serial_in_i};
            end

            if (start_i) begin
                if (enable_i)
                    bit_counter <= 1;
                else
                    bit_counter <= '0;
            end else if (in_packet && enable_i) begin
                bit_counter <= bit_counter + 1;
            end

            if (start_i) begin
                in_packet <= 1'b1;
            end else if (in_packet) begin
                if (int'(bit_counter) == PARALLEL_DATA_WIDTH - 1) begin
                    in_packet <= '0;
                end
            end

            valid <= (in_packet && int'(bit_counter) == PARALLEL_DATA_WIDTH - 1  && enable_i && !start_i);


        end
    end


    generate
        if (HAS_ECC == 1) begin : ECC

            hamming_pad #(.DATA_WIDTH(DATA_WIDTH)) hamming_pad_inst (
                .data_in_i(parallel_regs[PARALLEL_DATA_WIDTH-1:PARALLEL_DATA_WIDTH-DATA_WIDTH]),
                //.pad_bits_i({<<CODE_BITS {parallel_regs[PARALLEL_DATA_WIDTH-DATA_WIDTH-1:0]}}),
                .pad_bits_i(parallel_regs[PARALLEL_DATA_WIDTH-DATA_WIDTH-1:0]),
                .data_out_o(parallel_regs_padded)
            );

            hamming_decode #(.DATA_WIDTH(DATA_WIDTH)) hamming_decode_inst (
            .clk_i(clk_i),
            .rst_n_i(rst_n_i),
            .data_in_i(parallel_regs_padded),
            .raw_data_o(),
            .data_out_o(parallel_regs_ecc),
            .fault_location_o(fault_location_o),
            .num_errors_o(num_errors_o)
            );

            // FLOP outputs
            always_ff @( posedge clk_i ) begin
                if (!rst_n_i) begin
                    valid_o <= '0;
                    parallel_out_o <= '0;
                end else begin
                    parallel_out_o <= parallel_out;
                    valid_o <= valid;
                end
            end

        end else begin
            assign parallel_regs_ecc = parallel_regs;
            assign parallel_out_o = parallel_out;
            assign valid_o = valid;
        end
    endgenerate

//dump vcd

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,deserializer);
end

endmodule