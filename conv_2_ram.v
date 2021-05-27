module Conv2Ram(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    input [6:0] wr_addr,
    input [6:0] rd_addr,
    input [7:0] d_in,
    output reg [7:0] d_out
);

    // �����һ�������������С�����ڳػ��������2x2��ֻ��Ҫ����һ��4x24��С��ƹ�һ���
    parameter layer_2_output_num = 7'd96;
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
            else begin
                d_out <= 8'b0;
            end
        end
    end

endmodule