module div7(
    input logic clk_i, 
    input logic rst_n_i, 
    output logic clk_o
); 

// this is witten in a (speed of coding) inefficient way for the sake of testing hand derrived logic.

logic A;
logic B;
logic C,C_del;

always_ff @(posedge clk_i or negedge rst_n_i) begin 
    if (!rst_n_i) begin
        A <= 1'b0;
        B <= 1'b0;
        C <= 1'b0;
    end else begin 
        A <= !(A^(B&C));
        B <= !(!(A^B)^(B&C));
        C <= !(!((A&B)^C)^(B&C));
    end 
end

always_ff @(negedge clk_i or negedge rst_n_i) begin 
    if (!rst_n_i) begin
        C_del <= 1'b0;
    end else begin 
        C_del <= C; 
    end 
end

assign clk_o = C | C_del;

endmodule