module pipeline_buffer #(int DATA_WIDTH = 8) (
    input logic clk_i,
    input logic rst_n_i, 

    // RECIVING SIDE
    input logic [DATA_WIDTH-1:0] data_i,
    input valid_i, 
    output ready_o, 

    // SENDING SIDE
    output logic [DATA_WIDTH-1:0] data_o, 
    output valid_o, 
    input ready_i
);

logic [DATA_WIDTH-1:0] data_pipe_reg;
logic valid_pipe_reg; 

always_ff @( posedge clk_i or negedge rst_n_i ) begin 
    if (!rst_n_i) begin 
        valid_pipe_reg <= 1'b0;
        data_pipe_reg  <= '0; 
    end else begin
        if (ready_i) begin 
            valid_pipe_reg <= valid_i;
            data_pipe_reg  <= data_i; 
        end 
    end 
end

assign ready_o = ready_i;
assign data_o = data_pipe_reg;
assign valid_o = valid_pipe_reg;

endmodule 