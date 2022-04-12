module Layer6Input(
    input clk,
    input rst,
    input [511:0] d_in,
    input conv_start,
    input wr_en,
    input rd_en,
    input [6:0] wr_addr,
    input [6:0] rd_addr,
    output wire [511:0] d_out,
    output reg relu_6_write_complete = 1'b0
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
                    if(relu_6_write_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    // 第六层池化输出个数为4x4=16
    parameter layer_6_output_num = 10'd16;
    reg [9:0] wr_count = 10'd0;

    Relu6Ram Relu6Ram(
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
            relu_6_write_complete <= 1'b0;
            wr_count <= 10'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    relu_6_write_complete <= 1'b0;
                    wr_count <= 10'd0;
                end
                BUSY: begin
                    if(wr_en) begin
                        if(wr_count < layer_6_output_num - 1) begin
                            wr_count <= wr_count + 10'd1;
                        end
                        else begin
                            relu_6_write_complete <= 1'b1;
                        end
                    end
                end
                default: begin
                    relu_6_write_complete <= 1'b0;
                    wr_count <= 10'd0;
                end
            endcase
        end
    end

endmodule