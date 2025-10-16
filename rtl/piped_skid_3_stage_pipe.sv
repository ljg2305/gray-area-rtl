module piped_skid_3_stage_pipe #(int DATA_WIDTH = 8) (
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

parameter pipeline_len = 3;

logic [pipeline_len-1:0] [DATA_WIDTH-1:0] data_out;
logic [pipeline_len-1:0] valid_out;
logic [pipeline_len-1:0] ready_in;

logic [pipeline_len-1:0] [DATA_WIDTH-1:0] data_in;
logic [pipeline_len-1:0] valid_in;
logic [pipeline_len-1:0] ready_out;

logic [pipeline_len-1:0] [DATA_WIDTH-1:0] skid_data_in;
logic [pipeline_len-1:0] skid_valid_in;
logic [pipeline_len-1:0] skid_ready_out;

logic [pipeline_len-1:0] [DATA_WIDTH-1:0] skid_data_out;
logic [pipeline_len-1:0] skid_valid_out;
logic [pipeline_len-1:0] skid_ready_in;

genvar i;
generate
    for (i = 0; i < pipeline_len; i = i+1) begin
        if (i==0) begin
            assign skid_data_in[i] = data_i;
            assign skid_valid_in[i] = valid_i;
            assign ready_o = skid_ready_out[0];
        end else begin 
            assign skid_data_in[i] = data_out[i-1];
            assign skid_valid_in[i] = valid_out[i-1];
            assign ready_in[i-1] = skid_ready_out[i];
        end

        if (i == pipeline_len-1) begin
            assign ready_in[i]=ready_i;
            assign data_o = data_out[i];
            assign valid_o = valid_out[i];
        end 


        assign data_in[i] = skid_data_out[i];
        assign valid_in[i] = skid_valid_out[i];
        assign skid_ready_in[i] = ready_out[i];
    
        pipeline_skid_buffer #(.DATA_WIDTH(DATA_WIDTH)) skid_buffer_inst (
            .clk_i(clk_i),
            .rst_n_i(rst_n_i),
            .data_i(skid_data_in[i]),
            .valid_i(skid_valid_in[i]),
            .ready_o(skid_ready_out[i]),
            .data_o(skid_data_out[i]),
            .valid_o(skid_valid_out[i]),
            .ready_i(skid_ready_in[i])
        );

        pipeline_buffer #(.DATA_WIDTH(DATA_WIDTH)) pipeline_buffer_inst (
            .clk_i(clk_i),
            .rst_n_i(rst_n_i),
            .data_i(data_in[i]),
            .valid_i(valid_in[i]),
            .ready_o(ready_out[i]),
            .data_o(data_out[i]),
            .valid_o(valid_out[i]),
            .ready_i(ready_in[i])
        );

    end

endgenerate

endmodule 