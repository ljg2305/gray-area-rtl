
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

    // Define states using enum
    typedef enum logic [1:0] {
        WAIT    = 2'b00,
        PARSE   = 2'b01,
        CORRUPT = 2'b10
    } state_t;

    assign serial_out_o = corrupt ?  ~serial_in_i : serial_in_i;
    assign start_o      = start_i;
    assign enable_o     = enable_i;

    // registers used for state machines can look for multiple bytes at the same time
    // state machines flag to corrupt/flip bits of a packet.

    logic [3:0]    nibble_check_reg, nibble_check_next;
    logic [1:0]    num_errors_reg, num_errors_next;
    logic          enable_reg, enable_next;
    logic          corrupt;

    logic [$clog2($bits(nibble_check_reg))-1:0] bit_counter, next_bit_counter, nibble_index; 
    logic [$bits(num_errors_reg)-1:0]           error_counter, next_error_counter; 

    assign nibble_check_next = nibble_check_reg;
    assign num_errors_next   = num_errors_reg;
    assign enable_next       = enable_reg;
    //TODO make writable by wishbone interface
    always_ff @( clk_i ) begin : byte_parser
        if (!rst_n_i) begin
            nibble_check_reg <= 4'h7;
            num_errors_reg   <= 2'b01;
            enable_reg       <= 1'b1;
        end else begin
            nibble_check_reg <= nibble_check_next;
            num_errors_reg   <= num_errors_next;
            enable_reg       <= enable_next;
        end
    end


    state_t state, next_state;

    always_ff @(posedge clk_i ) begin
        if (!rst_n_i) begin 
            state <= WAIT;
            bit_counter <= '0;
            error_counter <= '0;
        end else begin 
            state <= next_state;
            bit_counter <= next_bit_counter; 
            error_counter <= next_error_counter; 
        end
    end
    
    //inverting as we send MSB first from sender 
    assign nibble_index = 2**$bits(nibble_check_reg) - 1 -bit_counter;
    // assign bit_counter;

    always_comb begin
        // defaults 
        next_state = state; 
        next_bit_counter = bit_counter;
        
        unique case (state)
            WAIT: begin
                if (start_i && serial_in_i == nibble_check_reg[nibble_index]) begin 
                    next_state = PARSE;
                    next_bit_counter = bit_counter + 1;
                end 
            end

            PARSE: begin
                if ( serial_in_i == nibble_check_reg[nibble_index]) begin 
                    next_bit_counter = bit_counter + 1;
                    if ( nibble_index == 0 ) begin 
                        if (num_errors_reg == 0) begin 
                            next_state = WAIT;
                        end else begin 
                            next_state = CORRUPT;
                            next_bit_counter = 0;
                            next_error_counter = error_counter + 1; 
                        end 
                    end
                end else begin 
                    next_state = WAIT;
                    next_bit_counter = 0;
                end 
            end

            CORRUPT: begin
                if (error_counter >= num_errors_reg ) begin 
                    next_state = WAIT;
                    next_error_counter = '0;
                end 
                next_error_counter = error_counter + 1; 
            end

            default: next_state = WAIT;
        endcase
    end

    assign corrupt = state == CORRUPT ? 1'b1 : 1'b0;
    
`ifndef synthesis

//initial begin
//    $dumpfile("dump.vcd");
//    $dumpvars(1,sniffer);
//end

`endif  // synthesis

endmodule
