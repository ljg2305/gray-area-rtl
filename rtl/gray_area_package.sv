package gray_area_package;

function int hamming_address_width (int data_width);
    // This function calculates the total number address bits required for the hamming encoded data.
    // ie if you have 27 bits of data you require 7 repair bits which takes you over the 32 bit threshold
    // from 5 to 6 address bits.
    // This assumes the exteded hamming code with the additional bit for total parity. 
    int addr;
    int parity;
    int max;
    int min;
    addr =  $clog2(data_width);
    parity = addr + 1;
    max = 2 ** addr;
    min = max - parity;
    if (data_width > min) begin
      return addr + 1;
    end else begin
      return addr;
    end
endfunction


endpackage