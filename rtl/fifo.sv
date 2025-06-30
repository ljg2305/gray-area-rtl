module fifo #(
    int DATA_WIDTH = 8,
    int FIFO_DEPTH = 16,
    int ADDR_WIDTH = $clog2(FIFO_DEPTH)
    ) (
    input logic clk_i,
    input logic rst_n_i,
    output logic full_o,
    output logic empty_o,
    input  logic [DATA_WIDTH-1:0] data_in_i,
    output logic [DATA_WIDTH-1:0] data_out_o,

    // Write (Producer -> FIFO)
    input  logic         write_valid_i,
    output logic         write_ready_o,

    // Read (FIFO -> Consumer)
    output logic         read_valid_o,
    input  logic         read_ready_i
    );

    logic [ADDR_WIDTH-1:0] rd_ptr, wr_ptr;
    logic [ADDR_WIDTH:0] rd_idx, wr_idx;
    logic [FIFO_DEPTH-1:0] [DATA_WIDTH-1:0] fifo_regs;
    logic [DATA_WIDTH-1:0] read_data;

    assign rd_ptr = rd_idx[ADDR_WIDTH-1:0];
    assign wr_ptr = wr_idx[ADDR_WIDTH-1:0];

    assign empty_o = (rd_idx == wr_idx);
    //assign read_valid_o_next = !empty_o;
    assign full_o  = (wr_ptr == rd_ptr) && (rd_idx[ADDR_WIDTH] != wr_idx[ADDR_WIDTH]);
    assign write_ready_o = !full_o;
    assign data_out_o = read_valid_o ? read_data : '0;


    always_ff @( posedge clk_i ) begin : pointers
        if (!rst_n_i) begin
            wr_idx <= '0;
            rd_idx <= '0;
            fifo_regs <= '0;
            read_data <= '0;
            read_valid_o <= '0;
        end else begin
            if (write_valid_i && write_ready_o) begin
                fifo_regs[wr_ptr] <= data_in_i;
                wr_idx <= wr_idx + 1;
            end
            if (!empty_o && read_ready_i) begin
                rd_idx <= rd_idx + 1;
            end
            if (read_ready_i) begin
                read_data <= fifo_regs[rd_ptr];
            end
            read_valid_o <= !empty_o && read_ready_i;
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

assert property (@(posedge clk_i) !(full_o && empty_o));

always @(posedge clk_i) begin
    if (full_o & write_valid_i) begin
        $warning("write attempted to fifo when fifo is full_o");
    end
end

// dump vcd
 initial begin
     $dumpfile("dump.vcd");
     $dumpvars(1,fifo);
 end

`endif //synthesis

endmodule