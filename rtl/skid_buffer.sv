module skid_buffer #(int DATA_WIDTH = 8) (
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

logic bypass_reg; 
logic [DATA_WIDTH-1:0] skid_reg;

always_ff @( posedge clk_i or negedge rst_n_i ) begin 
    if (!rst_n_i) begin 
        bypass_reg <= 1'b1;
        skid_reg <= '0;
    end else begin
        if (bypass_reg) begin 
            if (!ready_i&&valid_i) begin 
                bypass_reg <= 1'b0; 
                skid_reg <= data_i;
            end 
        end

        if (ready_i) begin 
            bypass_reg <= 1'b1; 
        end 

    end 
end

assign ready_o = bypass_reg; 
assign valid_o = bypass_reg ? valid_i : 1'b1;
assign data_o  = bypass_reg ? data_i : skid_reg; 


endmodule 