module Layer1Input(
    input clk,
    input rst,
    input conv_start,
    input conv_1_ready,
    output layer_1_input_ready
);

    // ����״̬����ȷ��������ظ�ִ�У�conv_1_ready�ź���1ʱ������һ���������Ч
    reg layer_1_input_complete = 1'b0;
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
                    if(layer_1_input_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    // ����ͼ���СΪ26x26x8������˴�СΪ3x3x8
    parameter img_size = 10'd676;
    parameter convolution_size = 7'd78;
    parameter kernel_size = 2'd3;
    reg [9:0] pix_count = 10'd0;

    always @(posedge clk) begin
        if(!rst) begin
            pix_count <= 10'd0;
            layer_1_input_complete <= 1'b0;
        end
        else begin
            case(state)
                VACANT: begin
                    pix_count <= 10'd0;
                    layer_1_input_complete <= 1'b0;
                end
                BUSY: begin
                    if(conv_1_ready) begin
                        if(pix_count < img_size - 10'd1) begin
                            pix_count <= pix_count + 10'd1;
                        end
                        else begin
                            layer_1_input_complete <= 1'b1;
                        end
                    end
                end
                default: begin
                    pix_count <= 10'd0;
                    layer_1_input_complete <= 1'b0;
                end
            endcase
        end
    end

    // ���ǵ�conv_2.v�ж�layer_1_input_ready�ź���״̬�����൱�ڴ���һ�ģ������ȥ1'b1
    assign layer_1_input_ready = pix_count >= convolution_size + kernel_size - 1'b1;

endmodule