module GarbageSortTop # (
    parameter CONV1_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1.hex",
    parameter CONV2_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2.hex"
) (
    input clk,
    input rst,
    input [23:0] d_in,
    input conv_start,
    output reg [127:0] pool_out
);

    // 第1层卷积使能信号
    wire image_input_ready;
    // 第1层卷积8层卷积输出
    wire [63:0] layer_1_conv_tmp;
    // 第1层卷积输出有效信号
    wire conv_1_ready;
    // 第1层卷积计算完成信号
    wire conv_1_complete;
    // 第2层卷积开始信号
    wire layer_1_input_ready;
    // 第2层卷积写地址
    wire [6:0] conv_2_ram_write_addr;
    // 第2层卷积输出
    wire [7:0] layer_2_conv_tmp [15:0];
    // 第2层卷积输出有效信号
    wire conv_2_ready;
    // 第2层卷积计算完成信号
    wire conv_2_complete;
    // 第2层卷积ram输出
    wire [7:0] layer_2_conv [15:0];
    // 第2层卷积ram写完成信号
    wire conv_2_write_complete;
    // 第3层池化读使能信号
    wire layer_3_read_en;
    // 第3层池化读地址
    wire [6:0] layer_3_read_addr;
    // 第3层池化开始信号
    wire layer_3_relu_begin;
    // 第3层池化输出
    wire [7:0] layer_3_max_tmp [15:0];
    // 第3层池化输出有效信号
    wire relu_3_ready;
    // 第3层池化完成信号
    wire relu_3_complete;

    // 用于确定第1层卷积什么时候开始
    ImageInput ImageInput(.clk(clk), .rst(rst), .conv_start(conv_start), .image_input_ready(image_input_ready));

    // 第1层卷积
    genvar j;
    generate
        for(j = 0; j < 8; j = j + 1)
        begin: g0
            // 减少信号线
            if(j == 0) begin
                Conv1 #(CONV1_HEX_FILE_PATH) Conv1(.clk(clk), .rst(rst), .d_in(d_in), .conv_start(conv_start), .image_input_ready(image_input_ready),
                    .d_out(layer_1_conv_tmp[8 * (j + 1) - 1:8 * j]), .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete));
            end
            else begin
                Conv1 #(CONV1_HEX_FILE_PATH) Conv1(.clk(clk), .rst(rst), .d_in(d_in), .conv_start(conv_start), .image_input_ready(image_input_ready),
                    .d_out(layer_1_conv_tmp[8 * (j + 1) - 1:8 * j]));
            end
        end
    endgenerate

    // 用于确定第2层卷积什么时候开始
    Layer1Input Layer1Input(.clk(clk), .rst(rst), .conv_start(conv_start), .conv_1_ready(conv_1_ready),
        .layer_1_input_ready(layer_1_input_ready));

    // 第2层卷积
    genvar i;
    generate
        for(i = 0; i < 16; i = i + 1)
        begin: g1
            // 减少信号线
            if(i == 0) begin
                // 第2层卷积
                Conv2 #(CONV2_HEX_FILE_PATH) Conv2(.clk(clk), .rst(rst), .d_in(layer_1_conv_tmp), .conv_start(conv_start), .layer_1_input_ready(layer_1_input_ready),
                    .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete), .d_out(layer_2_conv_tmp[i]),
                    .ram_write_addr(conv_2_ram_write_addr), .conv_2_ready(conv_2_ready), .conv_2_complete(conv_2_complete));
                // 第2层卷积缓存
                Layer2Input Layer2Input(.clk(clk), .rst(rst), .d_in(layer_2_conv_tmp[i]), .conv_start(conv_start), .wr_en(conv_2_ready),
                    .rd_en(layer_3_read_en), .wr_addr(conv_2_ram_write_addr), .rd_addr(layer_3_read_addr), .d_out(layer_2_conv[i]),
                    .conv_2_write_complete(conv_2_write_complete), .layer_3_relu_begin(layer_3_relu_begin));
                // 第3层池化
                Relu3 Relu3(.clk(clk), .rst(rst), .layer_3_relu_begin(layer_3_relu_begin), .d_in(layer_2_conv[i]), .conv_2_ready(conv_2_ready),
                    .conv_2_write_complete(conv_2_write_complete), .d_out(layer_3_max_tmp[i]), .rd_en(layer_3_read_en),
                    .layer_3_read_addr(layer_3_read_addr), .relu_3_ready(relu_3_ready), .relu_3_complete(relu_3_complete));
            end
            else begin
                Conv2 #(CONV2_HEX_FILE_PATH) Conv2(.clk(clk), .rst(rst), .d_in(layer_1_conv_tmp), .conv_start(conv_start), .layer_1_input_ready(layer_1_input_ready),
                    .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete), .d_out(layer_2_conv_tmp[i]));
                Layer2Input Layer2Input(.clk(clk), .rst(rst), .d_in(layer_2_conv_tmp[i]), .conv_start(conv_start), .wr_en(conv_2_ready),
                    .rd_en(layer_3_read_en), .wr_addr(conv_2_ram_write_addr), .rd_addr(layer_3_read_addr),
                    .d_out(layer_2_conv[i]));
                Relu3 Relu3(.clk(clk), .rst(rst), .layer_3_relu_begin(layer_3_relu_begin), .d_in(layer_2_conv[i]), .conv_2_ready(conv_2_ready),
                    .conv_2_write_complete(conv_2_write_complete), .d_out(layer_3_max_tmp[i]));
            end
        end
    endgenerate

    always @(posedge clk) begin
        if(!rst) begin
            pool_out <= 128'd0;
        end
        else begin
            if(relu_3_ready) begin
                pool_out <= {layer_3_max_tmp[15], layer_3_max_tmp[14], layer_3_max_tmp[13], layer_3_max_tmp[12],
                            layer_3_max_tmp[11], layer_3_max_tmp[10], layer_3_max_tmp[9], layer_3_max_tmp[8],
                            layer_3_max_tmp[7], layer_3_max_tmp[6], layer_3_max_tmp[5], layer_3_max_tmp[4], 
                            layer_3_max_tmp[3], layer_3_max_tmp[2], layer_3_max_tmp[1], layer_3_max_tmp[0]};
            end
            else begin
                pool_out <= 128'd0;
            end
        end
    end

endmodule