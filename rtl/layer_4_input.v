module Layer4Input(
    input clk,
    input rst,
    input conv_start,
    input conv_4_ready,
    output layer_4_input_ready
);

    // 内置状态机，确保程序可重复执行，conv_4_ready信号置1时表明第四层卷积输出有效
    reg layer_4_input_complete = 1'b0;
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
                    if(layer_4_input_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    // 输入图像大小为10x10x32，卷积核大小为3x3x32
    parameter img_size = 10'd100;
    parameter convolution_size = 7'd30;
    parameter kernel_size = 2'd3;
    reg [9:0] pix_count = 10'd0;

    always @(posedge clk) begin
        if(!rst) begin
            pix_count <= 10'd0;
            layer_4_input_complete <= 1'b0;
        end
        else begin
            case(state)
                VACANT: begin
                    pix_count <= 10'd0;
                    layer_4_input_complete <= 1'b0;
                end
                BUSY: begin
                    if(conv_4_ready) begin
                        if(pix_count < img_size - 10'd1) begin
                            pix_count <= pix_count + 10'd1;
                        end
                        else begin
                            layer_4_input_complete <= 1'b1;
                        end
                    end
                end
                default: begin
                    pix_count <= 10'd0;
                    layer_4_input_complete <= 1'b0;
                end
            endcase
        end
    end

    // 考虑到conv_5.v中对layer_4_input_ready信号在状态机中相当于打了一拍，这里减去1'b1
    assign layer_4_input_ready = pix_count >= convolution_size + kernel_size - 1'b1;

endmodule