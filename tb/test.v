`timescale 1ns / 1ns
module test();
    reg clk;
    reg rst;
    reg [23:0] data;
    wire [127:0] out;

    GarbageSortTop GarbageSortTop(
        .clk(clk),
        .rst(rst),
        .d_in(data),
        .conv_start(1'b1),
        .pool_out(out)
    );

    initial begin
        clk <= 1'b0;
        rst <= 1'b1;
        data <= 24'd0;
        forever begin
            #5 clk <= 1'b1;
            #5 clk <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if(!rst) begin
            data <= 24'd0;
        end
        else begin
            case(data)
                24'd0: begin
                    data <= 24'd1;
                end
                24'd1: begin
                    data <= 24'd2;
                end
                24'd2: begin
                    data <= 24'd3;
                end
                24'd3: begin
                    data <= 24'd0;
                end
                default: begin
                    data <= 24'd0;
                end
            endcase
        end
    end

endmodule