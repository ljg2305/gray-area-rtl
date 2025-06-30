import gray_area_package::*;

module hamming_encode #(
    DATA_WIDTH = 32
) (
  input  logic                    clk_i,
  input  logic                    rst_n_i,
  input  logic [DATA_WIDTH-1:0]   data_in_i,
  input  logic                    valid_in_i,
  output logic [CODED_WIDTH-1:0]  data_out_o,
  output logic [CODE_BITS-1:0]    parity_bits_o,
  output logic                    valid_out_o
);

`include "hamming_defines.svh"

logic [CODED_WIDTH-1:0][ADDR_WIDTH-1:0] parity_input;
logic [CODED_WIDTH-1:0][ADDR_WIDTH-1:0] parity_index;

logic [CODED_WIDTH-1:0] packed_input;
logic [CODED_WIDTH-1:0] extended_coded_output;

logic [ADDR_WIDTH-1:0] base_parity_bits;
logic                  extended_parity_bit;
logic                  valid;
logic [DATA_WIDTH-1:0] data_in_reg;

// Flop and hold input
always @(posedge clk_i ) begin
    if (!rst_n_i) begin
      valid <= 0;
      data_in_reg <= '0;
    end else begin
      valid <= valid_in_i;
      if (valid_in_i) begin
        data_in_reg <= data_in_i;
      end
    end
end


hamming_pad #(.DATA_WIDTH(DATA_WIDTH)) hamming_pad_inst (
  .data_in_i(data_in_reg),
  .pad_bits_i('0),
  .data_out_o(packed_input)
);

hamming_parity #(.DATA_WIDTH(DATA_WIDTH)) hamming_parity_inst (
  .clk_i(clk_i),
  .rst_n_i(rst_n_i),
  .data_in_i(packed_input),
  .parity_bits_o(base_parity_bits),
  .extended_parity_o(),
  .coded_output_o(extended_coded_output),
  .extended_coded_parity_o(extended_parity_bit)
);


assign data_out_o = extended_coded_output;
assign valid_out_o = valid;
assign parity_bits_o = {base_parity_bits,extended_parity_bit};

endmodule