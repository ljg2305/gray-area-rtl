module fifo #( 
    DATA_WIDTH = 8,
    FIFO_DEPTH = 16,
    ADDR_WIDTH = $clog2(FIFO_DEPTH)
    ) (
    input logic clk,
    input logic rst_n,
    output logic full,
    output logic empty, 
    input  logic [DATA_WIDTH-1:0] data_in, 
    output logic [DATA_WIDTH-1:0] data_out,
    
    // Write (Producer -> FIFO)
    input  logic         write_valid,
    output logic         write_ready,

    // Read (FIFO -> Consumer)
    output logic         read_valid,
    input  logic         read_ready
    ); 

    logic [ADDR_WIDTH-1:0] rd_ptr, wr_ptr; 
    logic [ADDR_WIDTH:0] rd_idx, wr_idx; 
    logic [FIFO_DEPTH-1:0] [DATA_WIDTH-1:0] fifo_regs;
    logic [DATA_WIDTH-1:0] read_data; 

    assign rd_ptr = rd_idx[ADDR_WIDTH-1:0];
    assign wr_ptr = wr_idx[ADDR_WIDTH-1:0];

    assign empty = (rd_idx == wr_idx); 
    //assign read_valid_next = !empty;  
    assign full  = (wr_ptr == rd_ptr) && (rd_idx[ADDR_WIDTH] != wr_idx[ADDR_WIDTH]);
    assign write_ready = !full; 
    assign data_out = read_valid ? read_data : '0;


    always_ff @( posedge clk ) begin : pointers
        if (!rst_n) begin
            wr_idx <= '0;
            rd_idx <= '0;
            fifo_regs <= '0;
            read_data <= '0;
            read_valid <= '0;
        end else begin 
            if (write_valid && write_ready) begin 
                fifo_regs[wr_ptr] <= data_in;
                wr_idx <= wr_idx + 1; 
            end 
            if (!empty && read_ready) begin 
                rd_idx <= rd_idx + 1; 
            end 
            if (read_ready) begin
                read_data <= fifo_regs[rd_ptr];
            end
            read_valid <= !empty && read_ready;
        end 
    end

`ifndef synthesis 
// assertions
// iverilog does not support concurent assertions
initial begin
    if ((FIFO_DEPTH & (FIFO_DEPTH - 1)) != 0) begin
        $fatal(1, "fifo_depth must be a power of 2");
    end
    if (FIFO_DEPTH == 0) begin
        $fatal(1, "fifo_depth must not be zero");
    end
    if (DATA_WIDTH == 0) begin
        $fatal(1, "data_width must not be zero");
    end
end

assert property (@(posedge clk) !(full && empty));

always @(posedge clk) begin
    if (full & write_valid) begin 
        $warning("write attempted to fifo when fifo is full");
    end 
end

// dump vcd 
 initial begin
     $dumpfile("dump.vcd");
     $dumpvars(1,fifo);
 end

`endif //synthesis

endmodule