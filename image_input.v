module ImageInput(
    input clk,
    input rst,
    input conv_start,
    output image_input_ready
);

    // 内置状态机，确保程序可重复执行，conv_start信号过一个时钟周期后开始输入图像
    reg image_input_complete = 1'b0;
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
                    if(image_input_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    // 输入图像大小为28x28x3，卷积核大小为3x3x3
    parameter img_size = 10'd784;
    parameter convolution_size = 7'd84;
    parameter kernel_size = 2'd3;
    reg [9:0] pix_count = 10'd0;

    always @(posedge clk) begin
        if(!rst) begin
            pix_count <= 10'd0;
            image_input_complete <= 1'b0;
        end
        else begin
            case(state)
                VACANT: begin
                    pix_count <= 10'd0;
                    image_input_complete <= 1'b0;
                end
                BUSY: begin
                    if(pix_count < img_size + convolution_size) begin
                        pix_count <= pix_count + 10'd1;
                    end
                    else begin
                        image_input_complete <= 1'b1;
                    end
                end
                default: begin
                    pix_count <= 10'd0;
                    image_input_complete <= 1'b0;
                end
            endcase
        end
    end

    assign image_input_ready = pix_count >= convolution_size + kernel_size;

endmodule