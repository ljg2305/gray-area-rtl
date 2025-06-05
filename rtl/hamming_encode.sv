import gray_area_package::*;

// TODO:
// 1. add flops 
// 2. add split data coding
// 3. add interleaving 
module hamming_encode #(
    DATA_WIDTH = 32
) (
  input  logic clk,
  input  logic rst_n,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [OUTPUT_WIDTH-1:0] data_out 
); 

//TODO move common calcs to include file
parameter ADDR_WIDTH = hamming_address_width(DATA_WIDTH);
parameter CODE_BITS = ADDR_WIDTH  + 1;
parameter OUTPUT_WIDTH = DATA_WIDTH + CODE_BITS;
parameter PADDED_CODE_WIDTH = 2 ** (ADDR_WIDTH);

logic [OUTPUT_WIDTH-1:0][ADDR_WIDTH-1:0] parity_input; 
logic [OUTPUT_WIDTH-1:0][ADDR_WIDTH-1:0] parity_index; 
logic [ADDR_WIDTH-1:0] parity_bits;

logic [OUTPUT_WIDTH-1:0] packed_input; 
logic [OUTPUT_WIDTH-1:0] coded_output; 
logic [OUTPUT_WIDTH-1:0] exteded_coded_output;

hamming_pack #(.DATA_WIDTH(DATA_WIDTH)) hamming_pad_inst (
  .data_in(data_in),
  .data_out(packed_input)
);

// TODO put in to module to be reused by decoder
always_comb begin

  for (int i = 0; i < OUTPUT_WIDTH; i++) begin
      parity_index[i] = i[ADDR_WIDTH-1:0];       
      parity_input[i] = {ADDR_WIDTH{packed_input[i]}} & parity_index[i];
  end

  parity_bits = {ADDR_WIDTH{1'b0}};
  for (int i = 0; i < OUTPUT_WIDTH; i++) begin
    parity_bits ^= parity_input[i];  // bitwise XOR across each value
  end

  coded_output = packed_input;
  for (int i = 0; i < ADDR_WIDTH; i++) begin
    coded_output[2**i] = parity_bits[i]; 
  end

end

assign exteded_coded_output[0] = ^coded_output;
assign exteded_coded_output[OUTPUT_WIDTH-1:1] = coded_output[OUTPUT_WIDTH-1:1];

assign data_out = exteded_coded_output;

endmodule