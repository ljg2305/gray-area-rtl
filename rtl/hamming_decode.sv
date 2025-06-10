import gray_area_package::*;

module hamming_decode #(
    DATA_WIDTH = 32
) (
  input  logic clk,
  input  logic rst_n,
  input  logic [CODED_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic [ADDR_WIDTH-1:0] location,
  output logic [1:0]            num_errors
); 

//TODO move common calcs to include file
parameter ADDR_WIDTH = hamming_address_width(DATA_WIDTH);
parameter CODE_BITS = ADDR_WIDTH  + 1;
parameter CODED_WIDTH = DATA_WIDTH + CODE_BITS;
parameter PADDED_CODE_WIDTH = 2 ** (ADDR_WIDTH);

logic [CODED_WIDTH-1:0][ADDR_WIDTH-1:0] parity_input; 
logic [CODED_WIDTH-1:0][ADDR_WIDTH-1:0] parity_index; 
logic [CODED_WIDTH-1:0] fixed_data_in; 
logic [ADDR_WIDTH-1:0] parity_bits;

logic [DATA_WIDTH-1:0] unpacked_input;

logic exteded_parity;

// TODO put in to module to be reused by decoder
// hamming_parity
always_comb begin

  for (int i = 0; i < CODED_WIDTH; i++) begin
      parity_index[i] = i[ADDR_WIDTH-1:0];       
      parity_input[i] = {ADDR_WIDTH{data_in[i]}} & parity_index[i];
  end

  parity_bits = {ADDR_WIDTH{1'b0}};
  for (int i = 0; i < CODED_WIDTH; i++) begin
    parity_bits ^= parity_input[i];  // bitwise XOR across each value
  end
end

assign exteded_parity = ^data_in[CODED_WIDTH-1:1];
always_comb begin
    case ({|parity_bits, exteded_parity})
        2'b00: num_errors = 2'b00; // No errors
        2'b01: num_errors = 2'b10; // 2 errors
        2'b10: num_errors = 2'b01; // 1 error
        2'b11: num_errors = 2'b10; // 2 errors
    endcase
end

assign location   = parity_bits;
always_comb begin
    fixed_data_in = data_in;
    if (num_errors == 1) begin 
        fixed_data_in[location] = !data_in[location];
    end 
end

genvar i; 
generate
for (i = 0; i < ADDR_WIDTH; i++) begin
    // TODO: Fix for non power of 2 coded data width 
    localparam int current_pow = 2 ** i;
    localparam int next_pow = 2 ** (i + 1);
    localparam int width = next_pow - current_pow - 1;
    localparam int data_offset   = current_pow - (i+1);
    localparam int packed_offset = current_pow + 1;

    if (width  > 0)
        assign unpacked_input[data_offset +: width] = fixed_data_in[packed_offset+: width];
end
endgenerate

assign data_out = unpacked_input;

endmodule