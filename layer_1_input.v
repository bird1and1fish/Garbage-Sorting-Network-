module Layer1Input(
    input clk,
    input rst,
    input conv_start,
    input conv_1_ready,
    output layer_1_input_ready
);

    // 内置状态机，确保程序可重复执行，conv_1_ready信号置1时表明第一层卷积输出有效
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

    // 输入图像大小为26x26x8，卷积核大小为3x3x8
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

    // 考虑到conv_2.v中对layer_1_input_ready信号在状态机中相当于打了一拍，这里减去1'b1
    assign layer_1_input_ready = pix_count >= convolution_size + kernel_size - 1'b1;

endmodule