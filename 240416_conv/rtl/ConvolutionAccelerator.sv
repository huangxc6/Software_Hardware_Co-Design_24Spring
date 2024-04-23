module ConvolutionAccelerator (
    input             valid                     ,
    input      [7:0]  col_data [0:9*26*26-1]    , 
    input      [7:0]  kernel   [0:3*3-1]        ,
    input      [7:0]  bias                      , 
    output     [15:0] conv_result [0:26*26-1]   , 
    input             clk                       ,
    input             reset                     ,
    output reg        conv_done
);
    logic [1:0]  cnt ;

    // combine the results 
    logic [15:0] conv_result_1 [0:13*13-1];
    logic [15:0] conv_result_2 [0:13*13-1];
    logic [15:0] conv_result_3 [0:13*13-1];
    logic [15:0] conv_result_4 [0:13*13-1];
    assign conv_result[0        :  13*13-1] = conv_result_1;
    assign conv_result[13*13    :2*13*13-1] = conv_result_2;
    assign conv_result[2*13*13  :3*13*13-1] = conv_result_3;
    assign conv_result[3*13*13  :4*13*13-1] = conv_result_4;   

    // split the input data
    logic [7:0] col_data_1 [0:9*13*13-1];
    logic [7:0] col_data_2 [0:9*13*13-1];
    logic [7:0] col_data_3 [0:9*13*13-1];
    logic [7:0] col_data_4 [0:9*13*13-1];
    assign col_data_1 = col_data[0          :  9*13*13-1];
    assign col_data_2 = col_data[9*13*13    :2*9*13*13-1];
    assign col_data_3 = col_data[2*9*13*13  :3*9*13*13-1];    
    assign col_data_4 = col_data[3*9*13*13  :4*9*13*13-1];

    // data for PE in each clock cycle
    logic [7:0] col_data_tmp [0:9*13*13-1];
    always_comb begin
        case (cnt)
            2'b00: col_data_tmp = col_data_1;
            2'b01: col_data_tmp = col_data_2;
            2'b10: col_data_tmp = col_data_3;
            2'b11: col_data_tmp = col_data_4;
            default: ;
        endcase
        
    end

    integer i;
    // results from PE in each clock cycle 
    logic [15:0] conv_result_tmp [0:13*13-1];
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 13 * 13 ; i = i + 1 ) begin
                    conv_result_1[i]   <= 0;
                    conv_result_2[i]   <= 0;
                    conv_result_3[i]   <= 0;
                    conv_result_4[i]   <= 0;
            end
        end else begin
            case (cnt)
                2'b00: conv_result_1 <= conv_result_tmp;
                2'b01: conv_result_2 <= conv_result_tmp;
                2'b10: conv_result_3 <= conv_result_tmp;
                2'b11: conv_result_4 <= conv_result_tmp; 
                default: ;
            endcase
        end
    end

    PE pe (
        .col_data(col_data_tmp),
        .kernel(kernel),
        .bias(bias),
        .conv_result(conv_result_tmp)
        // .clk(clk),
        // .reset(reset)
    );

    always @(posedge clk) begin
        if (reset) begin
            cnt <= 2'b0;
        end
        else begin
            if (valid == 1'b1) begin
                cnt <= cnt + 1'b1;    
            end else begin
                cnt <= 2'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            conv_done <= 1'b0;
        end
        else begin
            if (cnt == 2'b11) begin
                conv_done <= 1'b1;
            end;
        end
    end

endmodule

// complete the convolution in 4 clock cycles
// 26*26*9 = 6084 
// 26*26 = 13 * 13 * 4 = 676
module PE (
    input [7:0] col_data [0:9*13*13-1], 
    input [7:0] kernel [0:3*3-1],
    input [7:0] bias, 
    output [15:0] conv_result [0:13*13-1]
    // input clk,
    // input reset
);
    integer k;
    genvar i, j;

    logic [15:0] conv_sum [0:9*13*13-1];

    generate
        for (i = 0; i < 13*13; i = i + 1) begin
            for (j = 0; j < 3*3; j = j + 1) begin
                assign conv_sum[i*9 + j] = col_data[i*9 + j] * kernel[j];
            end
            assign conv_result[i] = conv_sum[0] + conv_sum[1] + conv_sum[2] + conv_sum[3] + conv_sum[4] 
                                        + conv_sum[5] + conv_sum[6] + conv_sum[7] + conv_sum[8] + bias;
            end
    endgenerate
    
endmodule
