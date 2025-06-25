module serializer #(
    int DATA_WIDTH = 8
    ) (
    input logic clk_i,
    input logic rst_n_i,
    output logic serial_out_o,
    output logic enable_o,
    output logic start_o,
    input logic [DATA_WIDTH-1:0] parallel_in_i,
    input logic valid_in_i,
    output logic ready_o
    );

    parameter COUNTER_WIDTH = $clog2(DATA_WIDTH);
    logic [DATA_WIDTH-1:0] parallel_regs;
    logic [COUNTER_WIDTH:0] bit_counter;
    logic in_packet;

    assign ready_o = !in_packet || in_packet && (bit_counter >= DATA_WIDTH - 2) && !valid_in_i;


    always_ff @( posedge clk_i ) begin
        if (!rst_n_i) begin
            parallel_regs <= '0;
            in_packet <= 1'b0;
            serial_out_o <= 1'b0;
            start_o <= 1'b0;
            enable_o <= 1'b0;
            bit_counter <= '0;
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
            end else if (in_packet) begin
                if (bit_counter == DATA_WIDTH - 1) begin
                    in_packet <= 1'b0;
                    bit_counter <= '0;
                end else begin

                    enable_o <= 1'b1;
                    bit_counter <= bit_counter + 1;
                    parallel_regs <= {parallel_regs[DATA_WIDTH-2:0],1'b0};
                    serial_out_o <= parallel_regs[DATA_WIDTH-1];
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