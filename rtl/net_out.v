module NetOut(
    input clk,
    input rst,
    input conv_start,
    input [7:0] layer_7_out,
    input full_connect_7_ready,
    input full_connect_7_complete,
    output [7:0] net_out
);

    // 内置状态机，确保程序可重复执行，conv_start信号过一个时钟周期后开始输入图像
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
                    if(full_connect_7_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    // 通过10个值判断输出
    parameter class_num = 4'd10;
    reg [7:0] out_temp = 8'd0;
    reg [7:0] max_index = 8'd0;
    reg [3:0] class_count = 4'd0;
    always @(posedge clk) begin
        if(!rst) begin
            out_temp <= 8'd0;
            max_index <= 8'd0;
            class_count <= 4'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    out_temp <= 8'd0;
                    max_index <= 8'd0;
                    class_count <= 4'd0;
                end
                BUSY: begin
                    if(full_connect_7_ready) begin
                        if(layer_7_out > out_temp) begin
                            out_temp <= layer_7_out;
                            max_index <= class_count;
                        end
                        if(class_count < class_num) begin
                            class_count <= class_count + 4'd1;
                        end
                    end
                end
                default: begin
                    out_temp <= 8'd0;
                    max_index <= 8'd0;
                    class_count <= 4'd0;
                end
            endcase
        end
    end

    // 输出垃圾的类别
    assign net_out = class_count == class_num? max_index + 8'd1:8'd0;

endmodule