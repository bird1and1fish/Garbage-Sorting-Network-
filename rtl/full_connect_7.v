module FullConnect7 # (
    parameter FULLCONNECT7_HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/data/fullconnect7.hex"
) (
    input clk,
    input rst,
    input [511:0] d_in,
    input conv_start,
    input relu_6_write_complete,
    output [7:0] d_out,
    output reg rd_en = 1'b0,
    output reg [6:0] layer_7_read_addr = 7'd0,
    output reg full_connect_7_ready,
    output full_connect_7_complete
);

    parameter qb = 8'd0;
    parameter Zx = 8'd0;
    parameter M = 8'd1;
    parameter Za = 8'd0;

    // 内置状态机，确保程序可重复执行，conv_start信号过一个时钟周期后开始输入图像
    // 设置WAIT_RAM状态是因为从设置addr到d_in需要等一拍
    parameter 
        VACANT = 3'd0,
        WAIT_LAYER6 = 3'd1,
        WAIT_RAM = 3'd2,
        BUSY = 3'd3;
    reg [2:0] state = 3'd0;
    always @(posedge clk) begin
        if(!rst) begin
            state <= VACANT;
            rd_en <= 1'b0;
        end
        else begin
            case(state)
                VACANT: begin
                    if(conv_start) begin
                        state <= WAIT_LAYER6;
                        rd_en <= 1'b0;
                    end
                end
                WAIT_LAYER6: begin
                    rd_en <= 1'b0;
                    if(relu_6_write_complete) begin
                        state <= WAIT_RAM;
                        rd_en <= 1'b1;
                    end
                end
                WAIT_RAM: begin
                    state <= BUSY;
                end
                BUSY: begin
                    rd_en <= 1'b1;
                    if(full_connect_7_complete) begin
                        state <= VACANT;
                        rd_en <= 1'b0;
                    end
                end
                default: begin
                    state <= VACANT;
                    rd_en <= 1'b0;
                end
            endcase
        end
    end

    // 从ram中读取4x4x64x10大小卷积核
    parameter ram_size = 5'd16;
    reg [511:0] k5 [0:10 * ram_size - 1];
    initial begin
        (*rom_style = "block"*) $readmemh(FULLCONNECT7_HEX_FILE_PATH, k5);
    end

    // 开始计算卷积
    parameter layer_num = 4'd10;
    
    reg [9:0] add_count = 10'd0;
    reg [3:0] layer_count = 4'd0;
    reg [26:0] sum = 27'd0;
    always @(posedge clk) begin
        if(!rst) begin
            sum <= 27'd0;
            add_count <= 10'd0;
            layer_count <= 4'd0;
            layer_7_read_addr <= 7'd0;
            full_connect_7_ready <= 1'b0;
        end
        else begin
            case(state)
                VACANT: begin
                    sum <= 27'd0;
                    add_count <= 10'd0;
                    layer_count <= 4'd0;
                    layer_7_read_addr <= 7'd0;
                    full_connect_7_ready <= 1'b0;
                end
                WAIT_LAYER6: begin
                    sum <= 27'd0;
                    add_count <= 10'd0;
                    layer_count <= 4'd0;
                    layer_7_read_addr <= 7'd0;
                    full_connect_7_ready <= 1'b0;
                end
                WAIT_RAM: begin
                    layer_7_read_addr <= layer_7_read_addr < (ram_size - 1'b1)? layer_7_read_addr + 7'd1:7'd0;
                end
                BUSY: begin
                    if(add_count < ram_size) begin
                        sum <= sum + k5[add_count + 10 * layer_count][7:0] * (d_in[7:0] -Zx) + k5[add_count + 10 * layer_count][15:8] * (d_in[15:8] - Zx)
                            + k5[add_count + 10 * layer_count][23:16] * (d_in[23:16] -Zx) + k5[add_count + 10 * layer_count][31:24] * (d_in[31:24] -Zx)
                            + k5[add_count + 10 * layer_count][39:32] * (d_in[39:32] -Zx) + k5[add_count + 10 * layer_count][47:40] * (d_in[47:40] -Zx)
                            + k5[add_count + 10 * layer_count][55:48] * (d_in[55:48] -Zx) + k5[add_count + 10 * layer_count][63:56] * (d_in[63:56] -Zx)
                            + k5[add_count + 10 * layer_count][71:64] * (d_in[71:64] -Zx) + k5[add_count + 10 * layer_count][79:72] * (d_in[79:72] -Zx)
                            + k5[add_count + 10 * layer_count][87:80] * (d_in[87:80] -Zx) + k5[add_count + 10 * layer_count][95:88] * (d_in[95:88] -Zx)
                            + k5[add_count + 10 * layer_count][103:96] * (d_in[103:96] -Zx) + k5[add_count + 10 * layer_count][111:104] * (d_in[111:104] -Zx)
                            + k5[add_count + 10 * layer_count][119:112] * (d_in[119:112] - Zx) + k5[add_count + 10 * layer_count][127:120] * (d_in[127:120] - Zx)
                            + k5[add_count + 10 * layer_count][135:128] * (d_in[135:128] - Zx) + k5[add_count + 10 * layer_count][143:136] * (d_in[143:136] - Zx)
                            + k5[add_count + 10 * layer_count][151:144] * (d_in[151:144] - Zx) + k5[add_count + 10 * layer_count][159:152] * (d_in[159:152] - Zx)
                            + k5[add_count + 10 * layer_count][167:160] * (d_in[167:160] - Zx) + k5[add_count + 10 * layer_count][175:168] * (d_in[175:168] - Zx)
                            + k5[add_count + 10 * layer_count][183:176] * (d_in[183:176] - Zx) + k5[add_count + 10 * layer_count][191:184] * (d_in[191:184] - Zx)
                            + k5[add_count + 10 * layer_count][199:192] * (d_in[199:192] - Zx) + k5[add_count + 10 * layer_count][207:200] * (d_in[207:200] - Zx)
                            + k5[add_count + 10 * layer_count][215:208] * (d_in[215:208] - Zx) + k5[add_count + 10 * layer_count][223:216] * (d_in[223:216] - Zx)
                            + k5[add_count + 10 * layer_count][231:224] * (d_in[231:224] - Zx) + k5[add_count + 10 * layer_count][239:232] * (d_in[239:232] - Zx)
                            + k5[add_count + 10 * layer_count][247:240] * (d_in[247:240] - Zx) + k5[add_count + 10 * layer_count][255:248] * (d_in[255:248] - Zx)
                            + k5[add_count + 10 * layer_count][263:256] * (d_in[263:256] - Zx) + k5[add_count + 10 * layer_count][271:264] * (d_in[271:264] - Zx)
                            + k5[add_count + 10 * layer_count][279:272] * (d_in[279:272] - Zx) + k5[add_count + 10 * layer_count][287:280] * (d_in[287:280] - Zx)
                            + k5[add_count + 10 * layer_count][295:288] * (d_in[295:288] - Zx) + k5[add_count + 10 * layer_count][303:296] * (d_in[303:296] - Zx)
                            + k5[add_count + 10 * layer_count][311:304] * (d_in[311:304] - Zx) + k5[add_count + 10 * layer_count][319:312] * (d_in[319:312] - Zx)
                            + k5[add_count + 10 * layer_count][327:320] * (d_in[327:320] - Zx) + k5[add_count + 10 * layer_count][335:328] * (d_in[335:328] - Zx)
                            + k5[add_count + 10 * layer_count][343:336] * (d_in[343:336] - Zx) + k5[add_count + 10 * layer_count][351:344] * (d_in[351:344] - Zx)
                            + k5[add_count + 10 * layer_count][359:352] * (d_in[359:352] - Zx) + k5[add_count + 10 * layer_count][367:360] * (d_in[367:360] - Zx)
                            + k5[add_count + 10 * layer_count][375:368] * (d_in[375:368] - Zx) + k5[add_count + 10 * layer_count][383:376] * (d_in[383:376] - Zx)
                            + k5[add_count + 10 * layer_count][391:384] * (d_in[391:384] - Zx) + k5[add_count + 10 * layer_count][399:392] * (d_in[399:392] - Zx)
                            + k5[add_count + 10 * layer_count][407:400] * (d_in[407:400] - Zx) + k5[add_count + 10 * layer_count][415:408] * (d_in[415:408] - Zx)
                            + k5[add_count + 10 * layer_count][423:416] * (d_in[423:416] - Zx) + k5[add_count + 10 * layer_count][431:424] * (d_in[431:424] - Zx)
                            + k5[add_count + 10 * layer_count][439:432] * (d_in[439:432] - Zx) + k5[add_count + 10 * layer_count][447:440] * (d_in[447:440] - Zx)
                            + k5[add_count + 10 * layer_count][455:448] * (d_in[455:448] - Zx) + k5[add_count + 10 * layer_count][463:456] * (d_in[463:456] - Zx)
                            + k5[add_count + 10 * layer_count][471:464] * (d_in[471:464] - Zx) + k5[add_count + 10 * layer_count][479:472] * (d_in[479:472] - Zx)
                            + k5[add_count + 10 * layer_count][487:480] * (d_in[487:480] - Zx) + k5[add_count + 10 * layer_count][495:488] * (d_in[495:488] - Zx)
                            + k5[add_count + 10 * layer_count][503:496] * (d_in[503:496] - Zx) + k5[add_count + 10 * layer_count][511:504] * (d_in[511:504] - Zx);
                        add_count <= add_count + 7'd1;
                        layer_7_read_addr <= layer_7_read_addr < (ram_size - 1'b1)? layer_7_read_addr + 7'd1:7'd0;
                        if(add_count == ram_size - 5'd1) begin
                            full_connect_7_ready <= 1'b1;
                        end
                        else begin
                            full_connect_7_ready <= 1'b0;
                        end
                    end
                    else begin
                        add_count <= 7'd0;
                        full_connect_7_ready <= 1'b0;
                        sum <= 27'd0;
                        layer_count <= layer_count + 4'd1;
                    end
                end
                default: begin
                    sum <= 27'd0;
                    add_count <= 10'd0;
                    layer_count <= 4'd0;
                    layer_7_read_addr <= 7'd0;
                    full_connect_7_ready <= 1'b0;
                end
            endcase
        end
    end

    //assign d_out = sum[26:19];
    assign d_out = (((sum[7:0] + qb) * M) >> 0) + Za;

    assign full_connect_7_complete = layer_count == layer_num;

endmodule