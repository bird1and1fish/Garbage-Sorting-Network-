module GarbageSortTop # (
    localparam [4287:0] CONV1_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_8.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_7.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_6.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_5.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_4.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_3.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_2.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv1_1.hex",
    localparam [8703:0] CONV2_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_16.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_15.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_14.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_13.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_12.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_11.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_10.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_09.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_08.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_07.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_06.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_05.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_04.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_03.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_02.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv2_01.hex",
    localparam [17407:0] CONV4_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_32.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_31.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_30.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_29.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_28.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_27.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_26.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_25.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_24.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_23.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_22.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_21.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_20.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_19.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_18.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_17.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_16.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_15.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_14.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_13.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_12.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_11.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_10.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_09.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_08.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_07.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_06.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_05.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_04.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_03.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_02.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_01.hex",
    localparam [34815:0] CONV5_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_64.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_63.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_62.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_61.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_60.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_59.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_58.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_57.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_56.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_55.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_54.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_53.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_52.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_51.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_50.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_49.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_48.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_47.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_46.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_45.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_44.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_43.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_42.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_41.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_40.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_39.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_38.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_37.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_36.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_35.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_34.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_33.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_32.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_31.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_30.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_29.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_28.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_27.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_26.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_25.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_24.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_23.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_22.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_21.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_20.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_19.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_18.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_17.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_16.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_15.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_14.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_13.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_12.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_11.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_10.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_09.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_08.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_07.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_06.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_05.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_04.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_03.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_02.hexD:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_01.hex",
    localparam FULLCONNECT7_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/fullconnect7.hex"
) (
    input clk,
    input rst,
    input [23:0] d_in,
    input conv_start,
    output [9:0] read_addr,
    output [7:0] net_out,
    output net_complete
);

    // ???1?????????????????????
    wire image_input_ready;
    // ???1?????????8???????????????
    wire [63:0] layer_1_conv_tmp;
    // ???1???????????????????????????
    wire conv_1_ready;
    // ???1???????????????????????????
    wire conv_1_complete;
    // ???2?????????????????????
    wire layer_1_input_ready;
    // ???2??????????????????
    wire [6:0] conv_2_ram_write_addr;
    // ???2???????????????
    wire [7:0] layer_2_conv_tmp [15:0];
    // ???2???????????????????????????
    wire conv_2_ready;
    // ???2???????????????????????????
    wire conv_2_complete;
    // ???2?????????ram??????
    wire [7:0] layer_2_conv [15:0];
    // ???2?????????ram???????????????
    wire conv_2_write_complete;
    // ???3????????????????????????
    wire layer_3_read_en;
    // ???3??????????????????
    wire [6:0] layer_3_read_addr;
    // ???3?????????????????????
    wire layer_3_relu_begin;
    // ???3???????????????
    wire [127:0] layer_3_max_tmp;
    // ???3???????????????????????????
    wire relu_3_ready;
    // ???3?????????????????????
    wire relu_3_complete;
    // ???4?????????????????????
    wire layer_3_input_ready;
    // ???4???????????????
    wire [255:0] layer_4_conv_tmp;
    // ???4???????????????????????????
    wire conv_4_ready;
    // ???4???????????????????????????
    wire conv_4_complete;
    // ???5?????????????????????
    wire layer_4_input_ready;
    // ???5???????????????
    wire [7:0] layer_5_conv_tmp [63:0];
    // ???5??????????????????
    wire [6:0] conv_5_ram_write_addr;
    // ???5???????????????????????????
    wire conv_5_ready;
    // ???5???????????????????????????
    wire conv_5_complete;
    // ???5?????????ram??????
    wire [7:0] layer_5_conv [63:0];
    // ???5?????????ram???????????????
    wire conv_5_write_complete;
    // ???6????????????????????????
    wire layer_6_read_en;
    // ???6??????????????????
    wire [6:0] layer_6_read_addr;
    // ???6?????????????????????
    wire layer_6_relu_begin;
    // ???6???????????????
    wire [511:0] layer_6_max_tmp;
    // ???6???????????????????????????
    wire relu_6_ready;
    // ???6?????????????????????
    wire relu_6_complete;
    // ???6??????ram??????
    wire [6:0] relu_6_ram_write_addr;
    // ???6?????????ram??????
    wire [511:0] layer_6_max;
    // ???6?????????ram???????????????
    wire relu_6_write_complete;
    // ???7??????????????????
    wire layer_7_read_en;
    // ???7????????????
    wire [6:0] layer_7_read_addr;
    // ???7?????????
    wire [7:0] layer_7_out;
    // ???7?????????????????????
    wire full_connect_7_ready;
    // ???7?????????????????????
    wire full_connect_7_complete;

    assign net_complete = full_connect_7_complete;

    // ???????????????1?????????????????????
    ImageInput ImageInput(.clk(clk), .rst(rst), .conv_start(conv_start), .image_input_ready(image_input_ready));

    // ???1?????????
    genvar j;
    generate
        for(j = 0; j < 8; j = j + 1)
        begin: g0
            // ???????????????
            if(j == 0) begin
                Conv1 #(CONV1_HEX_FILE_PATH[536 * (j + 1) - 1:536 * j]) Conv1(.clk(clk), .rst(rst), .d_in(d_in), .conv_start(conv_start), .image_input_ready(image_input_ready),
                    .read_addr(read_addr), .d_out(layer_1_conv_tmp[8 * (j + 1) - 1:8 * j]), .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete));
            end
            else begin
                Conv1 #(CONV1_HEX_FILE_PATH[536 * (j + 1) - 1:536 * j]) Conv1(.clk(clk), .rst(rst), .d_in(d_in), .conv_start(conv_start), .image_input_ready(image_input_ready),
                    .d_out(layer_1_conv_tmp[8 * (j + 1) - 1:8 * j]));
            end
        end
    endgenerate

    // ???????????????2?????????????????????
    Layer1Input Layer1Input(.clk(clk), .rst(rst), .conv_start(conv_start), .conv_1_ready(conv_1_ready),
        .layer_1_input_ready(layer_1_input_ready));

    // ???2?????????
    genvar i;
    generate
        for(i = 0; i < 16; i = i + 1)
        begin: g1
            // ???????????????
            if(i == 0) begin
                // ???2?????????
                Conv2 #(CONV2_HEX_FILE_PATH[544 * (i + 1) - 1:544 * i]) Conv2(.clk(clk), .rst(rst), .d_in(layer_1_conv_tmp), .conv_start(conv_start), .layer_1_input_ready(layer_1_input_ready),
                    .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete), .d_out(layer_2_conv_tmp[i]),
                    .ram_write_addr(conv_2_ram_write_addr), .conv_2_ready(conv_2_ready), .conv_2_complete(conv_2_complete));
                // ???2???????????????
                Layer2Input Layer2Input(.clk(clk), .rst(rst), .d_in(layer_2_conv_tmp[i]), .conv_start(conv_start), .wr_en(conv_2_ready),
                    .rd_en(layer_3_read_en), .wr_addr(conv_2_ram_write_addr), .rd_addr(layer_3_read_addr), .d_out(layer_2_conv[i]),
                    .conv_2_write_complete(conv_2_write_complete), .layer_3_relu_begin(layer_3_relu_begin));
                // ???3?????????
                Relu3 Relu3(.clk(clk), .rst(rst), .layer_3_relu_begin(layer_3_relu_begin), .d_in(layer_2_conv[i]), .conv_2_ready(conv_2_ready),
                    .conv_2_write_complete(conv_2_write_complete), .d_out(layer_3_max_tmp[8 * (i + 1) - 1:8 * i]), .rd_en(layer_3_read_en),
                    .layer_3_read_addr(layer_3_read_addr), .relu_3_ready(relu_3_ready), .relu_3_complete(relu_3_complete));
            end
            else begin
                Conv2 #(CONV2_HEX_FILE_PATH[544 * (i + 1) - 1:544 * i]) Conv2(.clk(clk), .rst(rst), .d_in(layer_1_conv_tmp), .conv_start(conv_start), .layer_1_input_ready(layer_1_input_ready),
                    .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete), .d_out(layer_2_conv_tmp[i]));
                Layer2Input Layer2Input(.clk(clk), .rst(rst), .d_in(layer_2_conv_tmp[i]), .conv_start(conv_start), .wr_en(conv_2_ready),
                    .rd_en(layer_3_read_en), .wr_addr(conv_2_ram_write_addr), .rd_addr(layer_3_read_addr),
                    .d_out(layer_2_conv[i]));
                Relu3 Relu3(.clk(clk), .rst(rst), .layer_3_relu_begin(layer_3_relu_begin), .d_in(layer_2_conv[i]), .conv_2_ready(conv_2_ready),
                    .conv_2_write_complete(conv_2_write_complete), .d_out(layer_3_max_tmp[8 * (i + 1) - 1:8 * i]));
            end
        end
    endgenerate

    // ???????????????4?????????????????????
    Layer3Input Layer3Input(.clk(clk), .rst(rst), .conv_start(conv_start), .relu_3_ready(relu_3_ready),
        .layer_3_input_ready(layer_3_input_ready));

    // ???4?????????
    genvar k;
    generate
        for(k = 0; k < 32; k = k + 1)
        begin: g2
            // ???????????????
            if(k == 0) begin
                // ???4?????????
                Conv4 #(CONV4_HEX_FILE_PATH[544 * (k + 1) - 1:544 * k]) Conv4(.clk(clk), .rst(rst), .d_in(layer_3_max_tmp), .conv_start(conv_start), .layer_3_input_ready(layer_3_input_ready),
                    .relu_3_ready(relu_3_ready), .relu_3_complete(relu_3_complete), .d_out(layer_4_conv_tmp[8 * (k + 1) - 1:8 * k]),
                    .conv_4_ready(conv_4_ready), .conv_4_complete(conv_4_complete));
            end
            else begin
                Conv4 #(CONV4_HEX_FILE_PATH[544 * (k + 1) - 1:544 * k]) Conv4(.clk(clk), .rst(rst), .d_in(layer_3_max_tmp), .conv_start(conv_start), .layer_3_input_ready(layer_3_input_ready),
                    .relu_3_ready(relu_3_ready), .relu_3_complete(relu_3_complete), .d_out(layer_4_conv_tmp[8 * (k + 1) - 1:8 * k]));
            end
        end
    endgenerate

    // ???????????????5?????????????????????
    Layer4Input Layer4Input(.clk(clk), .rst(rst), .conv_start(conv_start), .conv_4_ready(conv_4_ready),
        .layer_4_input_ready(layer_4_input_ready));

    // ???5?????????
    genvar m;
    generate
        for(m = 0; m < 64; m = m + 1)
        begin: g3
            // ???????????????
            if(m == 0) begin
                // ???5?????????
                Conv5 #(CONV5_HEX_FILE_PATH[544 * (m + 1) - 1:544 * m]) Conv5(.clk(clk), .rst(rst), .d_in(layer_4_conv_tmp), .conv_start(conv_start), .layer_4_input_ready(layer_4_input_ready),
                    .conv_4_ready(conv_4_ready), .conv_4_complete(conv_4_complete), .d_out(layer_5_conv_tmp[m]),
                    .ram_write_addr(conv_5_ram_write_addr), .conv_5_ready(conv_5_ready), .conv_5_complete(conv_5_complete));
                // ???5???????????????
                Layer5Input Layer5Input(.clk(clk), .rst(rst), .d_in(layer_5_conv_tmp[m]), .conv_start(conv_start), .wr_en(conv_5_ready),
                    .rd_en(layer_6_read_en), .wr_addr(conv_5_ram_write_addr), .rd_addr(layer_6_read_addr), .d_out(layer_5_conv[m]),
                    .conv_5_write_complete(conv_5_write_complete), .layer_6_relu_begin(layer_6_relu_begin));
                // ???6?????????
                Relu6 Relu6(.clk(clk), .rst(rst), .layer_6_relu_begin(layer_6_relu_begin), .d_in(layer_5_conv[m]), .conv_5_ready(conv_5_ready),
                    .conv_5_write_complete(conv_5_write_complete), .d_out(layer_6_max_tmp[8 * (m + 1) - 1:8 * m]), .rd_en(layer_6_read_en),
                    .layer_6_read_addr(layer_6_read_addr), .ram_write_addr(relu_6_ram_write_addr), .relu_6_ready(relu_6_ready), .relu_6_complete(relu_6_complete));
            end
            else begin
                Conv5 #(CONV5_HEX_FILE_PATH[544 * (m + 1) - 1:544 * m]) Conv5(.clk(clk), .rst(rst), .d_in(layer_4_conv_tmp), .conv_start(conv_start), .layer_4_input_ready(layer_4_input_ready),
                    .conv_4_ready(conv_4_ready), .conv_4_complete(conv_4_complete), .d_out(layer_5_conv_tmp[m]));
                Layer5Input Layer5Input(.clk(clk), .rst(rst), .d_in(layer_5_conv_tmp[m]), .conv_start(conv_start), .wr_en(conv_5_ready),
                    .rd_en(layer_6_read_en), .wr_addr(conv_5_ram_write_addr), .rd_addr(layer_6_read_addr),
                    .d_out(layer_5_conv[m]));
                Relu6 Relu6(.clk(clk), .rst(rst), .layer_6_relu_begin(layer_6_relu_begin), .d_in(layer_5_conv[m]), .conv_5_ready(conv_5_ready),
                    .conv_5_write_complete(conv_5_write_complete), .d_out(layer_6_max_tmp[8 * (m + 1) - 1:8 * m]));
            end
        end
    endgenerate

    // ???6???????????????
    Layer6Input Layer6Input(.clk(clk), .rst(rst), .d_in(layer_6_max_tmp), .conv_start(conv_start), .wr_en(relu_6_ready),
            .rd_en(layer_7_read_en), .wr_addr(relu_6_ram_write_addr), .rd_addr(layer_7_read_addr), .d_out(layer_6_max),
            .relu_6_write_complete(relu_6_write_complete));
    
    // ???7????????????
    FullConnect7 #(FULLCONNECT7_HEX_FILE_PATH) FullConnect7(.clk(clk), .rst(rst), .d_in(layer_6_max), .conv_start(conv_start), .relu_6_write_complete(relu_6_write_complete),
            .d_out(layer_7_out), .rd_en(layer_7_read_en), .layer_7_read_addr(layer_7_read_addr), .full_connect_7_ready(full_connect_7_ready),
            .full_connect_7_complete(full_connect_7_complete));

    // ????????????
    NetOut NetOut(.clk(clk), .rst(rst), .conv_start(conv_start), .layer_7_out(layer_7_out), .full_connect_7_ready(full_connect_7_ready),
            .full_connect_7_complete(full_connect_7_complete), .net_out(net_out));

endmodule