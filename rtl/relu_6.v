module Relu6(
    input clk,
    input rst,
    input layer_6_relu_begin,
    input [7:0] d_in,
    input conv_5_ready,
    input conv_5_write_complete,
    output reg [7:0] d_out,
    output reg rd_en = 1'b0,
    output reg [6:0] layer_6_read_addr = 7'd0,
    output reg [6:0] ram_write_addr = 7'd0,
    output reg relu_6_ready = 1'b0,
    output relu_6_complete
);

    // 内置状态机，确保程序可重复执行
    parameter
        VACANT = 3'd0,
        WAIT_CONV5 = 3'd1,
        GO_ON = 3'd2;
    reg [2:0] state = 3'd0;
    always @(posedge clk) begin
        if(!rst) begin
            state <= VACANT;
        end
        else begin
            case(state)
                VACANT: begin
                    if(layer_6_relu_begin) begin
                        state <= WAIT_CONV5;
                    end
                end
                WAIT_CONV5: begin
                    if(conv_5_write_complete) begin
                        state <= GO_ON;
                    end
                end
                GO_ON: begin
                    if(relu_6_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    // 当第五层卷积层写完后，设置读使能
    always @(posedge clk) begin
        if(!rst) begin
            rd_en <= 1'b0;
        end
        else begin
            case(state)
                VACANT: begin
                    rd_en <= 1'b0;
                end
                WAIT_CONV5: begin
                    if(conv_5_ready) begin
                        rd_en <= 1'b1;
                    end
                    else begin
                        rd_en <= 1'b0;
                    end
                end
                GO_ON: begin
                    rd_en <= 1'b1;
                end
                default: begin
                    rd_en <= 1'b0;
                end
            endcase
            // if(layer_6_relu_begin) begin
            //     if(!relu_6_complete) begin
            //         rd_en <= 1'b1;
            //     end
            //     else begin
            //         rd_en <= 1'b0;
            //     end
            // end
            // else begin
            //     rd_en <= 1'b0;
            // end
        end
    end

    // 设置读地址以及计算最大池化
    parameter pool_stride = 2'd2;
    parameter  input_raw = 6'd8;
    parameter 
        POOL_ONE = 3'd0,
        POOL_TWO = 3'd1,
        POOL_THREE = 3'd2,
        POOL_FOUR = 3'd3;
    // 池化卷积核大小
    parameter pool_size = 3'd4;
    reg [2:0] pool_count = POOL_TWO;
    // 池化区域的首地址
    reg [6:0] head_addr = 7'd0;
    parameter input_raw_div = 4'd4;
    // 池化区域首地址在一行中的改变次数
    reg [3:0] head_addr_jump_count = 4'd0;
    parameter input_line_div = 4'd4;
    // 池化区域首地址改变的行数
    reg [3:0] line_count = 4'd0;
    always @(posedge clk) begin
        if(!rst) begin
            layer_6_read_addr <= 7'd0;
            d_out <= 8'd0;
            pool_count <= POOL_TWO;
            head_addr <= 7'd0;
            head_addr_jump_count <= 4'd0;
            relu_6_ready <= 1'b0;
            line_count <= 4'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    layer_6_read_addr <= 7'd0;
                    d_out <= 8'd0;
                    pool_count <= POOL_TWO;
                    head_addr <= 7'd0;
                    head_addr_jump_count <= 4'd0;
                    relu_6_ready <= 1'b0;
                    line_count <= 4'd0;
                end
                WAIT_CONV5: begin
                    if(conv_5_ready) begin
                        pool_count <= pool_count < pool_size - 1? pool_count + 3'd1:POOL_ONE;
                        // 根据池化卷积核大小和输入图像来计算读ram地址
                        case(pool_count)
                            POOL_ONE: begin
                                layer_6_read_addr <= head_addr;
                                if(d_in > d_out) begin
                                    d_out <= d_in;
                                end
                                relu_6_ready <= 1'b1;
                            end
                            POOL_TWO: begin
                                layer_6_read_addr <= head_addr + 7'd1;
                                d_out <= d_in;
                                relu_6_ready <= 1'b0;
                            end
                            POOL_THREE: begin
                                layer_6_read_addr <= head_addr + 7'd1 + input_raw;
                                if(d_in > d_out) begin
                                    d_out <= d_in;
                                end
                            end
                            POOL_FOUR: begin
                                layer_6_read_addr <= head_addr + input_raw;
                                head_addr_jump_count <= head_addr_jump_count < input_raw_div - 1? head_addr_jump_count + 4'd1:4'd0;
                                if(head_addr_jump_count < input_raw_div - 1) begin
                                    head_addr <= head_addr + pool_stride;
                                end
                                else begin
                                    head_addr <= head_addr == input_raw - pool_stride? input_raw << 1:0;
                                    if(line_count < input_line_div) begin
                                        line_count <= line_count + 4'd1;
                                    end
                                end
                                if(d_in > d_out) begin
                                    d_out <= d_in;
                                end
                            end
                            default: begin
                                layer_6_read_addr <= head_addr;
                            end
                        endcase
                    end
                    else begin
                        relu_6_ready <= 1'b0;
                    end
                end
                GO_ON: begin
                    pool_count <= pool_count < pool_size - 1? pool_count + 3'd1:POOL_ONE;
                    // 根据池化卷积核大小和输入图像来计算读ram地址
                    case(pool_count)
                        POOL_ONE: begin
                            layer_6_read_addr <= head_addr;
                            if(d_in > d_out) begin
                                d_out <= d_in;
                            end
                            relu_6_ready <= 1'b1;
                        end
                        POOL_TWO: begin
                            layer_6_read_addr <= head_addr + 7'd1;
                            d_out <= d_in;
                            relu_6_ready <= 1'b0;
                        end
                        POOL_THREE: begin
                            layer_6_read_addr <= head_addr + 7'd1 + input_raw;
                            if(d_in > d_out) begin
                                d_out <= d_in;
                            end
                        end
                        POOL_FOUR: begin
                            layer_6_read_addr <= head_addr + input_raw;
                            head_addr_jump_count <= head_addr_jump_count < input_raw_div - 1? head_addr_jump_count + 4'd1:4'd0;
                            if(head_addr_jump_count < input_raw_div - 1) begin
                                head_addr <= head_addr + pool_stride;
                            end
                            else begin
                                head_addr <= head_addr == input_raw - pool_stride? input_raw << 1:0;
                                if(line_count < input_line_div) begin
                                    line_count <= line_count + 4'd1;
                                end
                            end
                            if(d_in > d_out) begin
                                d_out <= d_in;
                            end
                        end
                        default: begin
                            layer_6_read_addr <= head_addr;
                        end
                    endcase
                end
                default: begin
                    layer_6_read_addr <= 7'd0;
                    d_out <= 8'd0;
                    pool_count <= POOL_TWO;
                    head_addr <= 7'd0;
                    head_addr_jump_count <= 4'd0;
                    relu_6_ready <= 1'b0;
                    line_count <= 4'd0;
                end
            endcase
        end
    end

    // 判断池化层是否完成，完成后返回上升沿
    assign relu_6_complete = line_count == input_line_div;

    // 设置写地址，内存大小为4x4=16
    parameter ram_size = 7'd16;
    always @(posedge clk) begin
        if(!rst) begin
            ram_write_addr <= 7'd0;
        end
        else begin
            case(state)
                WAIT_CONV5: begin
                    if(relu_6_ready) begin
                        if(ram_write_addr < ram_size - 1) begin
                            ram_write_addr <= ram_write_addr + 7'd1;
                        end
                        else begin
                            ram_write_addr <= 7'd0;
                        end
                    end
                end
                GO_ON: begin
                    if(relu_6_ready) begin
                        if(ram_write_addr < ram_size - 1) begin
                            ram_write_addr <= ram_write_addr + 7'd1;
                        end
                        else begin
                            ram_write_addr <= 7'd0;
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