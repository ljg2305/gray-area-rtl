module pipeline_skid_buffer #(int DATA_WIDTH = 8) (
    input logic clk_i,
    input logic rst_n_i, 

    // RECIVING SIDE
    input logic [DATA_WIDTH-1:0] data_i,
    input valid_i, 
    output ready_o, 

    // SENDING SIDE
    output logic [DATA_WIDTH-1:0] data_o, 
    output valid_o, 
    input ready_i
);

logic valid_pipe_reg; 
logic [DATA_WIDTH-1:0] data_pipe_reg;

logic valid_skid_reg; 
logic [DATA_WIDTH-1:0] data_skid_reg;

enum int unsigned { PIPE, SKID } state;

always_ff @( posedge clk_i or negedge rst_n_i ) begin 
    if (!rst_n_i) begin 
        state <= PIPE;
        valid_pipe_reg <= 1'b0;
        data_pipe_reg  <= '0;
        valid_skid_reg <= 1'b0;
        data_skid_reg  <= '0;
    end else begin
        case (state)
            PIPE: begin
                if (ready_i) begin 
                    data_pipe_reg <= data_i;
                    valid_pipe_reg <= valid_i;
                end else begin 
                    data_skid_reg <= data_i;
                    valid_skid_reg <= valid_i;
                    state <= SKID;
                end
            end
            SKID: begin
                if (ready_i) begin 
                    data_pipe_reg <= data_skid_reg;
                    valid_pipe_reg <= valid_skid_reg;                    
                    state <= PIPE;
                end
            end
            default:    
                state <= PIPE;
        endcase
    end
end 

assign ready_o = state == PIPE ? 1'b1 : 1'b0;
assign data_o  = data_pipe_reg; 
assign valid_o = valid_pipe_reg;

endmodule 