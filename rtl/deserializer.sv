module deserializer #( 
    DATA_WIDTH = 8
    ) (
    input logic clk,
    input logic rst_n,
    input logic serial_in, 
    input logic enable, 
    input logic start, 
    output logic [DATA_WIDTH-1:0] parallel_out,
    output logic valid
    ); 

    parameter COUNTER_WIDTH = $clog2(DATA_WIDTH);
    logic [DATA_WIDTH-1:0] parallel_regs;
    logic [COUNTER_WIDTH:0] bit_counter;
    logic in_packet; 

    assign parallel_out = valid ? parallel_regs : '0;

    always_ff @( posedge clk ) begin 
        if (!rst_n) begin
            parallel_regs <= '0;
            bit_counter <= '0;
            in_packet <= '0;
            valid <= '0;
        end else begin 
            
            if (enable) begin 
                parallel_regs <= {parallel_regs[DATA_WIDTH-2:0],serial_in};
            end 

            if (start) begin 
                if (enable)  
                    bit_counter <= 1;
                else 
                    bit_counter <= '0;
            end else if (in_packet && enable) begin 
                bit_counter <= bit_counter + 1;
            end

            if (start) begin 
                in_packet <= 1'b1;      
            end else if (in_packet) begin 
                if (bit_counter == DATA_WIDTH - 1) begin 
                    in_packet <= '0;
                end 
            end 

            valid <= (in_packet && bit_counter == DATA_WIDTH - 1  && enable && !start);


        end 
    end

//dump vcd 

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,deserializer);
end

endmodule