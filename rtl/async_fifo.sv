async_fifo
    #(
        int DATA_WIDTH = 8,
        int FIFO_DEPTH = 16,
    ) (
        input logic                     wr_clk_i,
        input logic                     wr_rst_n_i,
        input logic                     wr_enable_i,
        input logic [DATA_WIDTH-1:0]    wr_data_i,
        output logic                    full_o,

        input logic                     rd_clk_i,
        input logic                     rd_rst_n_i,
        input logic                     rd_enable_i,
        output logic [DATA_WIDTH-1:0]   rd_data_o,
        output logic                    empty_o
    );
    parameter int PTR_WIDTH = $clog2(FIFO_DEPTH)+1;

    // signals

    //WRITE SIDE SIGNALS
    logic [FIFO_DEPTH-1:0] [DATA_WIDTH-1:0] mem ;

    logic wr_en;
    logic [PTR_WIDTH-1:0] wr_ptr;
    logic [PTR_WIDTH-1:0] wr_ptr_gray_coded;
    logic [PTR_WIDTH-1:0] rd_ptr_wr_dom;
    logic full;

    // READ SIDE SIGNALS
    logic rd_en;
    logic [PTR_WIDTH-1:0] rd_ptr;
    logic [PTR_WIDTH-1:0] rd_ptr_gray_coded;
    logic [PTR_WIDTH-1:0] wr_ptr_rd_dom;
    logic [DATA_WIDTH-1:0] rd_data;
    logic empty;

    // WRITE SIDE LOGIC
    assign full = {!wr_ptr[PTR_WIDTH-1],wr_ptr[PTR_WIDTH-2:0]} == rd_ptr_wr_dom;
    assign wr_en = wr_enable_i && !full;

    always_ff @(posedge wr_clk_i && negedge wr_rst_n_i) begin
        if (!wr_rst_n_i) begin
            mem <= '0;
            wr_ptr <= '0;
        end else begin
            if (wr_en) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr+1;
            end
        end
    end

    b2g b2g_wr_ptr_inst #(.WIDTH(PTR_WIDTH)) (
        .binary_i(wr_ptr),
        .gray_code_o(wr_ptr_gray_coded)
    );

    g2b g2b_rd_ptr_inst #(.WIDTH(PTR_WIDTH)) (
        .clk_i(wr_clk_i),
        .rst_n_i(wr_rst_n_i),
        .gray_code_i(rd_ptr_gray_coded)
        .binary_o(rd_ptr_wr_dom),
    );

    // READ SIDE LOGIC
    assign empty = wr_ptr_rd_dom == rd_ptr;
    assign rd_en = rd_enable_i && !empty;

    always_ff @(posedge rd_clk_i && negedge rd_rst_n_i) begin
        if (!rd_rst_n_i) begin
            rd_ptr <= '0;
        end else begin
            if (rd_en) begin
                rd_ptr <= rd_ptr+1;
            end
        end
    end

    b2g b2g_rd_ptr_inst #(.WIDTH(PTR_WIDTH)) (
        .binary_i(rd_ptr),
        .gray_code_o(rd_ptr_gray_coded)
    );

    g2b g2b_wr_ptr_inst #(.WIDTH(PTR_WIDTH)) (
        .clk_i(rd_clk_i),
        .rst_n_i(rd_rst_n_i),
        .gray_code_i(wr_ptr_gray_coded)
        .binary_o(wr_ptr_rd_dom),
    );

    assign rd_data = mem[rd_ptr];

    // outputs
    assign full_o = full;
    assign empty_o = empty;
    assign rd_data_o = rd_data;

endmodule // async_fifo