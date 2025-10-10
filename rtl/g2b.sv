module g2b #(
    int WIDTH=4,
    int CDC_DEPTH=2
) (
    input logic clk_i,
    input logic rst_n_i,
    input logic [WIDTH-1:0] gray_code_i,
    output logic [WIDTH-1:0] binary_o
);

logic [WIDTH-1:0] gray_code;
logic [CDC_DEPTH-1:0] [WIDTH-1:0] cdc_stage;

generate
    if (CDC_DEPTH==0) begin
        assign gray_code = gray_code_i;
    end else begin

        always_ff @( posedge clk_i or negedge rst_n_i) begin
            if (!rst_n_i) begin
                cdc_stage <= '0;
            end else begin
                for (int i = 0; i < CDC_DEPTH; i = i + 1) begin
                    if (i==0) begin
                        cdc_stage[i] <= gray_code_i;
                    end else begin
                        cdc_stage[i] <= cdc_stage[i-1];
                    end
                end
            end
        end
        assign gray_code = cdc_stage[CDC_DEPTH-1];
    end
endgenerate


always_comb begin
    binary_o[WIDTH-1] = gray_code[WIDTH-1];
    for (int j= 0; j< WIDTH-1; j= j+1 ) begin
        binary_o[WIDTH-2-j] = binary_o[WIDTH-1-j] ^ gray_code[WIDTH-2-j];
    end
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,g2b);
end
endmodule