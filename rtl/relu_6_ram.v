module Relu6Ram(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    input [6:0] wr_addr,
    input [6:0] rd_addr,
    input [511:0] d_in,
    output reg [511:0] d_out
);

    // 定义4x4=16大小的ram
    parameter layer_6_output_num = 7'd16;
    reg [511:0] layer_6_bram [layer_6_output_num - 1:0];
    reg [6:0] i;

    always @(posedge clk) begin
        if(!rst) begin
            d_out <= 512'b0;
            for(i = 0; i < layer_6_output_num; i = i + 7'd1)
                layer_6_bram[i] <= 512'd0;
        end
        else begin
            if(wr_en) begin
                layer_6_bram[wr_addr] <= d_in;
            end
            if(rd_en) begin
                d_out <= layer_6_bram[rd_addr];
            end
        end
    end

endmodule