module Conv5Ram(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    input [6:0] wr_addr,
    input [6:0] rd_addr,
    input [7:0] d_in,
    output reg [7:0] d_out
);

    // 定义第二卷积层输出缓存大小，由于池化卷积核是2x2，只需要构造一个4x8大小的乒乓缓存
    parameter layer_2_output_num = 7'd32;
    reg [7:0] layer_2_bram [layer_2_output_num - 1:0];
    reg [6:0] i;

    always @(posedge clk) begin
        if(!rst) begin
            d_out <= 8'b0;
            for(i = 0; i < layer_2_output_num; i = i + 7'd1)
                layer_2_bram[i] <= 8'd0;
        end
        else begin
            if(wr_en) begin
                layer_2_bram[wr_addr] <= d_in;
            end
            if(rd_en) begin
                d_out <= layer_2_bram[rd_addr];
            end
        end
    end

endmodule