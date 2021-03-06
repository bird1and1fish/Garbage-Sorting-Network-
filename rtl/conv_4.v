module Conv4 # (
    parameter CONV4_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv4_01.hex"
) (
    input clk,
    input rst,
    input [127:0] d_in,
    input conv_start,
    input layer_3_input_ready,
    input relu_3_ready,
    input relu_3_complete,
    output reg [7:0] d_out,
    output conv_4_ready,
    output conv_4_complete
);

    parameter Zx = 8'd58;
    parameter M = 9'd62;
    parameter Za = 9'd70;

    // 内置状态机，确保程序可重复执行，relu_3_ready信号置1时表明信号有效
    // layer_3_input_ready信号置1时下一周期开始运算
    // relu_3_complete置1后将移位寄存器中剩下的数继续移动
    parameter 
        VACANT = 3'd0,
        CONV_START = 3'd1,
        WAIT_RELU3 = 3'd2,
        GO_ON = 3'd3;
    reg [2:0] state = 3'd0;
    always @(posedge clk) begin
        if(!rst) begin
            state <= VACANT;
        end
        else begin
            case(state)
                VACANT: begin
                    if(conv_start) begin
                        state <= CONV_START;
                    end
                end
                CONV_START: begin
                    if(layer_3_input_ready) begin
                        state <= WAIT_RELU3;
                    end
                end
                WAIT_RELU3: begin
                    if(relu_3_complete) begin
                        state <= GO_ON;
                    end
                end
                GO_ON: begin
                    if(conv_4_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    wire calculate_begin = (state == WAIT_RELU3 && relu_3_ready) || state == GO_ON;

    // 输入图像大小为12x12x16，卷积核大小为3x3x16x32
    parameter img_raw = 4'd12;
    parameter img_line = 4'd12;
    parameter img_size = 8'd144;
    parameter convolution_size = 7'd36;// 3x12
    parameter kernel_count = 4'd9;
    parameter kernel_size = 2'd3;

    // 移位寄存器缓存16排数据
    reg [127:0] shift_reg [convolution_size - 1:0];
    reg [6:0] i = 7'd0;
    always @(posedge clk) begin
        if(!rst) begin
            for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                shift_reg[i] <= 128'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                        shift_reg[i] <= 128'd0;
                end
                // 等待relu_3_ready信号
                CONV_START: begin
                    if(relu_3_ready) begin
                        shift_reg[convolution_size - 1] <= d_in;
                        for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                            shift_reg[i - 1] <= shift_reg[i];
                    end
                end
                // 等待relu_3_ready信号
                WAIT_RELU3: begin
                    if(relu_3_ready) begin
                        shift_reg[convolution_size - 1] <= d_in;
                        for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                            shift_reg[i - 1] <= shift_reg[i];
                    end
                end
                // 第一层卷积输出完毕，剩余数自行移位
                GO_ON: begin
                    shift_reg[convolution_size - 1] <= d_in;
                    for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                        shift_reg[i - 1] <= shift_reg[i];
                end
                default: begin
                    for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                        shift_reg[i] <= 128'd0;
                end
            endcase
        end
    end

    // 从ram中读取3x3x16大小卷积核
    reg [127:0] k3 [0:kernel_count - 1];
    initial begin
        //(*rom_style = "block"*) $readmemh(CONV4_HEX_FILE_PATH, k3);
        $readmemh(CONV4_HEX_FILE_PATH, k3);
    end

    // 读取3x3x8卷积数据
    reg [127:0] mult_data [kernel_count - 1:0];
    reg [3:0] j = 4'd0;
    always @(posedge clk) begin
        if(!rst) begin
            for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                mult_data[j] <= 128'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                        mult_data[j] <= 128'd0;
                end
                // 等待relu_3_ready信号
                CONV_START: begin
                    if(relu_3_ready) begin
                        mult_data[2] <= shift_reg[0];
                        mult_data[5] <= shift_reg[img_raw];
                        mult_data[8] <= shift_reg[img_raw << 1];
                        for(j = 4'd0; j < kernel_size - 1; j = j + 4'd1) begin
                            mult_data[j] <= mult_data[j + 1];
                            mult_data[j + 3] <= mult_data[j + 3 + 1];
                            mult_data[j + 6] <= mult_data[j + 6 + 1];
                        end
                    end
                end
                // 等待relu_3_ready信号
                WAIT_RELU3: begin
                    if(relu_3_ready) begin
                        mult_data[2] <= shift_reg[0];
                        mult_data[5] <= shift_reg[img_raw];
                        mult_data[8] <= shift_reg[img_raw << 1];
                        for(j = 4'd0; j < kernel_size - 1; j = j + 4'd1) begin
                            mult_data[j] <= mult_data[j + 1];
                            mult_data[j + 3] <= mult_data[j + 3 + 1];
                            mult_data[j + 6] <= mult_data[j + 6 + 1];
                        end
                    end
                end
                // 第一层卷积输出完毕，不需要等待relu_3_ready信号
                GO_ON: begin
                    mult_data[2] <= shift_reg[0];
                    mult_data[5] <= shift_reg[img_raw];
                    mult_data[8] <= shift_reg[img_raw << 1];
                    for(j = 4'd0; j < kernel_size - 1; j = j + 4'd1) begin
                        mult_data[j] <= mult_data[j + 1];
                        mult_data[j + 3] <= mult_data[j + 3 + 1];
                        mult_data[j + 6] <= mult_data[j + 6 + 1];
                    end
                end
                default: begin
                    for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                        mult_data[j] <= 128'd0;
                end
            endcase
        end
    end

    // 乘法运算
    wire [31:0] mult [16 * kernel_count - 1:0];
    genvar k;
    generate
        for(k = 0; k < kernel_count; k = k + 1)
        begin: conv4_mult
            Mult8 Mult8_1(.clk(clk), .rst(rst), .d_in_a(k3[k][127:120]), .d_in_b(mult_data[k][127:120] - Zx),
                .start(calculate_begin), .d_out(mult[k]));
            Mult8 Mult8_2(.clk(clk), .rst(rst), .d_in_a(k3[k][119:112]), .d_in_b(mult_data[k][119:112] - Zx),
                .start(calculate_begin), .d_out(mult[k + kernel_count]));
            Mult8 Mult8_3(.clk(clk), .rst(rst), .d_in_a(k3[k][111:104]), .d_in_b(mult_data[k][111:104] - Zx),
                .start(calculate_begin), .d_out(mult[k + 2 * kernel_count]));
            Mult8 Mult8_4(.clk(clk), .rst(rst), .d_in_a(k3[k][103:96]), .d_in_b(mult_data[k][103:96] - Zx),
                .start(calculate_begin), .d_out(mult[k + 3 * kernel_count]));
            Mult8 Mult8_5(.clk(clk), .rst(rst), .d_in_a(k3[k][95:88]), .d_in_b(mult_data[k][95:88] - Zx),
                .start(calculate_begin), .d_out(mult[k + 4 * kernel_count]));
            Mult8 Mult8_6(.clk(clk), .rst(rst), .d_in_a(k3[k][87:80]), .d_in_b(mult_data[k][87:80] - Zx),
                .start(calculate_begin), .d_out(mult[k + 5 * kernel_count]));
            Mult8 Mult8_7(.clk(clk), .rst(rst), .d_in_a(k3[k][79:72]), .d_in_b(mult_data[k][79:72] - Zx),
                .start(calculate_begin), .d_out(mult[k + 6 * kernel_count]));
            Mult8 Mult8_8(.clk(clk), .rst(rst), .d_in_a(k3[k][71:64]), .d_in_b(mult_data[k][71:64] - Zx),
                .start(calculate_begin), .d_out(mult[k + 7 * kernel_count]));
            Mult8 Mult8_9(.clk(clk), .rst(rst), .d_in_a(k3[k][63:56]), .d_in_b(mult_data[k][63:56] - Zx),
                .start(calculate_begin), .d_out(mult[k + 8 * kernel_count]));
            Mult8 Mult8_10(.clk(clk), .rst(rst), .d_in_a(k3[k][55:48]), .d_in_b(mult_data[k][55:48] - Zx),
                .start(calculate_begin), .d_out(mult[k + 9 * kernel_count]));
            Mult8 Mult8_11(.clk(clk), .rst(rst), .d_in_a(k3[k][47:40]), .d_in_b(mult_data[k][47:40] - Zx),
                .start(calculate_begin), .d_out(mult[k + 10 * kernel_count]));
            Mult8 Mult8_12(.clk(clk), .rst(rst), .d_in_a(k3[k][39:32]), .d_in_b(mult_data[k][39:32] - Zx),
                .start(calculate_begin), .d_out(mult[k + 11 * kernel_count]));
            Mult8 Mult8_13(.clk(clk), .rst(rst), .d_in_a(k3[k][31:24]), .d_in_b(mult_data[k][31:24] - Zx),
                .start(calculate_begin), .d_out(mult[k + 12 * kernel_count]));
            Mult8 Mult8_14(.clk(clk), .rst(rst), .d_in_a(k3[k][23:16]), .d_in_b(mult_data[k][23:16] - Zx),
                .start(calculate_begin), .d_out(mult[k + 13 * kernel_count]));
            Mult8 Mult8_15(.clk(clk), .rst(rst), .d_in_a(k3[k][15:8]), .d_in_b(mult_data[k][15:8] - Zx),
                .start(calculate_begin), .d_out(mult[k + 14 * kernel_count]));
            Mult8 Mult8_16(.clk(clk), .rst(rst), .d_in_a(k3[k][7:0]), .d_in_b(mult_data[k][7:0] - Zx),
                .start(calculate_begin), .d_out(mult[k + 15 * kernel_count]));
        end
    endgenerate

    // 加法运算
    reg [31:0] adder_1 = 32'd0;
    reg [31:0] adder_2 = 32'd0;
    reg [31:0] adder_3 = 32'd0;
    reg [31:0] adder_4 = 32'd0;
    reg [31:0] adder_5 = 32'd0;
    reg [31:0] adder_6 = 32'd0;
    reg [31:0] adder_7 = 32'd0;
    reg [31:0] adder_8 = 32'd0;
    reg [31:0] adder_9 = 32'd0;
    reg [31:0] adder_10 = 32'd0;
    reg [31:0] adder_11 = 32'd0;
    reg [31:0] adder_12 = 32'd0;
    reg [31:0] adder_13 = 32'd0;
    reg [31:0] adder_14 = 32'd0;
    reg [31:0] adder_15 = 32'd0;
    reg [31:0] adder_16 = 32'd0;
    reg [31:0] adder_17 = 32'd0;
    reg [31:0] adder_18 = 32'd0;
    reg [31:0] adder_19 = 32'd0;
    reg [31:0] adder_20 = 32'd0;
    reg [31:0] adder_21 = 32'd0;
    reg [31:0] adder_22 = 32'd0;
    reg [31:0] adder_23 = 32'd0;
    reg [31:0] adder_24 = 32'd0;
    reg [31:0] adder_25 = 32'd0;
    reg [31:0] adder_26 = 32'd0;
    reg [31:0] adder_27 = 32'd0;
    reg [31:0] adder_28 = 32'd0;
    reg [31:0] adder_29 = 32'd0;
    reg [31:0] adder_30 = 32'd0;
    reg [31:0] adder_31 = 32'd0;
    reg [31:0] adder_32 = 32'd0;
    reg [31:0] adder_33 = 32'd0;
    reg [31:0] adder_34 = 32'd0;
    reg [31:0] adder_35 = 32'd0;
    reg [31:0] adder_36 = 32'd0;
    reg [31:0] adder_37 = 32'd0;
    reg [31:0] adder_38 = 32'd0;
    reg [31:0] adder_39 = 32'd0;
    reg [31:0] adder_40 = 32'd0;
    reg [31:0] adder_41 = 32'd0;
    reg [31:0] adder_42 = 32'd0;
    reg [31:0] adder_43 = 32'd0;
    reg [31:0] adder_44 = 32'd0;
    reg [31:0] adder_45 = 32'd0;
    reg [31:0] adder_46 = 32'd0;
    reg [31:0] adder_47 = 32'd0;
    reg [31:0] adder_48 = 32'd0;

    reg [31:0] adder_49 = 32'd0;
    reg [31:0] adder_50 = 32'd0;
    reg [31:0] adder_51 = 32'd0;
    reg [31:0] adder_52 = 32'd0;
    reg [31:0] adder_53 = 32'd0;
    reg [31:0] adder_54 = 32'd0;
    reg [31:0] adder_55 = 32'd0;
    reg [31:0] adder_56 = 32'd0;
    reg [31:0] adder_57 = 32'd0;
    reg [31:0] adder_58 = 32'd0;
    reg [31:0] adder_59 = 32'd0;
    reg [31:0] adder_60 = 32'd0;
    reg [31:0] adder_61 = 32'd0;
    reg [31:0] adder_62 = 32'd0;
    reg [31:0] adder_63 = 32'd0;
    reg [31:0] adder_64 = 32'd0;
    
    reg [31:0] adder_65 = 32'd0;
    reg [31:0] adder_66 = 32'd0;
    reg [31:0] adder_67 = 32'd0;
    reg [31:0] adder_68 = 32'd0;
    reg [31:0] adder_69 = 32'd0;

    reg [31:0] adder_70 = 32'd0;
    reg [31:0] adder_71 = 32'd0;

    reg [31:0] adder_72 = 32'd0;

    always @(posedge clk) begin
        if(!rst) begin
            adder_1 <= 32'd0; adder_2 <= 32'd0; adder_3 <= 32'd0; adder_4 <= 32'd0; adder_5 <= 32'd0; adder_6 <= 32'd0;
            adder_7 <= 32'd0; adder_8 <= 32'd0; adder_9 <= 32'd0; adder_10 <= 32'd0; adder_11 <= 32'd0; adder_12 <= 32'd0;
            adder_13 <= 32'd0; adder_14 <= 32'd0; adder_15 <= 32'd0; adder_16 <= 32'd0; adder_17 <= 32'd0; adder_18 <= 32'd0;
            adder_19 <= 32'd0; adder_20 <= 32'd0; adder_21 <= 32'd0; adder_22 <= 32'd0; adder_23 <= 32'd0; adder_24 <= 32'd0;
            adder_25 <= 32'd0; adder_26 <= 32'd0; adder_27 <= 32'd0; adder_28 <= 32'd0; adder_29 <= 32'd0; adder_30 <= 32'd0;
            adder_31 <= 32'd0; adder_32 <= 32'd0; adder_33 <= 32'd0; adder_34 <= 32'd0; adder_35 <= 32'd0; adder_36 <= 32'd0;
            adder_37 <= 32'd0; adder_38 <= 32'd0; adder_39 <= 32'd0; adder_40 <= 32'd0; adder_41 <= 32'd0; adder_42 <= 32'd0;
            adder_43 <= 32'd0; adder_44 <= 32'd0; adder_45 <= 32'd0; adder_46 <= 32'd0; adder_47 <= 32'd0; adder_48 <= 32'd0;
            adder_49 <= 32'd0; adder_50 <= 32'd0; adder_51 <= 32'd0; adder_52 <= 32'd0; adder_53 <= 32'd0; adder_54 <= 32'd0;
            adder_55 <= 32'd0; adder_56 <= 32'd0; adder_57 <= 32'd0; adder_58 <= 32'd0; adder_59 <= 32'd0; adder_60 <= 32'd0;
            adder_61 <= 32'd0; adder_62 <= 32'd0; adder_63 <= 32'd0; adder_64 <= 32'd0;
            adder_65 <= 32'd0; adder_66 <= 32'd0; adder_67 <= 32'd0; adder_68 <= 32'd0; adder_69 <= 32'd0;
            adder_70 <= 32'd0; adder_71 <= 32'd0;
            adder_72 <= 32'd0;
            d_out <= 8'd0;
        end
        else begin
            case(state)
                WAIT_RELU3: begin
                    if(calculate_begin) begin
                        adder_1 <= mult[0] + mult[1] + mult[2];
                        adder_2 <= mult[3] + mult[4] + mult[5];
                        adder_3 <= mult[6] + mult[7] + mult[8];

                        adder_4 <= mult[9] + mult[10] + mult[11];
                        adder_5 <= mult[12] + mult[13] + mult[14];
                        adder_6 <= mult[15] + mult[16] + mult[17];

                        adder_7 <= mult[18] + mult[19] + mult[20];
                        adder_8 <= mult[21] + mult[22] + mult[23];
                        adder_9 <= mult[24] + mult[25] + mult[26];

                        adder_10 <= mult[27] + mult[28] + mult[29];
                        adder_11 <= mult[30] + mult[31] + mult[32];
                        adder_12 <= mult[33] + mult[34] + mult[35];

                        adder_13 <= mult[36] + mult[37] + mult[38];
                        adder_14 <= mult[39] + mult[40] + mult[41];
                        adder_15 <= mult[42] + mult[43] + mult[44];

                        adder_16 <= mult[45] + mult[46] + mult[47];
                        adder_17 <= mult[48] + mult[49] + mult[50];
                        adder_18 <= mult[51] + mult[52] + mult[53];

                        adder_19 <= mult[54] + mult[55] + mult[56];
                        adder_20 <= mult[57] + mult[58] + mult[59];
                        adder_21 <= mult[60] + mult[61] + mult[62];

                        adder_22 <= mult[63] + mult[64] + mult[65];
                        adder_23 <= mult[66] + mult[67] + mult[68];
                        adder_24 <= mult[69] + mult[70] + mult[71];

                        adder_25 <= mult[72] + mult[73] + mult[74];
                        adder_26 <= mult[75] + mult[76] + mult[77];
                        adder_27 <= mult[78] + mult[79] + mult[80];

                        adder_28 <= mult[81] + mult[82] + mult[83];
                        adder_29 <= mult[84] + mult[85] + mult[86];
                        adder_30 <= mult[87] + mult[88] + mult[89];

                        adder_31 <= mult[90] + mult[91] + mult[92];
                        adder_32 <= mult[93] + mult[94] + mult[95];
                        adder_33 <= mult[96] + mult[97] + mult[98];

                        adder_34 <= mult[99] + mult[100] + mult[101];
                        adder_35 <= mult[102] + mult[103] + mult[104];
                        adder_36 <= mult[105] + mult[106] + mult[107];

                        adder_37 <= mult[108] + mult[109] + mult[110];
                        adder_38 <= mult[111] + mult[112] + mult[113];
                        adder_39 <= mult[114] + mult[115] + mult[116];

                        adder_40 <= mult[117] + mult[118] + mult[119];
                        adder_41 <= mult[120] + mult[121] + mult[122];
                        adder_42 <= mult[123] + mult[124] + mult[125];

                        adder_43 <= mult[126] + mult[127] + mult[128];
                        adder_44 <= mult[129] + mult[130] + mult[131];
                        adder_45 <= mult[132] + mult[133] + mult[134];

                        adder_46 <= mult[135] + mult[136] + mult[137];
                        adder_47 <= mult[138] + mult[139] + mult[140];
                        adder_48 <= mult[141] + mult[142] + mult[143];

                        adder_49 <= adder_1 + adder_2 + adder_3;
                        adder_50 <= adder_4 + adder_5 + adder_6;
                        adder_51 <= adder_7 + adder_8 + adder_9;

                        adder_52 <= adder_10 + adder_11 + adder_12;
                        adder_53 <= adder_13 + adder_14 + adder_15;
                        adder_54 <= adder_16 + adder_17 + adder_18;

                        adder_55 <= adder_19 + adder_20 + adder_21;
                        adder_56 <= adder_22 + adder_23 + adder_24;
                        adder_57 <= adder_25 + adder_26 + adder_27;

                        adder_58 <= adder_28 + adder_29 + adder_30;
                        adder_59 <= adder_31 + adder_32 + adder_33;
                        adder_60 <= adder_34 + adder_35 + adder_36;

                        adder_61 <= adder_37 + adder_38 + adder_39;
                        adder_62 <= adder_40 + adder_41 + adder_42;
                        adder_63 <= adder_43 + adder_44 + adder_45;

                        adder_64 <= adder_46 + adder_47 + adder_48;

                        adder_65 <= adder_49 + adder_50 + adder_51;
                        adder_66 <= adder_52 + adder_53 + adder_54;
                        adder_67 <= adder_55 + adder_56 + adder_57;

                        adder_68 <= adder_58 + adder_59 + adder_60;
                        adder_69 <= adder_61 + adder_62 + adder_63;

                        adder_70 <= adder_65 + adder_66 + adder_67;
                        adder_71 <= adder_68 + adder_69;

                        adder_72 <= adder_64 + adder_70 + adder_71;
                        // 右移代替除法，注意四舍五入
                        // if(adder_72[15])
                        //     d_out <= (adder_72 >> 16) + 8'd1;
                        // else
                        //     d_out <= adder_72 >> 16;
                        d_out <= ((adder_72 * M) >> 16) + Za;
                    end
                end
                GO_ON: begin
                    if(calculate_begin) begin
                        adder_1 <= mult[0] + mult[1] + mult[2];
                        adder_2 <= mult[3] + mult[4] + mult[5];
                        adder_3 <= mult[6] + mult[7] + mult[8];

                        adder_4 <= mult[9] + mult[10] + mult[11];
                        adder_5 <= mult[12] + mult[13] + mult[14];
                        adder_6 <= mult[15] + mult[16] + mult[17];

                        adder_7 <= mult[18] + mult[19] + mult[20];
                        adder_8 <= mult[21] + mult[22] + mult[23];
                        adder_9 <= mult[24] + mult[25] + mult[26];

                        adder_10 <= mult[27] + mult[28] + mult[29];
                        adder_11 <= mult[30] + mult[31] + mult[32];
                        adder_12 <= mult[33] + mult[34] + mult[35];

                        adder_13 <= mult[36] + mult[37] + mult[38];
                        adder_14 <= mult[39] + mult[40] + mult[41];
                        adder_15 <= mult[42] + mult[43] + mult[44];

                        adder_16 <= mult[45] + mult[46] + mult[47];
                        adder_17 <= mult[48] + mult[49] + mult[50];
                        adder_18 <= mult[51] + mult[52] + mult[53];

                        adder_19 <= mult[54] + mult[55] + mult[56];
                        adder_20 <= mult[57] + mult[58] + mult[59];
                        adder_21 <= mult[60] + mult[61] + mult[62];

                        adder_22 <= mult[63] + mult[64] + mult[65];
                        adder_23 <= mult[66] + mult[67] + mult[68];
                        adder_24 <= mult[69] + mult[70] + mult[71];

                        adder_25 <= mult[72] + mult[73] + mult[74];
                        adder_26 <= mult[75] + mult[76] + mult[77];
                        adder_27 <= mult[78] + mult[79] + mult[80];

                        adder_28 <= mult[81] + mult[82] + mult[83];
                        adder_29 <= mult[84] + mult[85] + mult[86];
                        adder_30 <= mult[87] + mult[88] + mult[89];

                        adder_31 <= mult[90] + mult[91] + mult[92];
                        adder_32 <= mult[93] + mult[94] + mult[95];
                        adder_33 <= mult[96] + mult[97] + mult[98];

                        adder_34 <= mult[99] + mult[100] + mult[101];
                        adder_35 <= mult[102] + mult[103] + mult[104];
                        adder_36 <= mult[105] + mult[106] + mult[107];

                        adder_37 <= mult[108] + mult[109] + mult[110];
                        adder_38 <= mult[111] + mult[112] + mult[113];
                        adder_39 <= mult[114] + mult[115] + mult[116];

                        adder_40 <= mult[117] + mult[118] + mult[119];
                        adder_41 <= mult[120] + mult[121] + mult[122];
                        adder_42 <= mult[123] + mult[124] + mult[125];

                        adder_43 <= mult[126] + mult[127] + mult[128];
                        adder_44 <= mult[129] + mult[130] + mult[131];
                        adder_45 <= mult[132] + mult[133] + mult[134];

                        adder_46 <= mult[135] + mult[136] + mult[137];
                        adder_47 <= mult[138] + mult[139] + mult[140];
                        adder_48 <= mult[141] + mult[142] + mult[143];

                        adder_49 <= adder_1 + adder_2 + adder_3;
                        adder_50 <= adder_4 + adder_5 + adder_6;
                        adder_51 <= adder_7 + adder_8 + adder_9;

                        adder_52 <= adder_10 + adder_11 + adder_12;
                        adder_53 <= adder_13 + adder_14 + adder_15;
                        adder_54 <= adder_16 + adder_17 + adder_18;

                        adder_55 <= adder_19 + adder_20 + adder_21;
                        adder_56 <= adder_22 + adder_23 + adder_24;
                        adder_57 <= adder_25 + adder_26 + adder_27;

                        adder_58 <= adder_28 + adder_29 + adder_30;
                        adder_59 <= adder_31 + adder_32 + adder_33;
                        adder_60 <= adder_34 + adder_35 + adder_36;

                        adder_61 <= adder_37 + adder_38 + adder_39;
                        adder_62 <= adder_40 + adder_41 + adder_42;
                        adder_63 <= adder_43 + adder_44 + adder_45;

                        adder_64 <= adder_46 + adder_47 + adder_48;

                        adder_65 <= adder_49 + adder_50 + adder_51;
                        adder_66 <= adder_52 + adder_53 + adder_54;
                        adder_67 <= adder_55 + adder_56 + adder_57;

                        adder_68 <= adder_58 + adder_59 + adder_60;
                        adder_69 <= adder_61 + adder_62 + adder_63;

                        adder_70 <= adder_65 + adder_66 + adder_67;
                        adder_71 <= adder_68 + adder_69;

                        adder_72 <= adder_64 + adder_70 + adder_71;
                        // 右移代替除法，注意四舍五入
                        // if(adder_72[15])
                        //     d_out <= (adder_72 >> 16) + 8'd1;
                        // else
                        //     d_out <= adder_72 >> 16;
                        d_out <= ((adder_72 * M) >> 16) + Za;
                    end
                end
                default: begin
                    adder_1 <= 32'd0; adder_2 <= 32'd0; adder_3 <= 32'd0; adder_4 <= 32'd0; adder_5 <= 32'd0; adder_6 <= 32'd0;
                    adder_7 <= 32'd0; adder_8 <= 32'd0; adder_9 <= 32'd0; adder_10 <= 32'd0; adder_11 <= 32'd0; adder_12 <= 32'd0;
                    adder_13 <= 32'd0; adder_14 <= 32'd0; adder_15 <= 32'd0; adder_16 <= 32'd0; adder_17 <= 32'd0; adder_18 <= 32'd0;
                    adder_19 <= 32'd0; adder_20 <= 32'd0; adder_21 <= 32'd0; adder_22 <= 32'd0; adder_23 <= 32'd0; adder_24 <= 32'd0;
                    adder_25 <= 32'd0; adder_26 <= 32'd0; adder_27 <= 32'd0; adder_28 <= 32'd0; adder_29 <= 32'd0; adder_30 <= 32'd0;
                    adder_31 <= 32'd0; adder_32 <= 32'd0; adder_33 <= 32'd0; adder_34 <= 32'd0; adder_35 <= 32'd0; adder_36 <= 32'd0;
                    adder_37 <= 32'd0; adder_38 <= 32'd0; adder_39 <= 32'd0; adder_40 <= 32'd0; adder_41 <= 32'd0; adder_42 <= 32'd0;
                    adder_43 <= 32'd0; adder_44 <= 32'd0; adder_45 <= 32'd0; adder_46 <= 32'd0; adder_47 <= 32'd0; adder_48 <= 32'd0;
                    adder_49 <= 32'd0; adder_50 <= 32'd0; adder_51 <= 32'd0; adder_52 <= 32'd0; adder_53 <= 32'd0; adder_54 <= 32'd0;
                    adder_55 <= 32'd0; adder_56 <= 32'd0; adder_57 <= 32'd0; adder_58 <= 32'd0; adder_59 <= 32'd0; adder_60 <= 32'd0;
                    adder_61 <= 32'd0; adder_62 <= 32'd0; adder_63 <= 32'd0; adder_64 <= 32'd0;
                    adder_65 <= 32'd0; adder_66 <= 32'd0; adder_67 <= 32'd0; adder_68 <= 32'd0; adder_69 <= 32'd0;
                    adder_70 <= 32'd0; adder_71 <= 32'd0;
                    adder_72 <= 32'd0;
                    d_out <= 8'd0;
                end
            endcase
        end
    end

    // 判断输出有效，image_input_ready第7拍后d_out数据有效
    parameter out_ready = 3'd7;
    parameter out_end = 10'd150;// 12 x 12 + 7 - 1
    reg [9:0] out_count = 10'd0;
    reg [4:0] line_count = 5'd0;
    always @(posedge clk) begin
        if(!rst) begin
            out_count <= 10'd0;
            line_count <= 5'd0;
        end
        else begin
            case(state)
                WAIT_RELU3: begin
                    if(calculate_begin) begin
                        if(out_count < out_ready + img_raw - 1'b1) begin
                            out_count <= out_count + 10'd1;
                        end
                        else begin
                            out_count <= out_ready;
                            if(line_count < img_line - kernel_size + 1'b1) begin
                                line_count <= line_count + 5'd1;
                            end
                        end
                    end
                end
                GO_ON: begin
                    if(calculate_begin) begin
                        if(out_count < out_ready + img_raw - 1'b1) begin
                            out_count <= out_count + 10'd1;
                        end
                        else begin
                            out_count <= out_ready;
                            if(line_count < img_line - kernel_size + 1'b1) begin
                                line_count <= line_count + 5'd1;
                            end
                        end
                    end
                end
                default: begin
                    out_count <= 10'd0;
                    line_count <= 5'd0;
                end
            endcase
        end
    end
    assign conv_4_ready = (calculate_begin && (out_count >= out_ready) && (out_count <= out_ready + img_raw - kernel_size)) && (line_count < img_line -kernel_size + 1'b1);

    assign conv_4_complete = line_count == img_line - kernel_size + 1'b1;

endmodule