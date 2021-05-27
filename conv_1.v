module Conv1(
    input clk,
    input rst,
    input [23:0] d_in,
    input conv_start,
    input image_input_ready,
    output reg [7:0] d_out,
    output conv_1_ready,
    output conv_1_complete
);

    // ����״̬����ȷ��������ظ�ִ�У�conv_start�źŹ�һ��ʱ�����ں�ʼ����ͼ��
    parameter 
        VACANT = 3'd0,
        BUSY = 3'd1;
    reg [2:0] state = 3'd0;
    always @(posedge clk) begin
        if(!rst) begin
            state <= VACANT;
        end
        else begin
            case(state)
                VACANT: begin
                    if(conv_start) begin
                        state <= BUSY;
                    end
                end
                BUSY: begin
                    if(conv_1_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    wire calculate_begin = image_input_ready && state == BUSY;

    // ����ͼ���СΪ28x28x3������˴�СΪ3x3x3
    parameter img_raw = 5'd28;
    parameter img_line = 5'd28;
    parameter img_size = 10'd784;
    parameter convolution_size = 7'd84;
    parameter kernel_count = 4'd9;
    parameter kernel_size = 2'd3;

    // ��λ�Ĵ�������3������
    reg [23:0] shift_reg [convolution_size - 1:0];
    reg [6:0] i = 7'd0;
    always @(posedge clk) begin
        if(!rst) begin
            for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                shift_reg[i] <= 24'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                        shift_reg[i] <= 24'd0;
                end
                BUSY: begin
                    shift_reg[convolution_size - 1] <= d_in;
                    for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                        shift_reg[i - 1] <= shift_reg[i];
                end
                default: begin
                    for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                        shift_reg[i] <= 24'd0;
                end
            endcase
        end
    end

    // ��ram�ж�ȡ3x3x3��С�����
    reg [23:0] k1 [kernel_count - 1:0];

    // ��ȡ3x3x3�������
    reg [23:0] mult_data [kernel_count - 1:0];
    reg [3:0] j = 4'd0;
    always @(posedge clk) begin
        if(!rst) begin
            for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                mult_data[j] <= 24'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                        mult_data[j] <= 24'd0;
                end
                BUSY: begin
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
                        mult_data[j] <= 24'd0;
                end
            endcase
        end
    end

    // �˷�����
    wire [15:0] mult [3 * kernel_count - 1:0];
    genvar k;
    generate
        for(k = 0; k < kernel_count; k = k + 1)
        begin: conv1_mult
            Mult8 Mult8_r(.clk(clk), .rst(rst), .d_in_a(k1[k][23:16]), .d_in_b(mult_data[k][23:16]),
                .start(calculate_begin), .d_out(mult[k]));
            Mult8 Mult8_g(.clk(clk), .rst(rst), .d_in_a(k1[k][15:8]), .d_in_b(mult_data[k][15:8]),
                .start(calculate_begin), .d_out(mult[k + kernel_count]));
            Mult8 Mult8_b(.clk(clk), .rst(rst), .d_in_a(k1[k][7:0]), .d_in_b(mult_data[k][7:0]),
                .start(calculate_begin), .d_out(mult[k + 2 * kernel_count]));
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
    reg [19:0] adder_10 = 20'd0;
    reg [19:0] adder_11 = 20'd0;
    reg [19:0] adder_12 = 20'd0;
    reg [20:0] adder_13 = 21'd0;
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
            adder_10 <= 20'd0;
            adder_11 <= 20'd0;
            adder_12 <= 20'd0;
            adder_13 <= 21'd0;
            d_out <= 8'd0;
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

                adder_10 <= adder_1 + adder_2 + adder_3;
                adder_11 <= adder_4 + adder_5 + adder_6;
                adder_12 <= adder_7 + adder_8 + adder_9;

                adder_13 <= adder_10 + adder_11 + adder_12;
                // ���ƴ��������ע����������
                // if(adder_13[12])
                //     d_out <= (adder_13 >> 13) + 8'd1;
                // else
                //     d_out <= adder_13 >> 13;
                d_out <= adder_13;
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
                adder_10 <= 20'd0;
                adder_11 <= 20'd0;
                adder_12 <= 20'd0;
                adder_13 <= 21'd0;
                d_out <= 8'd0;
            end
        end
    end

    // �ж������Ч��image_input_ready��5�ĺ�d_out������Ч
    parameter out_ready = 3'd5;
    parameter out_end = 10'd680;// 26 x 26 + 5 - 1
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
    assign conv_1_ready = ((out_count >= out_ready) && (out_count <= out_ready + img_raw - kernel_size)) && (line_count < img_line -kernel_size + 1'b1);

    assign conv_1_complete = line_count == img_line - kernel_size + 1'b1;

endmodule