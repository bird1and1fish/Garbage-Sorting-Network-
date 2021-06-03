module Mult8(
    input clk,
    input rst,
    input [7:0] d_in_a,
    input [7:0] d_in_b,
    input start,
    output reg [15:0] d_out
);

    always @(posedge clk) begin
        if(!rst) begin
            d_out <= 16'd0;
        end
        else begin
            if(start) begin
                d_out <= d_in_a * d_in_b;
            end
            else begin
                d_out <= d_out;
            end
        end
    end

endmodule