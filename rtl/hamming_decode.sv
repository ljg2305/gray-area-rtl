import gray_area_package::*;

module hamming_decode #(
    int DATA_WIDTH = 32
) (
  input  logic                   clk,
  input  logic                   rst_n,
  input  logic [CODED_WIDTH-1:0] data_in_i,
  output logic [CODED_WIDTH-1:0] raw_data_o,
  output logic [DATA_WIDTH-1:0]  data_out_o,
  output logic [ADDR_WIDTH-1:0]  fault_location_o,
  output logic [1:0]             num_errors_o
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

logic extended_parity;

// TODO put in to module to be reused by decoder
// hamming_parity
always_comb begin

  for (int i = 0; i < CODED_WIDTH; i++) begin
      parity_index[i] = i[ADDR_WIDTH-1:0];       
      parity_input[i] = {ADDR_WIDTH{data_in_i[i]}} & parity_index[i];
  end

  parity_bits = {ADDR_WIDTH{1'b0}};
  for (int i = 0; i < CODED_WIDTH; i++) begin
    parity_bits ^= parity_input[i];  // bitwise XOR across each value
  end
end

assign extended_parity = ^data_in_i[CODED_WIDTH-1:1];
always_comb begin
    unique case ({|parity_bits, extended_parity!=data_in_i[0]})
        2'b00: num_errors_o = 2'b00; // No errors
        2'b01: num_errors_o = 2'b10; // 2 errors
        2'b10: num_errors_o = 2'b10; // 2 error
        2'b11: num_errors_o = 2'b01; // 1 errors
    endcase
end

assign fault_location_o   = parity_bits;
always_comb begin
    fixed_data_in = data_in_i;
    if (num_errors_o == 1) begin
        fixed_data_in[fault_location_o] = !data_in_i[fault_location_o];
    end 
end

genvar i; 
generate
for (i = 0; i < ADDR_WIDTH; i++) begin
    localparam int CURRENT_POW = 2 ** i;
    localparam int NEXT_POW = 2 ** (i + 1);
    localparam int WIDTH = NEXT_POW - CURRENT_POW - 1;
    localparam int DATA_OFFSET   = CURRENT_POW - (i+1);
    localparam int PACKED_OFFSET = CURRENT_POW + 1;
    localparam int WIDTH_LIMIT = (DATA_OFFSET + WIDTH < DATA_WIDTH)
                   ? WIDTH
                   : DATA_WIDTH - DATA_OFFSET;

    if (width  > 0)
        assign unpacked_input[DATA_OFFSET +: WIDTH_LIMIT]
               = fixed_data_in[PACKED_OFFSET+: WIDTH_LIMIT];
end
endgenerate

assign data_out_o = unpacked_input;
assign raw_data_o = data_in_i;

endmodule