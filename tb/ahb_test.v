`timescale 1ns / 1ns
module ahb_test();
    reg clk;
    reg rst;
    reg conv_start = 1'b1;
    reg [9:0] count;
    wire [15:0] out;

    ahb_cnn ahb_cnn(
        .hclk(clk),
        .hrst(rst),
        .cnn_en(conv_start),
        .cnn_res(out)
    );

    initial begin
        clk <= 1'b0;
        rst <= 1'b1;
        conv_start <= 1'b1;
        count <= 10'd0;
        forever begin
            #5 clk <= 1'b1;
            #5 clk <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if(!rst) begin
            conv_start <= 1'b0;
        end
        else begin
            if(count < 10'd100) begin
                count <= count + 10'd1;
            end
            else begin
                conv_start <= 1'b0;
            end
        end
    end

endmodule