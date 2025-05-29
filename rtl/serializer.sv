// TODO: add a ready flag to the serializer to be able to request data from the fifo

module serializer #( 
    DATA_WIDTH = 8
    ) (
    input logic clk,
    input logic rst_n,
    output logic serial_out, 
    output logic enable, 
    output logic start, 
    input logic [DATA_WIDTH-1:0] parallel_in,
    input logic valid,
    output logic ready
    ); 

    parameter COUNTER_WIDTH = $clog2(DATA_WIDTH);
    logic [DATA_WIDTH-1:0] parallel_regs;
    logic [COUNTER_WIDTH:0] bit_counter;
    logic in_packet; 

    assign ready = !in_packet || in_packet && (bit_counter >= DATA_WIDTH - 2) && !valid;


    always_ff @( posedge clk ) begin 
        if (!rst_n) begin
            parallel_regs <= '0;
            in_packet <= 1'b0;
            serial_out <= 1'b0;
            start <= 1'b0;
            enable <= 1'b0;
            bit_counter <= '0;
        end else begin 
            start <= 1'b0;
            enable <= 1'b0;
            serial_out <= 1'b0;
            if (valid) begin
                parallel_regs <= {parallel_in[DATA_WIDTH-2:0],1'b0};
                in_packet <= 1'b1;
                serial_out <= parallel_in[DATA_WIDTH-1];
                start <= 1'b1;
                enable <= 1'b1;
                bit_counter <= '0;
            end else if (in_packet) begin 
                if (bit_counter == DATA_WIDTH - 1) begin
                    in_packet <= 1'b0;
                    bit_counter <= '0;
                end else begin

                    enable <= 1'b1;
                    bit_counter <= bit_counter + 1;
                    parallel_regs <= {parallel_regs[DATA_WIDTH-2:0],1'b0};
                    serial_out <= parallel_regs[DATA_WIDTH-1];
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