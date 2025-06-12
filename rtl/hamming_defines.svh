parameter ADDR_WIDTH = hamming_address_width(DATA_WIDTH);
parameter CODE_BITS = ADDR_WIDTH  + 1;
parameter CODED_WIDTH = DATA_WIDTH + CODE_BITS;
parameter PADDED_CODE_WIDTH = 2 ** (ADDR_WIDTH);
parameter PADDED_INPUT_WIDTH = PADDED_CODE_WIDTH - CODE_BITS;