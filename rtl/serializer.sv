import gray_area_package::*;

module serializer #(
    DATA_WIDTH = 8,
    HAS_ECC = 0
    ) (
    input  logic                    clk_i,
    input  logic                    rst_n_i,
    output logic                    serial_out_o,
    output logic                    enable_o,
    output logic                    start_o,
    input  logic [DATA_WIDTH-1:0]   parallel_in_i,
    input  logic                    valid_in_i,
    output logic                    ready_o
    );

    `include "hamming_defines.svh"

    parameter PARALLEL_DATA_WIDTH = (HAS_ECC == 0) ? DATA_WIDTH : CODED_WIDTH;
    parameter COUNTER_WIDTH = $clog2(PARALLEL_DATA_WIDTH);

    logic [CODE_BITS-1:0] parity_data;
    logic [CODE_BITS-1:0] parity_regs;
    logic                 parity_valid;

    logic [DATA_WIDTH-1:0] parallel_regs;
    logic [COUNTER_WIDTH:0] bit_counter;
    logic in_packet;


    logic serial_from_parity;

    assign ready_o = !in_packet || in_packet && (int'(bit_counter) >= PARALLEL_DATA_WIDTH - 2) && !valid_in_i;


    generate
        if (HAS_ECC == 1) begin
            hamming_encode #( .DATA_WIDTH(DATA_WIDTH)) hamming_encode_inst (
                .clk_i(clk_i),
                .rst_n_i(rst_n_i),
                .data_in_i(parallel_in_i),
                .valid_in_i(valid_in_i),
                .data_out_o(),
                .parity_bits_o(parity_data),
                .valid_out_o(parity_valid)
                );
        end
    endgenerate


    always_ff @( posedge clk_i ) begin
        if (!rst_n_i) begin
            parallel_regs <= '0;
            in_packet <= 1'b0;
            serial_out_o <= 1'b0;
            start_o <= 1'b0;
            enable_o <= 1'b0;
            bit_counter <= '0;
            if (HAS_ECC)
                parity_regs <= '0;
        end else begin
            start_o <= 1'b0;
            enable_o <= 1'b0;
            serial_out_o <= 1'b0;
            if (valid_in_i) begin
                parallel_regs <= {parallel_in_i[DATA_WIDTH-2:0],1'b0};
                in_packet <= 1'b1;
                serial_out_o <= parallel_in_i[DATA_WIDTH-1];
                start_o <= 1'b1;
                enable_o <= 1'b1;
                bit_counter <= '0;
                serial_from_parity <= '0;
            end else if (in_packet) begin

                if (HAS_ECC) begin
                    if (parity_valid) begin
                        parity_regs <= parity_data;
                    end
                end

                if (int'(bit_counter) == PARALLEL_DATA_WIDTH - 1) begin
                    in_packet <= 1'b0;
                    bit_counter <= '0;
                end else begin
                  
                    enable_o <= 1'b1;
                    bit_counter <= bit_counter + 1;
                    if (int'(bit_counter) < DATA_WIDTH - 1  ) begin
                        parallel_regs <= {parallel_regs[DATA_WIDTH-2:0],1'b0};
                        serial_out_o <= parallel_regs[DATA_WIDTH-1];
                        serial_from_parity <= 0;
                    end else if (HAS_ECC) begin
                        parity_regs <= {parity_regs[CODE_BITS-2:0],1'b0};
                        serial_out_o <= parity_regs[CODE_BITS-1];
                        serial_from_parity <= 1;
                        //parity_regs <= {1'b0,parity_regs[CODE_BITS-1:1]};
                        //serial_out_o <= 0;
                    end
                end
            end
        end
    end

//dump vcd

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,serializer);
end

endmodule