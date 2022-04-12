module Layer2Input(
    input clk,
    input rst,
    input [7:0] d_in,
    input conv_start,
    input wr_en,
    input rd_en,
    input [6:0] wr_addr,
    input [6:0] rd_addr,
    output wire [7:0] d_out,
    output reg conv_2_write_complete = 1'b0,
    output reg layer_3_relu_begin = 1'b0
);

    // 内置状态机
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
                    if(conv_2_write_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    // 定义第二卷积层输出缓存大小，由于池化卷积核是2x2，只需要构造一个4x24大小的乒乓缓存
    parameter left_ram_size = 6'd48;
    parameter layer_2_output_num = 10'd576;
    reg [9:0] wr_count = 10'd0;

    Conv2Ram Conv2Ram(
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_addr(wr_addr),
        .rd_addr(rd_addr),
        .d_in(d_in),
        .d_out(d_out)
    );

    always @(posedge clk) begin
        if(!rst) begin
            conv_2_write_complete <= 1'b0;
            layer_3_relu_begin <= 1'b0;
            wr_count <= 10'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    conv_2_write_complete <= 1'b0;
                    layer_3_relu_begin <= 1'b0;
                    wr_count <= 10'd0;
                end
                BUSY: begin
                    if(wr_en) begin
                        if(wr_count == left_ram_size - 1) begin
                            layer_3_relu_begin <= 1'b1;
                        end
                        if(wr_count < layer_2_output_num - 1) begin
                            wr_count <= wr_count + 10'd1;
                        end
                        else begin
                            conv_2_write_complete <= 1'b1;
                        end
                    end
                end
                default: begin
                    conv_2_write_complete <= 1'b0;
                    layer_3_relu_begin <= 1'b0;
                    wr_count <= 10'd0;
                end
            endcase
        end
    end

endmodule