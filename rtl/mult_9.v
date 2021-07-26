module Mult9(
    input clk,
    input rst,
    input [7:0] d_in_a,
    input [8:0] d_in_b,
    input start,
    output [31:0] d_out
);
    reg [16:0] mult;

    always @(posedge clk) begin
        if(!rst) begin
            mult <= 17'd0;
        end
        else begin
            if(start) begin
                mult <= {{9{d_in_a[7]}}, d_in_a} * {{8{d_in_b[8]}}, d_in_b};
            end
            else begin
                mult <= mult;
            end
        end
    end

    assign d_out = {{15{mult[16]}}, mult};

endmodule