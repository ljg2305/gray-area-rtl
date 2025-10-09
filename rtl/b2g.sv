module g2b #(int WIDTH=4) (
    input logic [WIDTH-1:0] binary_i,
    output logic [WIDTH-1:0] gray_code_o
);

assign gray_code_i = binary_i ^ (binary_i >> 1); 

endmodule 