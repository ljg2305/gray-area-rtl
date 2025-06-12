import gray_area_package::*;

module hamming_parity #(
    int DATA_WIDTH = 39
) (
  input  logic                   clk_i,
  input  logic                   rst_n_i,
  input  logic [CODED_WIDTH-1:0] data_in_i,
  output logic [ADDR_WIDTH-1:0]  parity_bits_o,
  output logic                   extended_parity_o,
  output logic [CODED_WIDTH-1:0] coded_output_o  
  
); 

`include "hamming_defines.svh"

logic [CODED_WIDTH-1:0][ADDR_WIDTH-1:0] parity_input; 
logic [CODED_WIDTH-1:0][ADDR_WIDTH-1:0] parity_index; 
logic [CODED_WIDTH-1:0] fixed_data_in; 
logic [CODED_WIDTH-1:0] coded_output; 

always_comb begin

  for (int i = 0; i < CODED_WIDTH; i++) begin
      parity_index[i] = i[ADDR_WIDTH-1:0];       
      parity_input[i] = {ADDR_WIDTH{data_in_i[i]}} & parity_index[i];
  end

  parity_bits_o = {ADDR_WIDTH{1'b0}};
  for (int i = 0; i < CODED_WIDTH; i++) begin
    parity_bits_o ^= parity_input[i];  // bitwise XOR across each value
  end

  coded_output = data_in_i;
  for (int i = 0; i < ADDR_WIDTH; i++) begin
    coded_output[2**i] = parity_bits_o[i]; 
  end

end

assign extended_parity_o = ^coded_output;

assign coded_output_o[0] = extended_parity_o;
assign coded_output_o[CODED_WIDTH-1:1] = coded_output[CODED_WIDTH-1:1];

endmodule
