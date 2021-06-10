module GarbageSortTop # (
    parameter [535:0] CONV1_HEX_FILE_PATH[7:0] = {"D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_1.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_2.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_3.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_4.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_5.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_6.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_7.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_8.hex"},
    parameter [543:0] CONV2_HEX_FILE_PATH[15:0] = {"D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_01.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_02.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_03.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_04.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_05.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_06.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_07.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_08.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_09.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_10.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_11.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_12.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_13.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_14.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_15.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_16.hex"},
    parameter [543:0] CONV4_HEX_FILE_PATH[31:0] = {"D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_01.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_02.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_03.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_04.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_05.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_06.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_07.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_08.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_09.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_10.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_11.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_12.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_13.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_14.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_15.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_16.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_17.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_18.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_19.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_20.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_21.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_22.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_23.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_24.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_25.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_26.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_27.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_28.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_29.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_30.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_31.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_32.hex"},
    parameter [543:0] CONV5_HEX_FILE_PATH[63:0] = {"D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_01.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_02.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_03.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_04.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_05.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_06.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_07.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_08.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_09.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_10.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_11.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_12.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_13.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_14.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_15.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_16.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_17.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_18.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_19.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_20.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_21.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_22.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_23.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_24.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_25.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_26.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_27.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_28.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_29.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_30.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_31.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_32.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_33.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_34.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_35.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_36.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_37.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_38.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_39.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_40.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_41.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_42.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_43.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_44.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_45.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_46.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_47.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_48.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_49.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_50.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_51.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_52.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_53.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_54.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_55.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_56.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_57.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_58.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_59.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_60.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_61.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_62.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_63.hex",
                                                    "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_64.hex"},
    parameter FULLCONNECT7_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/fullconnect7.hex"
) (
    input clk,
    input rst,
    input [23:0] d_in,
    input conv_start,
    output reg [7:0] net_out
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
    wire [127:0] layer_3_max_tmp;
    // 第3层池化输出有效信号
    wire relu_3_ready;
    // 第3层池化完成信号
    wire relu_3_complete;
    // 第4层卷积开始信号
    wire layer_3_input_ready;
    // 第4层卷积输出
    wire [255:0] layer_4_conv_tmp;
    // 第4层卷积输出有效信号
    wire conv_4_ready;
    // 第4层卷积计算完成信号
    wire conv_4_complete;
    // 第5层卷积开始信号
    wire layer_4_input_ready;
    // 第5层卷积输出
    wire [7:0] layer_5_conv_tmp [63:0];
    // 第5层卷积写地址
    wire [6:0] conv_5_ram_write_addr;
    // 第5层卷积输出有效信号
    wire conv_5_ready;
    // 第5层卷积计算完成信号
    wire conv_5_complete;
    // 第5层卷积ram输出
    wire [7:0] layer_5_conv [63:0];
    // 第5层卷积ram写完成信号
    wire conv_5_write_complete;
    // 第6层池化读使能信号
    wire layer_6_read_en;
    // 第6层池化读地址
    wire [6:0] layer_6_read_addr;
    // 第6层池化开始信号
    wire layer_6_relu_begin;
    // 第6层池化输出
    wire [511:0] layer_6_max_tmp;
    // 第6层池化输出有效信号
    wire relu_6_ready;
    // 第6层池化完成信号
    wire relu_6_complete;
    // 第6层写ram地址
    wire [6:0] relu_6_ram_write_addr;
    // 第6层池化ram输出
    wire [511:0] layer_6_max;
    // 第6层池化ram写完成信号
    wire relu_6_write_complete;
    // 第7层读使能信号
    wire layer_7_read_en;
    // 第7层读地址
    wire [6:0] layer_7_read_addr;
    // 第7层输出
    wire [7:0] layer_7_out;
    // 第7层输出有效信号
    wire full_connect_7_ready;
    // 第7层输出完成信号
    wire full_connect_7_complete;
    

    // 用于确定第1层卷积什么时候开始
    ImageInput ImageInput(.clk(clk), .rst(rst), .conv_start(conv_start), .image_input_ready(image_input_ready));

    // 第1层卷积
    genvar j;
    generate
        for(j = 0; j < 8; j = j + 1)
        begin: g0
            // 减少信号线
            if(j == 0) begin
                Conv1 #(CONV1_HEX_FILE_PATH[j]) Conv1(.clk(clk), .rst(rst), .d_in(d_in), .conv_start(conv_start), .image_input_ready(image_input_ready),
                    .d_out(layer_1_conv_tmp[8 * (j + 1) - 1:8 * j]), .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete));
            end
            else begin
                Conv1 #(CONV1_HEX_FILE_PATH[j]) Conv1(.clk(clk), .rst(rst), .d_in(d_in), .conv_start(conv_start), .image_input_ready(image_input_ready),
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
                Conv2 #(CONV2_HEX_FILE_PATH[i]) Conv2(.clk(clk), .rst(rst), .d_in(layer_1_conv_tmp), .conv_start(conv_start), .layer_1_input_ready(layer_1_input_ready),
                    .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete), .d_out(layer_2_conv_tmp[i]),
                    .ram_write_addr(conv_2_ram_write_addr), .conv_2_ready(conv_2_ready), .conv_2_complete(conv_2_complete));
                // 第2层卷积缓存
                Layer2Input Layer2Input(.clk(clk), .rst(rst), .d_in(layer_2_conv_tmp[i]), .conv_start(conv_start), .wr_en(conv_2_ready),
                    .rd_en(layer_3_read_en), .wr_addr(conv_2_ram_write_addr), .rd_addr(layer_3_read_addr), .d_out(layer_2_conv[i]),
                    .conv_2_write_complete(conv_2_write_complete), .layer_3_relu_begin(layer_3_relu_begin));
                // 第3层池化
                Relu3 Relu3(.clk(clk), .rst(rst), .layer_3_relu_begin(layer_3_relu_begin), .d_in(layer_2_conv[i]), .conv_2_ready(conv_2_ready),
                    .conv_2_write_complete(conv_2_write_complete), .d_out(layer_3_max_tmp[8 * (i + 1) - 1:8 * i]), .rd_en(layer_3_read_en),
                    .layer_3_read_addr(layer_3_read_addr), .relu_3_ready(relu_3_ready), .relu_3_complete(relu_3_complete));
            end
            else begin
                Conv2 #(CONV2_HEX_FILE_PATH[i]) Conv2(.clk(clk), .rst(rst), .d_in(layer_1_conv_tmp), .conv_start(conv_start), .layer_1_input_ready(layer_1_input_ready),
                    .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete), .d_out(layer_2_conv_tmp[i]));
                Layer2Input Layer2Input(.clk(clk), .rst(rst), .d_in(layer_2_conv_tmp[i]), .conv_start(conv_start), .wr_en(conv_2_ready),
                    .rd_en(layer_3_read_en), .wr_addr(conv_2_ram_write_addr), .rd_addr(layer_3_read_addr),
                    .d_out(layer_2_conv[i]));
                Relu3 Relu3(.clk(clk), .rst(rst), .layer_3_relu_begin(layer_3_relu_begin), .d_in(layer_2_conv[i]), .conv_2_ready(conv_2_ready),
                    .conv_2_write_complete(conv_2_write_complete), .d_out(layer_3_max_tmp[8 * (i + 1) - 1:8 * i]));
            end
        end
    endgenerate

    // 用于确定第4层卷积什么时候开始
    Layer3Input Layer3Input(.clk(clk), .rst(rst), .conv_start(conv_start), .relu_3_ready(relu_3_ready),
        .layer_3_input_ready(layer_3_input_ready));

    // 第4层卷积
    genvar k;
    generate
        for(k = 0; k < 32; k = k + 1)
        begin: g2
            // 减少信号线
            if(k == 0) begin
                // 第4层卷积
                Conv4 #(CONV4_HEX_FILE_PATH[k]) Conv4(.clk(clk), .rst(rst), .d_in(layer_3_max_tmp), .conv_start(conv_start), .layer_3_input_ready(layer_3_input_ready),
                    .relu_3_ready(relu_3_ready), .relu_3_complete(relu_3_complete), .d_out(layer_4_conv_tmp[8 * (k + 1) - 1:8 * k]),
                    .conv_4_ready(conv_4_ready), .conv_4_complete(conv_4_complete));
            end
            else begin
                Conv4 #(CONV4_HEX_FILE_PATH[k]) Conv4(.clk(clk), .rst(rst), .d_in(layer_3_max_tmp), .conv_start(conv_start), .layer_3_input_ready(layer_3_input_ready),
                    .relu_3_ready(relu_3_ready), .relu_3_complete(relu_3_complete), .d_out(layer_4_conv_tmp[8 * (k + 1) - 1:8 * k]));
            end
        end
    endgenerate

    // 用于确定第5层卷积什么时候开始
    Layer4Input Layer4Input(.clk(clk), .rst(rst), .conv_start(conv_start), .conv_4_ready(conv_4_ready),
        .layer_4_input_ready(layer_4_input_ready));

    // 第5层卷积
    genvar m;
    generate
        for(m = 0; m < 64; m = m + 1)
        begin: g3
            // 减少信号线
            if(m == 0) begin
                // 第5层卷积
                Conv5 #(CONV5_HEX_FILE_PATH[m]) Conv5(.clk(clk), .rst(rst), .d_in(layer_4_conv_tmp), .conv_start(conv_start), .layer_4_input_ready(layer_4_input_ready),
                    .conv_4_ready(conv_4_ready), .conv_4_complete(conv_4_complete), .d_out(layer_5_conv_tmp[m]),
                    .ram_write_addr(conv_5_ram_write_addr), .conv_5_ready(conv_5_ready), .conv_5_complete(conv_5_complete));
                // 第5层卷积缓存
                Layer5Input Layer5Input(.clk(clk), .rst(rst), .d_in(layer_5_conv_tmp[m]), .conv_start(conv_start), .wr_en(conv_5_ready),
                    .rd_en(layer_6_read_en), .wr_addr(conv_5_ram_write_addr), .rd_addr(layer_6_read_addr), .d_out(layer_5_conv[m]),
                    .conv_5_write_complete(conv_5_write_complete), .layer_6_relu_begin(layer_6_relu_begin));
                // 第6层池化
                Relu6 Relu6(.clk(clk), .rst(rst), .layer_6_relu_begin(layer_6_relu_begin), .d_in(layer_5_conv[m]), .conv_5_ready(conv_5_ready),
                    .conv_5_write_complete(conv_5_write_complete), .d_out(layer_6_max_tmp[8 * (m + 1) - 1:8 * m]), .rd_en(layer_6_read_en),
                    .layer_6_read_addr(layer_6_read_addr), .ram_write_addr(relu_6_ram_write_addr), .relu_6_ready(relu_6_ready), .relu_6_complete(relu_6_complete));
            end
            else begin
                Conv5 #(CONV5_HEX_FILE_PATH[m]) Conv5(.clk(clk), .rst(rst), .d_in(layer_4_conv_tmp), .conv_start(conv_start), .layer_4_input_ready(layer_4_input_ready),
                    .conv_4_ready(conv_4_ready), .conv_4_complete(conv_4_complete), .d_out(layer_5_conv_tmp[m]));
                Layer5Input Layer5Input(.clk(clk), .rst(rst), .d_in(layer_5_conv_tmp[m]), .conv_start(conv_start), .wr_en(conv_5_ready),
                    .rd_en(layer_6_read_en), .wr_addr(conv_5_ram_write_addr), .rd_addr(layer_6_read_addr),
                    .d_out(layer_5_conv[m]));
                Relu6 Relu6(.clk(clk), .rst(rst), .layer_6_relu_begin(layer_6_relu_begin), .d_in(layer_5_conv[m]), .conv_5_ready(conv_5_ready),
                    .conv_5_write_complete(conv_5_write_complete), .d_out(layer_6_max_tmp[8 * (m + 1) - 1:8 * m]));
            end
        end
    endgenerate

    // 第6层池化缓存
    Layer6Input Layer6Input(.clk(clk), .rst(rst), .d_in(layer_6_max_tmp), .conv_start(conv_start), .wr_en(relu_6_ready),
            .rd_en(layer_7_read_en), .wr_addr(relu_6_ram_write_addr), .rd_addr(layer_7_read_addr), .d_out(layer_6_max),
            .relu_6_write_complete(relu_6_write_complete));
    
    // 第7层全连接
    FullConnect7 #(FULLCONNECT7_HEX_FILE_PATH) FullConnect7(.clk(clk), .rst(rst), .d_in(layer_6_max), .conv_start(conv_start), .relu_6_write_complete(relu_6_write_complete),
            .d_out(layer_7_out), .rd_en(layer_7_read_en), .layer_7_read_addr(layer_7_read_addr), .full_connect_7_ready(full_connect_7_ready),
            .full_connect_7_complete(full_connect_7_complete));

    always @(posedge clk) begin
        if(!rst) begin
            net_out <= 8'd0;
        end
        else begin
            if(full_connect_7_complete) begin
                net_out <= layer_7_out;
            end
            else begin
                net_out <= 8'd0;
            end
        end
    end

endmodule