module div3_5(
    input logic clk_i, 
    input logic rst_n_i, 
    output logic clk_o
); 

// this is witten in a (speed of coding) inefficient way for the sake of testing hand derrived logic.
logic [6:0] shift_reg; 
logic del_3, del_4;


always_ff @(posedge clk_i or negedge rst_n_i) begin 
    if (!rst_n_i) begin
        shift_reg <= 7'b0000001;
    end else begin 
        shift_reg <= shift_reg << 1;
        shift_reg[0] <= shift_reg[6];
    end 
end

always_ff @(negedge clk_i or negedge rst_n_i) begin 
    if (!rst_n_i) begin
        del_3 <= '0;
        del_4 <= '0; 
    end else begin 
        del_3 <= shift_reg[3];
        del_4 <= shift_reg[4];
    end 
end

assign clk_o = shift_reg[0] | shift_reg[1] | del_3 | del_4;

endmodule