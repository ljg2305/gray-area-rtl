
module sniffer (
        input  logic clk_i,
        input  logic rst_n_i,
        input  logic serial_in_i,
        input  logic start_i,
        input  logic enable_i,
        output logic serial_out_o,
        output logic start_o,
        output logic enable_o
    );

    assign serial_out_o = serial_in_i;
    assign start_o      = start_i;
    assign enable_o     = enable_i;

    // registers used for state machines can look for multiple bytes at the same time
    // state machines flag to corrupt/flip bits of a packet.

    logic [4:0] nibble_check_reg, nibble_check_next;
    logic [1:0] num_errors_reg, num_errors_next;
    logic       enable_reg, enable_next;

    assign nibble_check_next = nibble_check_reg;
    assign num_errors_next   = num_errors_reg;
    assign enable_reg        = enable_next;
    always_ff @( clk_i ) begin : byte_parser
        if (!rst_n_i) begin
            //TODO make writable by wishbone interface
            nibble_check_reg <= 4'h7;
            num_errors_reg   <= 2'b01;
            enable_reg       <= 1'b1;
        end else begin
            nibble_check_reg <= nibble_check_next;
            num_errors_reg   <= num_errors_next;
            enable_reg       <= enable_next;
        end
    end

    //FSM

    always_ff @( clk_i ) begin : byte_parser
        if (!rst_n_i) begin
            //TODO make writable by wishbone interface
            nibble_check_reg <= 4'h7;
            num_errors_reg   <= 2'b01;
            enable_reg       <= 1'b1;
        end else begin
            nibble_check_reg <= nibble_check_next;
            num_errors_reg   <= num_errors_next;
            enable_reg       <= enable_next;
        end
    end



`ifndef synthesis

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,sniffer);
end

`endif  // synthesis

endmodule
