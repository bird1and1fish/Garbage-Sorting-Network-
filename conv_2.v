module Conv2(
    input clk,
    input rst,
    input [63:0] d_in,
    input conv_start,
    input layer_1_input_ready,
    input conv_1_ready,
    input conv_1_complete,
    output reg [7:0] d_out,
    output reg [6:0] ram_write_addr = 7'd0,
    output conv_2_ready,
    output conv_2_complete
);

    // ����״̬����ȷ��������ظ�ִ�У�conv_1_ready�ź���1ʱ�����ź���Ч
    // layer_1_input_ready�ź���1ʱ��һ���ڿ�ʼ����
    // conv_1_complete��1����λ�Ĵ�����ʣ�µ��������ƶ�
    parameter 
        VACANT = 3'd0,
        CONV_START = 3'd1,
        WAIT_CONV1 = 3'd2,
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
                    if(layer_1_input_ready) begin
                        state <= WAIT_CONV1;
                    end
                end
                WAIT_CONV1: begin
                    if(conv_1_complete) begin
                        state <= GO_ON;
                    end
                end
                GO_ON: begin
                    if(conv_2_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    wire calculate_begin = (state == WAIT_CONV1 && conv_1_ready) || state == GO_ON;

    // ����ͼ���СΪ26x26x8������˴�СΪ3x3x8
    parameter img_raw = 5'd26;
    parameter img_line = 5'd26;
    parameter img_size = 10'd676;
    parameter convolution_size = 7'd78;
    parameter kernel_count = 4'd9;
    parameter kernel_size = 2'd3;

    // ��λ�Ĵ�������8������
    reg [63:0] shift_reg [convolution_size - 1:0];
    reg [6:0] i = 7'd0;
    always @(posedge clk) begin
        if(!rst) begin
            for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                shift_reg[i] <= 64'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                        shift_reg[i] <= 64'd0;
                end
                // �ȴ�conv_1_ready�ź�
                CONV_START: begin
                    if(conv_1_ready) begin
                        shift_reg[convolution_size - 1] <= d_in;
                        for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                            shift_reg[i - 1] <= shift_reg[i];
                    end
                end
                // �ȴ�conv_1_ready�ź�
                WAIT_CONV1: begin
                    if(conv_1_ready) begin
                        shift_reg[convolution_size - 1] <= d_in;
                        for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                            shift_reg[i - 1] <= shift_reg[i];
                    end
                end
                // ��һ���������ϣ�ʣ����������λ
                GO_ON: begin
                    shift_reg[convolution_size - 1] <= d_in;
                    for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                        shift_reg[i - 1] <= shift_reg[i];
                end
                default: begin
                    for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                        shift_reg[i] <= 64'd0;
                end
            endcase
        end
    end

    // ��ram�ж�ȡ3x3x8��С�����
    reg [63:0] k2 [kernel_count - 1:0];

    // ��ȡ3x3x8�������
    reg [63:0] mult_data [kernel_count - 1:0];
    reg [3:0] j = 4'd0;
    always @(posedge clk) begin
        if(!rst) begin
            for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                mult_data[j] <= 64'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                        mult_data[j] <= 64'd0;
                end
                // �ȴ�conv_1_ready�ź�
                CONV_START: begin
                    if(conv_1_ready) begin
                        mult_data[2] <= shift_reg[0];
                        mult_data[5] <= shift_reg[28];
                        mult_data[8] <= shift_reg[56];
                        for(j = 4'd0; j < kernel_size - 1; j = j + 4'd1) begin
                            mult_data[j] <= mult_data[j + 1];
                            mult_data[j + 3] <= mult_data[j + 3 + 1];
                            mult_data[j + 6] <= mult_data[j + 6 + 1];
                        end
                    end
                end
                // �ȴ�conv_1_ready�ź�
                WAIT_CONV1: begin
                    if(conv_1_ready) begin
                        mult_data[2] <= shift_reg[0];
                        mult_data[5] <= shift_reg[28];
                        mult_data[8] <= shift_reg[56];
                        for(j = 4'd0; j < kernel_size - 1; j = j + 4'd1) begin
                            mult_data[j] <= mult_data[j + 1];
                            mult_data[j + 3] <= mult_data[j + 3 + 1];
                            mult_data[j + 6] <= mult_data[j + 6 + 1];
                        end
                    end
                end
                // ��һ���������ϣ�����Ҫ�ȴ�conv_1_ready�ź�
                GO_ON: begin
                    mult_data[2] <= shift_reg[0];
                    mult_data[5] <= shift_reg[28];
                    mult_data[8] <= shift_reg[56];
                    for(j = 4'd0; j < kernel_size - 1; j = j + 4'd1) begin
                        mult_data[j] <= mult_data[j + 1];
                        mult_data[j + 3] <= mult_data[j + 3 + 1];
                        mult_data[j + 6] <= mult_data[j + 6 + 1];
                    end
                end
                default: begin
                    for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                        mult_data[j] <= 64'd0;
                end
            endcase
        end
    end

    // �˷�����
    wire [15:0] mult [8 * kernel_count - 1:0];
    genvar k;
    generate
        for(k = 0; k < kernel_count; k = k + 1)
        begin: conv1_mult
            Mult8 Mult8_1(.clk(clk), .rst(rst), .d_in_a(k2[k][63:56]), .d_in_b(mult_data[k][63:56]),
                .start(calculate_begin), .d_out(mult[k]));
            Mult8 Mult8_2(.clk(clk), .rst(rst), .d_in_a(k2[k][55:48]), .d_in_b(mult_data[k][55:48]),
                .start(calculate_begin), .d_out(mult[k + kernel_count]));
            Mult8 Mult8_3(.clk(clk), .rst(rst), .d_in_a(k2[k][47:40]), .d_in_b(mult_data[k][47:40]),
                .start(calculate_begin), .d_out(mult[k + 2 * kernel_count]));
            Mult8 Mult8_4(.clk(clk), .rst(rst), .d_in_a(k2[k][39:32]), .d_in_b(mult_data[k][39:32]),
                .start(calculate_begin), .d_out(mult[k + 3 * kernel_count]));
            Mult8 Mult8_5(.clk(clk), .rst(rst), .d_in_a(k2[k][31:24]), .d_in_b(mult_data[k][31:24]),
                .start(calculate_begin), .d_out(mult[k + 4 * kernel_count]));
            Mult8 Mult8_6(.clk(clk), .rst(rst), .d_in_a(k2[k][23:16]), .d_in_b(mult_data[k][23:16]),
                .start(calculate_begin), .d_out(mult[k + 5 * kernel_count]));
            Mult8 Mult8_7(.clk(clk), .rst(rst), .d_in_a(k2[k][15:8]), .d_in_b(mult_data[k][15:8]),
                .start(calculate_begin), .d_out(mult[k + 6 * kernel_count]));
            Mult8 Mult8_8(.clk(clk), .rst(rst), .d_in_a(k2[k][7:0]), .d_in_b(mult_data[k][7:0]),
                .start(calculate_begin), .d_out(mult[k + 7 * kernel_count]));
        end
    endgenerate

    // �ӷ�����
    reg [17:0] adder_1 = 18'd0;
    reg [17:0] adder_2 = 18'd0;
    reg [17:0] adder_3 = 18'd0;
    reg [17:0] adder_4 = 18'd0;
    reg [17:0] adder_5 = 18'd0;
    reg [17:0] adder_6 = 18'd0;
    reg [17:0] adder_7 = 18'd0;
    reg [17:0] adder_8 = 18'd0;
    reg [17:0] adder_9 = 18'd0;
    reg [17:0] adder_10 = 18'd0;
    reg [17:0] adder_11 = 18'd0;
    reg [17:0] adder_12 = 18'd0;
    reg [17:0] adder_13 = 18'd0;
    reg [17:0] adder_14 = 18'd0;
    reg [17:0] adder_15 = 18'd0;
    reg [17:0] adder_16 = 18'd0;
    reg [17:0] adder_17 = 18'd0;
    reg [17:0] adder_18 = 18'd0;
    reg [17:0] adder_19 = 18'd0;
    reg [17:0] adder_20 = 18'd0;
    reg [17:0] adder_21 = 18'd0;
    reg [17:0] adder_22 = 18'd0;
    reg [17:0] adder_23 = 18'd0;
    reg [17:0] adder_24 = 18'd0;

    reg [19:0] adder_25 = 20'd0;
    reg [19:0] adder_26 = 20'd0;
    reg [19:0] adder_27 = 20'd0;
    reg [19:0] adder_28 = 20'd0;
    reg [19:0] adder_29 = 20'd0;
    reg [19:0] adder_30 = 20'd0;
    reg [19:0] adder_31 = 20'd0;
    reg [19:0] adder_32 = 20'd0;
    
    reg [20:0] adder_33 = 21'd0;
    reg [20:0] adder_34 = 21'd0;
    reg [20:0] adder_35 = 21'd0;

    reg [22:0] adder_36 = 23'd0;

    always @(posedge clk) begin
        if(!rst) begin
            adder_1 <= 18'd0;
            adder_2 <= 18'd0;
            adder_3 <= 18'd0;
            adder_4 <= 18'd0;
            adder_5 <= 18'd0;
            adder_6 <= 18'd0;
            adder_7 <= 18'd0;
            adder_8 <= 18'd0;
            adder_9 <= 18'd0;
            adder_10 <= 18'd0;
            adder_11 <= 18'd0;
            adder_12 <= 18'd0;
            adder_13 <= 18'd0;
            adder_14 <= 18'd0;
            adder_15 <= 18'd0;
            adder_16 <= 18'd0;
            adder_17 <= 18'd0;
            adder_18 <= 18'd0;
            adder_19 <= 18'd0;
            adder_20 <= 18'd0;
            adder_21 <= 18'd0;
            adder_22 <= 18'd0;
            adder_23 <= 18'd0;
            adder_24 <= 18'd0;
            adder_25 <= 20'd0;
            adder_26 <= 20'd0;
            adder_27 <= 20'd0;
            adder_28 <= 20'd0;
            adder_29 <= 20'd0;
            adder_30 <= 20'd0;
            adder_31 <= 20'd0;
            adder_32 <= 20'd0;
            adder_33 <= 21'd0;
            adder_34 <= 21'd0;
            adder_35 <= 21'd0;
            adder_36 <= 23'd0;
            d_out <= adder_36;
        end
        else begin
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

                adder_25 <= adder_1 + adder_2 + adder_3;
                adder_26 <= adder_4 + adder_5 + adder_6;
                adder_27 <= adder_7 + adder_8 + adder_9;

                adder_28 <= adder_10 + adder_11 + adder_12;
                adder_29 <= adder_13 + adder_14 + adder_15;
                adder_30 <= adder_16 + adder_17 + adder_18;

                adder_31 <= adder_19 + adder_20 + adder_21;
                adder_32 <= adder_22 + adder_23 + adder_24;

                adder_33 <= adder_25 + adder_26 + adder_27;
                adder_34 <= adder_28 + adder_29 + adder_30;
                adder_35 <= adder_31 + adder_32;

                adder_36 <= adder_33 + adder_34 + adder_35;
                // ���ƴ��������ע����������
                // if(adder_36[14])
                //     d_out <= (adder_36 >> 15) + 8'd1;
                // else
                //     d_out <= adder_36 >> 15;
                d_out <= adder_36;
            end
            else begin
                adder_1 <= 18'd0;
                adder_2 <= 18'd0;
                adder_3 <= 18'd0;
                adder_4 <= 18'd0;
                adder_5 <= 18'd0;
                adder_6 <= 18'd0;
                adder_7 <= 18'd0;
                adder_8 <= 18'd0;
                adder_9 <= 18'd0;
                adder_10 <= 18'd0;
                adder_11 <= 18'd0;
                adder_12 <= 18'd0;
                adder_13 <= 18'd0;
                adder_14 <= 18'd0;
                adder_15 <= 18'd0;
                adder_16 <= 18'd0;
                adder_17 <= 18'd0;
                adder_18 <= 18'd0;
                adder_19 <= 18'd0;
                adder_20 <= 18'd0;
                adder_21 <= 18'd0;
                adder_22 <= 18'd0;
                adder_23 <= 18'd0;
                adder_24 <= 18'd0;
                adder_25 <= 20'd0;
                adder_26 <= 20'd0;
                adder_27 <= 20'd0;
                adder_28 <= 20'd0;
                adder_29 <= 20'd0;
                adder_30 <= 20'd0;
                adder_31 <= 20'd0;
                adder_32 <= 20'd0;
                adder_33 <= 21'd0;
                adder_34 <= 21'd0;
                adder_35 <= 21'd0;
                adder_36 <= 23'd0;
                d_out <= adder_36;
            end
        end
    end

    // �ж������Ч��image_input_ready��6�ĺ�d_out������Ч
    parameter out_ready = 3'd6;
    parameter out_end = 10'd681;// 26 x 26 + 6 - 1
    reg [9:0] out_count = 10'd0;
    reg [4:0] line_count = 5'd0;
    always @(posedge clk) begin
        if(!rst) begin
            out_count <= 10'd0;
            line_count <= 5'd0;
        end
        else begin
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
            else begin
                out_count <= 10'd0;
                line_count <= 5'd0;
            end
        end
    end
    assign conv_2_ready = ((out_count >= out_ready) && (out_count <= out_ready + img_raw - kernel_size)) && (line_count < img_line -kernel_size + 1'b1);

    assign conv_2_complete = line_count == img_line - kernel_size + 1'b1;

    // ����д��ַ��ƹ�һ����СΪ4x24
    parameter pingpong_size = 7'd96;
    always @(posedge clk) begin
        if(!rst) begin
            ram_write_addr <= 7'd0;
        end
        else begin
            if(calculate_begin) begin
                if(conv_2_ready) begin
                    if(ram_write_addr < pingpong_size - 1) begin
                        ram_write_addr <= ram_write_addr + 7'd1;
                    end
                    else begin
                        ram_write_addr <= 7'd0;
                    end
                end
            end
            else begin
                ram_write_addr <= 7'd0;
            end
        end
    end

endmodule