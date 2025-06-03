module serdes #( 
    DATA_WIDTH = 8,
    FIFO_DEPTH = 0
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

    logic serial_out;
    logic enable;
    logic start;


    logic [DATA_WIDTH-1:0] data_to_serializer;
    logic valid_to_serializer;
    logic ready_from_serializer,ready_to_fifo, previous_ready;
    generate
        if (FIFO_DEPTH == 0) begin 
            // bypass fifo
            // hooking up the fifo could change the IO behavour
            assign data_to_serializer = parallel_in;
            assign valid_to_serializer = valid_in;
            assign ready_out = ready_from_serializer; 
            assign fifo_full = 1'b0;
            assign fifo_empty = 1'b0;
        end else begin 
            fifo #(.DATA_WIDTH(DATA_WIDTH),.FIFO_DEPTH(FIFO_DEPTH)) fifo_inst
                (
                    .clk(clk),
                    .rst_n(rst_n),
                    .full(fifo_full),
                    .empty(fifo_empty), 
                    .data_in(parallel_in), 
                    .data_out(data_to_serializer),
                    .write_valid(valid_in),
                    .write_ready(ready_out),
                    .read_valid(valid_to_serializer),
                    .read_ready(ready_to_fifo)
                );
                
            pulse_gen pulse_gen_inst (
                .clk(clk),
                .rst_n(rst_n),
                .signal_in(ready_from_serializer),
                .hold(fifo_empty), 
                .pulse_out(ready_to_fifo)
            ); 


        end 
    endgenerate

    serializer #(.DATA_WIDTH(DATA_WIDTH)) serializer_inst
        (
            .clk(clk),
            .rst_n(rst_n),
            .serial_out(serial_out),
            .enable(enable),
            .start(start),
            .parallel_in(data_to_serializer),
            .valid(valid_to_serializer),
            .ready(ready_from_serializer)
        );


    deserializer #(.DATA_WIDTH(DATA_WIDTH)) deserializer_inst
        (
            .clk(clk),
            .rst_n(rst_n),
            .serial_in(serial_out),
            .enable(enable),
            .start(start),
            .parallel_out(parallel_out),
            .valid(valid_out)
        );

//dump vcd 

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,serdes);
end

endmodule