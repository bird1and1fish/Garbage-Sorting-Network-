module Conv5 # (
    parameter CONV5_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/conv5_01.hex"
) (
    input clk,
    input rst,
    input [255:0] d_in,
    input conv_start,
    input layer_4_input_ready,
    input conv_4_ready,
    input conv_4_complete,
    output reg [7:0] d_out,
    output reg [6:0] ram_write_addr = 7'd0,
    output conv_5_ready,
    output conv_5_complete
);

    parameter Zx = 8'd70;
    parameter M = 9'd59;
    parameter Za = 9'd129;

    // 内置状态机，确保程序可重复执行，conv_4_ready信号置1时表明信号有效
    // layer_4_input_ready信号置1时下一周期开始运算
    // conv_4_complete置1后将移位寄存器中剩下的数继续移动
    parameter 
        VACANT = 3'd0,
        CONV_START = 3'd1,
        WAIT_CONV4 = 3'd2,
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
                    if(layer_4_input_ready) begin
                        state <= WAIT_CONV4;
                    end
                end
                WAIT_CONV4: begin
                    if(conv_4_complete) begin
                        state <= GO_ON;
                    end
                end
                GO_ON: begin
                    if(conv_5_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    wire calculate_begin = (state == WAIT_CONV4 && conv_4_ready) || state == GO_ON;

    // 输入图像大小为10x10x32，卷积核大小为3x3x32x64
    parameter img_raw = 5'd10;
    parameter img_line = 5'd10;
    parameter img_size = 10'd100;
    parameter convolution_size = 7'd30;// 3x10
    parameter kernel_count = 4'd9;
    parameter kernel_size = 2'd3;

    // 移位寄存器缓存32排数据
    reg [255:0] shift_reg [convolution_size - 1:0];
    reg [6:0] i = 7'd0;
    always @(posedge clk) begin
        if(!rst) begin
            for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                shift_reg[i] <= 256'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                        shift_reg[i] <= 256'd0;
                end
                // 等待conv_4_ready信号
                CONV_START: begin
                    if(conv_4_ready) begin
                        shift_reg[convolution_size - 1] <= d_in;
                        for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                            shift_reg[i - 1] <= shift_reg[i];
                    end
                end
                // 等待conv_4_ready信号
                WAIT_CONV4: begin
                    if(conv_4_ready) begin
                        shift_reg[convolution_size - 1] <= d_in;
                        for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                            shift_reg[i - 1] <= shift_reg[i];
                    end
                end
                // 第四层卷积输出完毕，剩余数自行移位
                GO_ON: begin
                    shift_reg[convolution_size - 1] <= d_in;
                    for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                        shift_reg[i - 1] <= shift_reg[i];
                end
                default: begin
                    for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                        shift_reg[i] <= 256'd0;
                end
            endcase
        end
    end

    // 从ram中读取3x3x32大小卷积核
    reg [255:0] k4 [0:kernel_count - 1];
    initial begin
        (*rom_style = "block"*) $readmemh(CONV5_HEX_FILE_PATH, k4);
    end

    // 读取3x3x32卷积数据
    reg [255:0] mult_data [kernel_count - 1:0];
    reg [3:0] j = 4'd0;
    always @(posedge clk) begin
        if(!rst) begin
            for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                mult_data[j] <= 256'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                        mult_data[j] <= 256'd0;
                end
                // 等待conv_4_ready信号
                CONV_START: begin
                    if(conv_4_ready) begin
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
                // 等待conv_4_ready信号
                WAIT_CONV4: begin
                    if(conv_4_ready) begin
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
                // 第一层卷积输出完毕，不需要等待conv_4_ready信号
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
                        mult_data[j] <= 256'd0;
                end
            endcase
        end
    end

    // 乘法运算
    wire [31:0] mult [32 * kernel_count - 1:0];
    genvar k;
    generate
        for(k = 0; k < kernel_count; k = k + 1)
        begin: conv5_mult
            Mult8 Mult8_1(.clk(clk), .rst(rst), .d_in_a(k4[k][255:248]), .d_in_b(mult_data[k][255:248] - Zx),
                .start(calculate_begin), .d_out(mult[k]));
            Mult8 Mult8_2(.clk(clk), .rst(rst), .d_in_a(k4[k][247:240]), .d_in_b(mult_data[k][247:240] - Zx),
                .start(calculate_begin), .d_out(mult[k + kernel_count]));
            Mult8 Mult8_3(.clk(clk), .rst(rst), .d_in_a(k4[k][239:232]), .d_in_b(mult_data[k][239:232] - Zx),
                .start(calculate_begin), .d_out(mult[k + 2 * kernel_count]));
            Mult8 Mult8_4(.clk(clk), .rst(rst), .d_in_a(k4[k][231:224]), .d_in_b(mult_data[k][231:224] - Zx),
                .start(calculate_begin), .d_out(mult[k + 3 * kernel_count]));
            Mult8 Mult8_5(.clk(clk), .rst(rst), .d_in_a(k4[k][223:216]), .d_in_b(mult_data[k][223:216] - Zx),
                .start(calculate_begin), .d_out(mult[k + 4 * kernel_count]));
            Mult8 Mult8_6(.clk(clk), .rst(rst), .d_in_a(k4[k][215:208]), .d_in_b(mult_data[k][215:208] - Zx),
                .start(calculate_begin), .d_out(mult[k + 5 * kernel_count]));
            Mult8 Mult8_7(.clk(clk), .rst(rst), .d_in_a(k4[k][207:200]), .d_in_b(mult_data[k][207:200] - Zx),
                .start(calculate_begin), .d_out(mult[k + 6 * kernel_count]));
            Mult8 Mult8_8(.clk(clk), .rst(rst), .d_in_a(k4[k][199:192]), .d_in_b(mult_data[k][199:192] - Zx),
                .start(calculate_begin), .d_out(mult[k + 7 * kernel_count]));
            Mult8 Mult8_9(.clk(clk), .rst(rst), .d_in_a(k4[k][191:184]), .d_in_b(mult_data[k][191:184] - Zx),
                .start(calculate_begin), .d_out(mult[k + 8 * kernel_count]));
            Mult8 Mult8_10(.clk(clk), .rst(rst), .d_in_a(k4[k][183:176]), .d_in_b(mult_data[k][183:176] - Zx),
                .start(calculate_begin), .d_out(mult[k + 9 * kernel_count]));
            Mult8 Mult8_11(.clk(clk), .rst(rst), .d_in_a(k4[k][175:168]), .d_in_b(mult_data[k][175:168] - Zx),
                .start(calculate_begin), .d_out(mult[k + 10 * kernel_count]));
            Mult8 Mult8_12(.clk(clk), .rst(rst), .d_in_a(k4[k][167:160]), .d_in_b(mult_data[k][167:160] - Zx),
                .start(calculate_begin), .d_out(mult[k + 11 * kernel_count]));
            Mult8 Mult8_13(.clk(clk), .rst(rst), .d_in_a(k4[k][159:152]), .d_in_b(mult_data[k][159:152] - Zx),
                .start(calculate_begin), .d_out(mult[k + 12 * kernel_count]));
            Mult8 Mult8_14(.clk(clk), .rst(rst), .d_in_a(k4[k][151:144]), .d_in_b(mult_data[k][151:144] - Zx),
                .start(calculate_begin), .d_out(mult[k + 13 * kernel_count]));
            Mult8 Mult8_15(.clk(clk), .rst(rst), .d_in_a(k4[k][143:136]), .d_in_b(mult_data[k][143:136] - Zx),
                .start(calculate_begin), .d_out(mult[k + 14 * kernel_count]));
            Mult8 Mult8_16(.clk(clk), .rst(rst), .d_in_a(k4[k][135:128]), .d_in_b(mult_data[k][135:128] - Zx),
                .start(calculate_begin), .d_out(mult[k + 15 * kernel_count]));
            Mult8 Mult8_17(.clk(clk), .rst(rst), .d_in_a(k4[k][127:120]), .d_in_b(mult_data[k][127:120] - Zx),
                .start(calculate_begin), .d_out(mult[k + 16 * kernel_count]));
            Mult8 Mult8_18(.clk(clk), .rst(rst), .d_in_a(k4[k][119:112]), .d_in_b(mult_data[k][119:112] - Zx),
                .start(calculate_begin), .d_out(mult[k + 17 * kernel_count]));
            Mult8 Mult8_19(.clk(clk), .rst(rst), .d_in_a(k4[k][111:104]), .d_in_b(mult_data[k][111:104] - Zx),
                .start(calculate_begin), .d_out(mult[k + 18 * kernel_count]));
            Mult8 Mult8_20(.clk(clk), .rst(rst), .d_in_a(k4[k][103:96]), .d_in_b(mult_data[k][103:96] - Zx),
                .start(calculate_begin), .d_out(mult[k + 19 * kernel_count]));
            Mult8 Mult8_21(.clk(clk), .rst(rst), .d_in_a(k4[k][95:88]), .d_in_b(mult_data[k][95:88] - Zx),
                .start(calculate_begin), .d_out(mult[k + 20 * kernel_count]));
            Mult8 Mult8_22(.clk(clk), .rst(rst), .d_in_a(k4[k][87:80]), .d_in_b(mult_data[k][87:80] - Zx),
                .start(calculate_begin), .d_out(mult[k + 21 * kernel_count]));
            Mult8 Mult8_23(.clk(clk), .rst(rst), .d_in_a(k4[k][79:72]), .d_in_b(mult_data[k][79:72] - Zx),
                .start(calculate_begin), .d_out(mult[k + 22 * kernel_count]));
            Mult8 Mult8_24(.clk(clk), .rst(rst), .d_in_a(k4[k][71:64]), .d_in_b(mult_data[k][71:64] - Zx),
                .start(calculate_begin), .d_out(mult[k + 23 * kernel_count]));
            Mult8 Mult8_25(.clk(clk), .rst(rst), .d_in_a(k4[k][63:56]), .d_in_b(mult_data[k][63:56] - Zx),
                .start(calculate_begin), .d_out(mult[k + 24 * kernel_count]));
            Mult8 Mult8_26(.clk(clk), .rst(rst), .d_in_a(k4[k][55:48]), .d_in_b(mult_data[k][55:48] - Zx),
                .start(calculate_begin), .d_out(mult[k + 25 * kernel_count]));
            Mult8 Mult8_27(.clk(clk), .rst(rst), .d_in_a(k4[k][47:40]), .d_in_b(mult_data[k][47:40] - Zx),
                .start(calculate_begin), .d_out(mult[k + 26 * kernel_count]));
            Mult8 Mult8_28(.clk(clk), .rst(rst), .d_in_a(k4[k][39:32]), .d_in_b(mult_data[k][39:32] - Zx),
                .start(calculate_begin), .d_out(mult[k + 27 * kernel_count]));
            Mult8 Mult8_29(.clk(clk), .rst(rst), .d_in_a(k4[k][31:24]), .d_in_b(mult_data[k][31:24] - Zx),
                .start(calculate_begin), .d_out(mult[k + 28 * kernel_count]));
            Mult8 Mult8_30(.clk(clk), .rst(rst), .d_in_a(k4[k][23:16]), .d_in_b(mult_data[k][23:16] - Zx),
                .start(calculate_begin), .d_out(mult[k + 29 * kernel_count]));
            Mult8 Mult8_31(.clk(clk), .rst(rst), .d_in_a(k4[k][15:8]), .d_in_b(mult_data[k][15:8] - Zx),
                .start(calculate_begin), .d_out(mult[k + 30 * kernel_count]));
            Mult8 Mult8_32(.clk(clk), .rst(rst), .d_in_a(k4[k][7:0]), .d_in_b(mult_data[k][7:0] - Zx),
                .start(calculate_begin), .d_out(mult[k + 31 * kernel_count]));
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
    reg [31:0] adder_73 = 32'd0;
    reg [31:0] adder_74 = 32'd0;
    reg [31:0] adder_75 = 32'd0;
    reg [31:0] adder_76 = 32'd0;
    reg [31:0] adder_77 = 32'd0;
    reg [31:0] adder_78 = 32'd0;
    reg [31:0] adder_79 = 32'd0;
    reg [31:0] adder_80 = 32'd0;
    reg [31:0] adder_81 = 32'd0;
    reg [31:0] adder_82 = 32'd0;
    reg [31:0] adder_83 = 32'd0;
    reg [31:0] adder_84 = 32'd0;
    reg [31:0] adder_85 = 32'd0;
    reg [31:0] adder_86 = 32'd0;
    reg [31:0] adder_87 = 32'd0;
    reg [31:0] adder_88 = 32'd0;
    reg [31:0] adder_89 = 32'd0;
    reg [31:0] adder_90 = 32'd0;
    reg [31:0] adder_91 = 32'd0;
    reg [31:0] adder_92 = 32'd0;
    reg [31:0] adder_93 = 32'd0;
    reg [31:0] adder_94 = 32'd0;
    reg [31:0] adder_95 = 32'd0;
    reg [31:0] adder_96 = 32'd0;

    reg [31:0] adder_97 = 32'd0;
    reg [31:0] adder_98 = 32'd0;
    reg [31:0] adder_99 = 32'd0;
    reg [31:0] adder_100 = 32'd0;
    reg [31:0] adder_101 = 32'd0;
    reg [31:0] adder_102 = 32'd0;
    reg [31:0] adder_103 = 32'd0;
    reg [31:0] adder_104 = 32'd0;
    reg [31:0] adder_105 = 32'd0;
    reg [31:0] adder_106 = 32'd0;
    reg [31:0] adder_107 = 32'd0;
    reg [31:0] adder_108 = 32'd0;
    reg [31:0] adder_109 = 32'd0;
    reg [31:0] adder_110 = 32'd0;
    reg [31:0] adder_111 = 32'd0;
    reg [31:0] adder_112 = 32'd0;
    reg [31:0] adder_113 = 32'd0;
    reg [31:0] adder_114 = 32'd0;
    reg [31:0] adder_115 = 32'd0;
    reg [31:0] adder_116 = 32'd0;
    reg [31:0] adder_117 = 32'd0;
    reg [31:0] adder_118 = 32'd0;
    reg [31:0] adder_119 = 32'd0;
    reg [31:0] adder_120 = 32'd0;
    reg [31:0] adder_121 = 32'd0;
    reg [31:0] adder_122 = 32'd0;
    reg [31:0] adder_123 = 32'd0;
    reg [31:0] adder_124 = 32'd0;
    reg [31:0] adder_125 = 32'd0;
    reg [31:0] adder_126 = 32'd0;
    reg [31:0] adder_127 = 32'd0;
    reg [31:0] adder_128 = 32'd0;
    
    reg [31:0] adder_129 = 32'd0;
    reg [31:0] adder_130 = 32'd0;
    reg [31:0] adder_131 = 32'd0;
    reg [31:0] adder_132 = 32'd0;
    reg [31:0] adder_133 = 32'd0;
    reg [31:0] adder_134 = 32'd0;
    reg [31:0] adder_135 = 32'd0;
    reg [31:0] adder_136 = 32'd0;
    reg [31:0] adder_137 = 32'd0;
    reg [31:0] adder_138 = 32'd0;
    reg [31:0] adder_139 = 32'd0;

    reg [31:0] adder_140 = 32'd0;
    reg [31:0] adder_141 = 32'd0;
    reg [31:0] adder_142 = 32'd0;
    reg [31:0] adder_143 = 32'd0;

    reg [31:0] adder_144 = 32'd0;

    reg [31:0] adder_145 = 32'd0;

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
            adder_61 <= 32'd0; adder_62 <= 32'd0; adder_63 <= 32'd0; adder_64 <= 32'd0; adder_65 <= 32'd0; adder_66 <= 32'd0;
            adder_67 <= 32'd0; adder_68 <= 32'd0; adder_69 <= 32'd0; adder_70 <= 32'd0; adder_71 <= 32'd0; adder_72 <= 32'd0;
            adder_73 <= 32'd0; adder_74 <= 32'd0; adder_75 <= 32'd0; adder_76 <= 32'd0; adder_77 <= 32'd0; adder_78 <= 32'd0;
            adder_79 <= 32'd0; adder_80 <= 32'd0; adder_81 <= 32'd0; adder_82 <= 32'd0; adder_83 <= 32'd0; adder_84 <= 32'd0;
            adder_85 <= 32'd0; adder_86 <= 32'd0; adder_87 <= 32'd0; adder_88 <= 32'd0; adder_89 <= 32'd0; adder_90 <= 32'd0;
            adder_91 <= 32'd0; adder_92 <= 32'd0; adder_93 <= 32'd0; adder_94 <= 32'd0; adder_95 <= 32'd0; adder_96 <= 32'd0;
            adder_97 <= 32'd0; adder_98 <= 32'd0; adder_99 <= 32'd0; adder_100 <= 32'd0; adder_101 <= 32'd0; adder_102 <= 32'd0;
            adder_103 <= 32'd0; adder_104 <= 32'd0; adder_105 <= 32'd0; adder_106 <= 32'd0; adder_107 <= 32'd0; adder_108 <= 32'd0;
            adder_109 <= 32'd0; adder_110 <= 32'd0; adder_111 <= 32'd0; adder_112 <= 32'd0; adder_113 <= 32'd0; adder_114 <= 32'd0;
            adder_115 <= 32'd0; adder_116 <= 32'd0; adder_117 <= 32'd0; adder_118 <= 32'd0; adder_119 <= 32'd0; adder_120 <= 32'd0;
            adder_121 <= 32'd0; adder_122 <= 32'd0; adder_123 <= 32'd0; adder_124 <= 32'd0; adder_125 <= 32'd0; adder_126 <= 32'd0;
            adder_127 <= 32'd0; adder_128 <= 32'd0;
            adder_129 <= 32'd0; adder_130 <= 32'd0; adder_131 <= 32'd0; adder_132 <= 32'd0; adder_133 <= 32'd0; adder_134 <= 32'd0;
            adder_135 <= 32'd0; adder_136 <= 32'd0; adder_137 <= 32'd0; adder_138 <= 32'd0; adder_139 <= 32'd0;
            adder_140 <= 32'd0; adder_141 <= 32'd0; adder_142 <= 32'd0; adder_143 <= 32'd0;
            adder_144 <= 32'd0;
            adder_145 <= 32'd0;
            d_out <= 8'd0;
        end
        else begin
            case(state)
                WAIT_CONV4: begin
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

                        adder_49 <= mult[144] + mult[145] + mult[146];
                        adder_50 <= mult[147] + mult[148] + mult[149];
                        adder_51 <= mult[150] + mult[151] + mult[152];

                        adder_52 <= mult[153] + mult[154] + mult[155];
                        adder_53 <= mult[156] + mult[157] + mult[158];
                        adder_54 <= mult[159] + mult[160] + mult[161];

                        adder_55 <= mult[162] + mult[163] + mult[164];
                        adder_56 <= mult[165] + mult[166] + mult[167];
                        adder_57 <= mult[168] + mult[169] + mult[170];

                        adder_58 <= mult[171] + mult[172] + mult[173];
                        adder_59 <= mult[174] + mult[175] + mult[176];
                        adder_60 <= mult[177] + mult[178] + mult[179];

                        adder_61 <= mult[180] + mult[181] + mult[182];
                        adder_62 <= mult[183] + mult[184] + mult[185];
                        adder_63 <= mult[186] + mult[187] + mult[188];

                        adder_64 <= mult[189] + mult[190] + mult[191];
                        adder_56 <= mult[192] + mult[193] + mult[194];
                        adder_66 <= mult[195] + mult[196] + mult[197];

                        adder_67 <= mult[198] + mult[199] + mult[200];
                        adder_68 <= mult[201] + mult[202] + mult[203];
                        adder_69 <= mult[204] + mult[205] + mult[206];

                        adder_70 <= mult[207] + mult[208] + mult[209];
                        adder_71 <= mult[210] + mult[211] + mult[212];
                        adder_72 <= mult[213] + mult[214] + mult[215];

                        adder_73 <= mult[216] + mult[217] + mult[218];
                        adder_74 <= mult[219] + mult[220] + mult[221];
                        adder_75 <= mult[222] + mult[223] + mult[224];

                        adder_76 <= mult[225] + mult[226] + mult[227];
                        adder_77 <= mult[228] + mult[229] + mult[230];
                        adder_78 <= mult[231] + mult[232] + mult[233];

                        adder_79 <= mult[234] + mult[235] + mult[236];
                        adder_80 <= mult[237] + mult[238] + mult[239];
                        adder_81 <= mult[240] + mult[241] + mult[242];

                        adder_82 <= mult[243] + mult[244] + mult[245];
                        adder_83 <= mult[246] + mult[247] + mult[248];
                        adder_84 <= mult[249] + mult[250] + mult[251];

                        adder_85 <= mult[252] + mult[253] + mult[254];
                        adder_86 <= mult[255] + mult[256] + mult[257];
                        adder_87 <= mult[258] + mult[259] + mult[260];

                        adder_88 <= mult[261] + mult[262] + mult[263];
                        adder_89 <= mult[264] + mult[265] + mult[266];
                        adder_90 <= mult[267] + mult[268] + mult[269];

                        adder_91 <= mult[270] + mult[271] + mult[272];
                        adder_92 <= mult[273] + mult[274] + mult[275];
                        adder_93 <= mult[276] + mult[277] + mult[278];

                        adder_94 <= mult[279] + mult[280] + mult[281];
                        adder_95 <= mult[282] + mult[283] + mult[284];
                        adder_96 <= mult[285] + mult[286] + mult[287];

                        adder_97 <= adder_1 + adder_2 + adder_3;
                        adder_98 <= adder_4 + adder_5 + adder_6;
                        adder_99 <= adder_7 + adder_8 + adder_9;

                        adder_100 <= adder_10 + adder_11 + adder_12;
                        adder_101 <= adder_13 + adder_14 + adder_15;
                        adder_102 <= adder_16 + adder_17 + adder_18;

                        adder_103 <= adder_19 + adder_20 + adder_21;
                        adder_104 <= adder_22 + adder_23 + adder_24;
                        adder_105 <= adder_25 + adder_26 + adder_27;

                        adder_106 <= adder_28 + adder_29 + adder_30;
                        adder_107 <= adder_31 + adder_32 + adder_33;
                        adder_108 <= adder_34 + adder_35 + adder_36;

                        adder_109 <= adder_37 + adder_38 + adder_39;
                        adder_110 <= adder_40 + adder_41 + adder_42;
                        adder_111 <= adder_43 + adder_44 + adder_45;

                        adder_112 <= adder_46 + adder_47 + adder_48;
                        adder_113 <= adder_49 + adder_50 + adder_51;
                        adder_114 <= adder_52 + adder_53 + adder_54;

                        adder_115 <= adder_55 + adder_56 + adder_57;
                        adder_116 <= adder_58 + adder_59 + adder_60;
                        adder_117 <= adder_61 + adder_62 + adder_63;

                        adder_118 <= adder_64 + adder_65 + adder_66;
                        adder_119 <= adder_67 + adder_68 + adder_69;
                        adder_120 <= adder_70 + adder_71 + adder_72;

                        adder_121 <= adder_73 + adder_74 + adder_75;
                        adder_122 <= adder_76 + adder_77 + adder_78;
                        adder_123 <= adder_79 + adder_80 + adder_81;

                        adder_124 <= adder_82 + adder_83 + adder_84;
                        adder_125 <= adder_85 + adder_86 + adder_87;
                        adder_126 <= adder_88 + adder_89 + adder_90;

                        adder_127 <= adder_91 + adder_92 + adder_93;
                        adder_128 <= adder_94 + adder_95 + adder_96;

                        adder_129 <= adder_97 + adder_98 + adder_99;
                        adder_130 <= adder_100 + adder_101 + adder_102;
                        adder_131 <= adder_103 + adder_104 + adder_105;

                        adder_132 <= adder_106 + adder_107 + adder_108;
                        adder_133 <= adder_109 + adder_110 + adder_111;
                        adder_134 <= adder_112 + adder_113 + adder_114;

                        adder_135 <= adder_115 + adder_116 + adder_117;
                        adder_136 <= adder_118 + adder_119 + adder_120;
                        adder_137 <= adder_121 + adder_122 + adder_123;

                        adder_138 <= adder_124 + adder_125 + adder_126;
                        adder_139 <= adder_127 + adder_128;

                        adder_140 <= adder_129 + adder_130 + adder_131;
                        adder_141 <= adder_132 + adder_133 + adder_134;
                        adder_142 <= adder_135 + adder_136 + adder_137;

                        adder_143 <= adder_138 + adder_139;

                        adder_144 <= adder_140 + adder_141 + adder_142;

                        adder_145 <= adder_143 + adder_144;
                        // 右移代替除法，注意四舍五入
                        // if(adder_145[16])
                        //     d_out <= (adder_72 >> 17) + 8'd1;
                        // else
                        //     d_out <= adder_72 >> 17;
                        d_out <= ((adder_145 * M) >> 16) + Za;
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

                        adder_49 <= mult[144] + mult[145] + mult[146];
                        adder_50 <= mult[147] + mult[148] + mult[149];
                        adder_51 <= mult[150] + mult[151] + mult[152];

                        adder_52 <= mult[153] + mult[154] + mult[155];
                        adder_53 <= mult[156] + mult[157] + mult[158];
                        adder_54 <= mult[159] + mult[160] + mult[161];

                        adder_55 <= mult[162] + mult[163] + mult[164];
                        adder_56 <= mult[165] + mult[166] + mult[167];
                        adder_57 <= mult[168] + mult[169] + mult[170];

                        adder_58 <= mult[171] + mult[172] + mult[173];
                        adder_59 <= mult[174] + mult[175] + mult[176];
                        adder_60 <= mult[177] + mult[178] + mult[179];

                        adder_61 <= mult[180] + mult[181] + mult[182];
                        adder_62 <= mult[183] + mult[184] + mult[185];
                        adder_63 <= mult[186] + mult[187] + mult[188];

                        adder_64 <= mult[189] + mult[190] + mult[191];
                        adder_56 <= mult[192] + mult[193] + mult[194];
                        adder_66 <= mult[195] + mult[196] + mult[197];

                        adder_67 <= mult[198] + mult[199] + mult[200];
                        adder_68 <= mult[201] + mult[202] + mult[203];
                        adder_69 <= mult[204] + mult[205] + mult[206];

                        adder_70 <= mult[207] + mult[208] + mult[209];
                        adder_71 <= mult[210] + mult[211] + mult[212];
                        adder_72 <= mult[213] + mult[214] + mult[215];

                        adder_73 <= mult[216] + mult[217] + mult[218];
                        adder_74 <= mult[219] + mult[220] + mult[221];
                        adder_75 <= mult[222] + mult[223] + mult[224];

                        adder_76 <= mult[225] + mult[226] + mult[227];
                        adder_77 <= mult[228] + mult[229] + mult[230];
                        adder_78 <= mult[231] + mult[232] + mult[233];

                        adder_79 <= mult[234] + mult[235] + mult[236];
                        adder_80 <= mult[237] + mult[238] + mult[239];
                        adder_81 <= mult[240] + mult[241] + mult[242];

                        adder_82 <= mult[243] + mult[244] + mult[245];
                        adder_83 <= mult[246] + mult[247] + mult[248];
                        adder_84 <= mult[249] + mult[250] + mult[251];

                        adder_85 <= mult[252] + mult[253] + mult[254];
                        adder_86 <= mult[255] + mult[256] + mult[257];
                        adder_87 <= mult[258] + mult[259] + mult[260];

                        adder_88 <= mult[261] + mult[262] + mult[263];
                        adder_89 <= mult[264] + mult[265] + mult[266];
                        adder_90 <= mult[267] + mult[268] + mult[269];

                        adder_91 <= mult[270] + mult[271] + mult[272];
                        adder_92 <= mult[273] + mult[274] + mult[275];
                        adder_93 <= mult[276] + mult[277] + mult[278];

                        adder_94 <= mult[279] + mult[280] + mult[281];
                        adder_95 <= mult[282] + mult[283] + mult[284];
                        adder_96 <= mult[285] + mult[286] + mult[287];

                        adder_97 <= adder_1 + adder_2 + adder_3;
                        adder_98 <= adder_4 + adder_5 + adder_6;
                        adder_99 <= adder_7 + adder_8 + adder_9;

                        adder_100 <= adder_10 + adder_11 + adder_12;
                        adder_101 <= adder_13 + adder_14 + adder_15;
                        adder_102 <= adder_16 + adder_17 + adder_18;

                        adder_103 <= adder_19 + adder_20 + adder_21;
                        adder_104 <= adder_22 + adder_23 + adder_24;
                        adder_105 <= adder_25 + adder_26 + adder_27;

                        adder_106 <= adder_28 + adder_29 + adder_30;
                        adder_107 <= adder_31 + adder_32 + adder_33;
                        adder_108 <= adder_34 + adder_35 + adder_36;

                        adder_109 <= adder_37 + adder_38 + adder_39;
                        adder_110 <= adder_40 + adder_41 + adder_42;
                        adder_111 <= adder_43 + adder_44 + adder_45;

                        adder_112 <= adder_46 + adder_47 + adder_48;
                        adder_113 <= adder_49 + adder_50 + adder_51;
                        adder_114 <= adder_52 + adder_53 + adder_54;

                        adder_115 <= adder_55 + adder_56 + adder_57;
                        adder_116 <= adder_58 + adder_59 + adder_60;
                        adder_117 <= adder_61 + adder_62 + adder_63;

                        adder_118 <= adder_64 + adder_65 + adder_66;
                        adder_119 <= adder_67 + adder_68 + adder_69;
                        adder_120 <= adder_70 + adder_71 + adder_72;

                        adder_121 <= adder_73 + adder_74 + adder_75;
                        adder_122 <= adder_76 + adder_77 + adder_78;
                        adder_123 <= adder_79 + adder_80 + adder_81;

                        adder_124 <= adder_82 + adder_83 + adder_84;
                        adder_125 <= adder_85 + adder_86 + adder_87;
                        adder_126 <= adder_88 + adder_89 + adder_90;

                        adder_127 <= adder_91 + adder_92 + adder_93;
                        adder_128 <= adder_94 + adder_95 + adder_96;

                        adder_129 <= adder_97 + adder_98 + adder_99;
                        adder_130 <= adder_100 + adder_101 + adder_102;
                        adder_131 <= adder_103 + adder_104 + adder_105;

                        adder_132 <= adder_106 + adder_107 + adder_108;
                        adder_133 <= adder_109 + adder_110 + adder_111;
                        adder_134 <= adder_112 + adder_113 + adder_114;

                        adder_135 <= adder_115 + adder_116 + adder_117;
                        adder_136 <= adder_118 + adder_119 + adder_120;
                        adder_137 <= adder_121 + adder_122 + adder_123;

                        adder_138 <= adder_124 + adder_125 + adder_126;
                        adder_139 <= adder_127 + adder_128;

                        adder_140 <= adder_129 + adder_130 + adder_131;
                        adder_141 <= adder_132 + adder_133 + adder_134;
                        adder_142 <= adder_135 + adder_136 + adder_137;

                        adder_143 <= adder_138 + adder_139;

                        adder_144 <= adder_140 + adder_141 + adder_142;

                        adder_145 <= adder_143 + adder_144;
                        // 右移代替除法，注意四舍五入
                        // if(adder_145[16])
                        //     d_out <= (adder_72 >> 17) + 8'd1;
                        // else
                        //     d_out <= adder_72 >> 17;
                        d_out <= ((adder_145 * M) >> 16) + Za;
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
                    adder_61 <= 32'd0; adder_62 <= 32'd0; adder_63 <= 32'd0; adder_64 <= 32'd0; adder_65 <= 32'd0; adder_66 <= 32'd0;
                    adder_67 <= 32'd0; adder_68 <= 32'd0; adder_69 <= 32'd0; adder_70 <= 32'd0; adder_71 <= 32'd0; adder_72 <= 32'd0;
                    adder_73 <= 32'd0; adder_74 <= 32'd0; adder_75 <= 32'd0; adder_76 <= 32'd0; adder_77 <= 32'd0; adder_78 <= 32'd0;
                    adder_79 <= 32'd0; adder_80 <= 32'd0; adder_81 <= 32'd0; adder_82 <= 32'd0; adder_83 <= 32'd0; adder_84 <= 32'd0;
                    adder_85 <= 32'd0; adder_86 <= 32'd0; adder_87 <= 32'd0; adder_88 <= 32'd0; adder_89 <= 32'd0; adder_90 <= 32'd0;
                    adder_91 <= 32'd0; adder_92 <= 32'd0; adder_93 <= 32'd0; adder_94 <= 32'd0; adder_95 <= 32'd0; adder_96 <= 32'd0;
                    adder_97 <= 32'd0; adder_98 <= 32'd0; adder_99 <= 32'd0; adder_100 <= 32'd0; adder_101 <= 32'd0; adder_102 <= 32'd0;
                    adder_103 <= 32'd0; adder_104 <= 32'd0; adder_105 <= 32'd0; adder_106 <= 32'd0; adder_107 <= 32'd0; adder_108 <= 32'd0;
                    adder_109 <= 32'd0; adder_110 <= 32'd0; adder_111 <= 32'd0; adder_112 <= 32'd0; adder_113 <= 32'd0; adder_114 <= 32'd0;
                    adder_115 <= 32'd0; adder_116 <= 32'd0; adder_117 <= 32'd0; adder_118 <= 32'd0; adder_119 <= 32'd0; adder_120 <= 32'd0;
                    adder_121 <= 32'd0; adder_122 <= 32'd0; adder_123 <= 32'd0; adder_124 <= 32'd0; adder_125 <= 32'd0; adder_126 <= 32'd0;
                    adder_127 <= 32'd0; adder_128 <= 32'd0;
                    adder_129 <= 32'd0; adder_130 <= 32'd0; adder_131 <= 32'd0; adder_132 <= 32'd0; adder_133 <= 32'd0; adder_134 <= 32'd0;
                    adder_135 <= 32'd0; adder_136 <= 32'd0; adder_137 <= 32'd0; adder_138 <= 32'd0; adder_139 <= 32'd0;
                    adder_140 <= 32'd0; adder_141 <= 32'd0; adder_142 <= 32'd0; adder_143 <= 32'd0;
                    adder_144 <= 32'd0;
                    adder_145 <= 32'd0;
                    d_out <= 8'd0;
                end
            endcase
        end
    end

    // 判断输出有效，image_input_ready第8拍后d_out数据有效
    parameter out_ready = 4'd8;
    parameter out_end = 10'd107;// 10 x 10 + 8 - 1
    reg [9:0] out_count = 10'd0;
    reg [4:0] line_count = 5'd0;
    always @(posedge clk) begin
        if(!rst) begin
            out_count <= 10'd0;
            line_count <= 5'd0;
        end
        else begin
            case(state)
                WAIT_CONV4: begin
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
    assign conv_5_ready = (calculate_begin && (out_count >= out_ready) && (out_count <= out_ready + img_raw - kernel_size)) && (line_count < img_line -kernel_size + 1'b1);

    assign conv_5_complete = line_count == img_line - kernel_size + 1'b1;

    // 设置写地址，乒乓缓存大小为4x8
    parameter pingpong_size = 7'd32;
    always @(posedge clk) begin
        if(!rst) begin
            ram_write_addr <= 7'd0;
        end
        else begin
            case(state)
                WAIT_CONV4: begin
                    if(calculate_begin) begin
                        if(conv_5_ready) begin
                            if(ram_write_addr < pingpong_size - 1) begin
                                ram_write_addr <= ram_write_addr + 7'd1;
                            end
                            else begin
                                ram_write_addr <= 7'd0;
                            end
                        end
                    end
                end
                GO_ON: begin
                    if(calculate_begin) begin
                        if(conv_5_ready) begin
                            if(ram_write_addr < pingpong_size - 1) begin
                                ram_write_addr <= ram_write_addr + 7'd1;
                            end
                            else begin
                                ram_write_addr <= 7'd0;
                            end
                        end
                    end
                end
                default: begin
                    ram_write_addr <= 7'd0;
                end
            endcase
        end
    end
endmodule