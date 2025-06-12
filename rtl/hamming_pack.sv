import gray_area_package::*;

module hamming_pack #(
   DATA_WIDTH = 32
) (
    input  logic [DATA_WIDTH-1:0]   data_in_i,
    output logic [CODED_WIDTH-1:0] data_out_o
);

    `include "hamming_defines.svh"


    logic [PADDED_INPUT_WIDTH-1:0] data_in_padded;
    logic [PADDED_CODE_WIDTH-1:0] packed_input;

    assign data_in_padded = {{(PADDED_INPUT_WIDTH-DATA_WIDTH){1'b0}},data_in_i};


    assign packed_input[0] = 1'b0;
    genvar i;
    generate
    for (i = 0; i < ADDR_WIDTH; i++) begin
        localparam int current_pow = 2 ** i;
        localparam int next_pow = 2 ** (i + 1);
        localparam int width = next_pow - current_pow - 1;
        localparam int data_offset   = current_pow - (i+1);
        localparam int packed_offset = current_pow + 1;

        // insert placeholder 0 for parity bits
        assign packed_input[current_pow] = 1'b0;

        if (width  > 0)
            assign packed_input[packed_offset +: width] = data_in_padded[data_offset +: width];
    end
    endgenerate

    assign data_out_o = packed_input[CODED_WIDTH-1:0];

endmodule