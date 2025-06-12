import gray_area_package::*;

// TODO:
// 1. add flops 
// 2. add split data coding
// 3. add interleaving 
module hamming_encode #(
    DATA_WIDTH = 32
) (
  input  logic clk_i,
  input  logic rst_n_i,
  input  logic [DATA_WIDTH-1:0] data_in_i,
  output logic [CODED_WIDTH-1:0] data_out_o 
); 

`include "hamming_defines.svh"

logic [CODED_WIDTH-1:0][ADDR_WIDTH-1:0] parity_input; 
logic [CODED_WIDTH-1:0][ADDR_WIDTH-1:0] parity_index; 

logic [CODED_WIDTH-1:0] packed_input; 
logic [CODED_WIDTH-1:0] extended_coded_output;

hamming_pack #(.DATA_WIDTH(DATA_WIDTH)) hamming_pad_inst (
  .data_in_i(data_in_i),
  .data_out_o(packed_input)
);

hamming_parity #(.DATA_WIDTH(DATA_WIDTH)) hamming_parity_inst ( 
  .clk_i(clk_i),
  .rst_n_i(rst_n_i),
  .data_in_i(packed_input),
  .parity_bits_o(),
  .extended_parity_o(),
  .coded_output_o(extended_coded_output),
  .extended_coded_parity_o()
);

assign data_out_o = extended_coded_output;

endmodule