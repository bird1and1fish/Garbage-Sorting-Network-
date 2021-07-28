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

    parameter Zx = 9'd129;
    parameter M = 9'd39;
    parameter Za = 9'd116;

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
    reg [31:0] sum = 32'd0;
    always @(posedge clk) begin
        if(!rst) begin
            sum <= 32'd0;
            add_count <= 10'd0;
            layer_count <= 4'd0;
            layer_7_read_addr <= 7'd0;
            full_connect_7_ready <= 1'b0;
        end
        else begin
            case(state)
                VACANT: begin
                    sum <= 32'd0;
                    add_count <= 10'd0;
                    layer_count <= 4'd0;
                    layer_7_read_addr <= 7'd0;
                    full_connect_7_ready <= 1'b0;
                end
                WAIT_LAYER6: begin
                    sum <= 32'd0;
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
                        sum <= sum + {{24{k5[add_count + 10 * layer_count][7]}}, k5[add_count + 10 * layer_count][7:0]} * ({{24{d_in[7]}}, d_in[7:0]} - Zx) + {{24{k5[add_count + 10 * layer_count][15]}}, k5[add_count + 10 * layer_count][15:8]} * ({{24{d_in[15]}}, d_in[15:8]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][23]}}, k5[add_count + 10 * layer_count][23:16]} * ({{24{d_in[23]}}, d_in[23:16]} - Zx) + {{24{k5[add_count + 10 * layer_count][31]}}, k5[add_count + 10 * layer_count][31:24]} * ({{24{d_in[31]}}, d_in[31:24]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][39]}}, k5[add_count + 10 * layer_count][39:32]} * ({{24{d_in[39]}}, d_in[39:32]} - Zx) + {{24{k5[add_count + 10 * layer_count][47]}}, k5[add_count + 10 * layer_count][47:40]} * ({{24{d_in[47]}}, d_in[47:40]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][55]}}, k5[add_count + 10 * layer_count][55:48]} * ({{24{d_in[55]}}, d_in[55:48]} - Zx) + {{24{k5[add_count + 10 * layer_count][63]}}, k5[add_count + 10 * layer_count][63:56]} * ({{24{d_in[63]}}, d_in[63:56]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][71]}}, k5[add_count + 10 * layer_count][71:64]} * ({{24{d_in[71]}}, d_in[71:64]} - Zx) + {{24{k5[add_count + 10 * layer_count][79]}}, k5[add_count + 10 * layer_count][79:72]} * ({{24{d_in[79]}}, d_in[79:72]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][87]}}, k5[add_count + 10 * layer_count][87:80]} * ({{24{d_in[87]}}, d_in[87:80]} - Zx) + {{24{k5[add_count + 10 * layer_count][95]}}, k5[add_count + 10 * layer_count][95:88]} * ({{24{d_in[95]}}, d_in[95:88]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][103]}}, k5[add_count + 10 * layer_count][103:96]} * ({{24{d_in[103]}}, d_in[103:96]} - Zx) + {{24{k5[add_count + 10 * layer_count][111]}}, k5[add_count + 10 * layer_count][111:104]} * ({{24{d_in[111]}}, d_in[111:104]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][119]}}, k5[add_count + 10 * layer_count][119:112]} * ({{24{d_in[119]}}, d_in[119:112]} - Zx) + {{24{k5[add_count + 10 * layer_count][127]}}, k5[add_count + 10 * layer_count][127:120]} * ({{24{d_in[127]}}, d_in[127:120]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][135]}}, k5[add_count + 10 * layer_count][135:128]} * ({{24{d_in[135]}}, d_in[135:128]} - Zx) + {{24{k5[add_count + 10 * layer_count][143]}}, k5[add_count + 10 * layer_count][143:136]} * ({{24{d_in[143]}}, d_in[143:136]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][151]}}, k5[add_count + 10 * layer_count][151:144]} * ({{24{d_in[151]}}, d_in[151:144]} - Zx) + {{24{k5[add_count + 10 * layer_count][159]}}, k5[add_count + 10 * layer_count][159:152]} * ({{24{d_in[159]}}, d_in[159:152]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][167]}}, k5[add_count + 10 * layer_count][167:160]} * ({{24{d_in[167]}}, d_in[167:160]} - Zx) + {{24{k5[add_count + 10 * layer_count][172]}}, k5[add_count + 10 * layer_count][175:168]} * ({{24{d_in[175]}}, d_in[175:168]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][183]}}, k5[add_count + 10 * layer_count][183:176]} * ({{24{d_in[183]}}, d_in[183:176]} - Zx) + {{24{k5[add_count + 10 * layer_count][191]}}, k5[add_count + 10 * layer_count][191:184]} * ({{24{d_in[191]}}, d_in[191:184]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][199]}}, k5[add_count + 10 * layer_count][199:192]} * ({{24{d_in[199]}}, d_in[199:192]} - Zx) + {{24{k5[add_count + 10 * layer_count][207]}}, k5[add_count + 10 * layer_count][207:200]} * ({{24{d_in[207]}}, d_in[207:200]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][215]}}, k5[add_count + 10 * layer_count][215:208]} * ({{24{d_in[215]}}, d_in[215:208]} - Zx) + {{24{k5[add_count + 10 * layer_count][223]}}, k5[add_count + 10 * layer_count][223:216]} * ({{24{d_in[223]}}, d_in[223:216]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][231]}}, k5[add_count + 10 * layer_count][231:224]} * ({{24{d_in[231]}}, d_in[231:224]} - Zx) + {{24{k5[add_count + 10 * layer_count][239]}}, k5[add_count + 10 * layer_count][239:232]} * ({{24{d_in[239]}}, d_in[239:232]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][247]}}, k5[add_count + 10 * layer_count][247:240]} * ({{24{d_in[247]}}, d_in[247:240]} - Zx) + {{24{k5[add_count + 10 * layer_count][255]}}, k5[add_count + 10 * layer_count][255:248]} * ({{24{d_in[255]}}, d_in[255:248]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][263]}}, k5[add_count + 10 * layer_count][263:256]} * ({{24{d_in[263]}}, d_in[263:256]} - Zx) + {{24{k5[add_count + 10 * layer_count][271]}}, k5[add_count + 10 * layer_count][271:264]} * ({{24{d_in[271]}}, d_in[271:264]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][279]}}, k5[add_count + 10 * layer_count][279:272]} * ({{24{d_in[279]}}, d_in[279:272]} - Zx) + {{24{k5[add_count + 10 * layer_count][287]}}, k5[add_count + 10 * layer_count][287:280]} * ({{24{d_in[287]}}, d_in[287:280]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][295]}}, k5[add_count + 10 * layer_count][295:288]} * ({{24{d_in[295]}}, d_in[295:288]} - Zx) + {{24{k5[add_count + 10 * layer_count][303]}}, k5[add_count + 10 * layer_count][303:296]} * ({{24{d_in[303]}}, d_in[303:296]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][311]}}, k5[add_count + 10 * layer_count][311:304]} * ({{24{d_in[311]}}, d_in[311:304]} - Zx) + {{24{k5[add_count + 10 * layer_count][319]}}, k5[add_count + 10 * layer_count][319:312]} * ({{24{d_in[319]}}, d_in[319:312]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][327]}}, k5[add_count + 10 * layer_count][327:320]} * ({{24{d_in[327]}}, d_in[327:320]} - Zx) + {{24{k5[add_count + 10 * layer_count][335]}}, k5[add_count + 10 * layer_count][335:328]} * ({{24{d_in[335]}}, d_in[335:328]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][343]}}, k5[add_count + 10 * layer_count][343:336]} * ({{24{d_in[343]}}, d_in[343:336]} - Zx) + {{24{k5[add_count + 10 * layer_count][351]}}, k5[add_count + 10 * layer_count][351:344]} * ({{24{d_in[351]}}, d_in[351:344]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][359]}}, k5[add_count + 10 * layer_count][359:352]} * ({{24{d_in[359]}}, d_in[359:352]} - Zx) + {{24{k5[add_count + 10 * layer_count][367]}}, k5[add_count + 10 * layer_count][367:360]} * ({{24{d_in[367]}}, d_in[367:360]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][375]}}, k5[add_count + 10 * layer_count][375:368]} * ({{24{d_in[375]}}, d_in[375:368]} - Zx) + {{24{k5[add_count + 10 * layer_count][383]}}, k5[add_count + 10 * layer_count][383:376]} * ({{24{d_in[383]}}, d_in[383:376]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][391]}}, k5[add_count + 10 * layer_count][391:384]} * ({{24{d_in[391]}}, d_in[391:384]} - Zx) + {{24{k5[add_count + 10 * layer_count][399]}}, k5[add_count + 10 * layer_count][399:392]} * ({{24{d_in[399]}}, d_in[399:392]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][407]}}, k5[add_count + 10 * layer_count][407:400]} * ({{24{d_in[407]}}, d_in[407:400]} - Zx) + {{24{k5[add_count + 10 * layer_count][415]}}, k5[add_count + 10 * layer_count][415:408]} * ({{24{d_in[415]}}, d_in[415:408]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][423]}}, k5[add_count + 10 * layer_count][423:416]} * ({{24{d_in[423]}}, d_in[423:416]} - Zx) + {{24{k5[add_count + 10 * layer_count][431]}}, k5[add_count + 10 * layer_count][431:424]} * ({{24{d_in[431]}}, d_in[431:424]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][439]}}, k5[add_count + 10 * layer_count][439:432]} * ({{24{d_in[439]}}, d_in[439:432]} - Zx) + {{24{k5[add_count + 10 * layer_count][447]}}, k5[add_count + 10 * layer_count][447:440]} * ({{24{d_in[447]}}, d_in[447:440]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][455]}}, k5[add_count + 10 * layer_count][455:448]} * ({{24{d_in[455]}}, d_in[455:448]} - Zx) + {{24{k5[add_count + 10 * layer_count][463]}}, k5[add_count + 10 * layer_count][463:456]} * ({{24{d_in[463]}}, d_in[463:456]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][471]}}, k5[add_count + 10 * layer_count][471:464]} * ({{24{d_in[471]}}, d_in[471:464]} - Zx) + {{24{k5[add_count + 10 * layer_count][479]}}, k5[add_count + 10 * layer_count][479:472]} * ({{24{d_in[479]}}, d_in[479:472]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][487]}}, k5[add_count + 10 * layer_count][487:480]} * ({{24{d_in[487]}}, d_in[487:480]} - Zx) + {{24{k5[add_count + 10 * layer_count][495]}}, k5[add_count + 10 * layer_count][495:488]} * ({{24{d_in[495]}}, d_in[495:488]} - Zx)
                            + {{24{k5[add_count + 10 * layer_count][503]}}, k5[add_count + 10 * layer_count][503:496]} * ({{24{d_in[503]}}, d_in[503:496]} - Zx) + {{24{k5[add_count + 10 * layer_count][511]}}, k5[add_count + 10 * layer_count][511:504]} * ({{24{d_in[511]}}, d_in[511:504]} - Zx);
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
                        sum <= 32'd0;
                        layer_count <= layer_count + 4'd1;
                    end
                end
                default: begin
                    sum <= 32'd0;
                    add_count <= 10'd0;
                    layer_count <= 4'd0;
                    layer_7_read_addr <= 7'd0;
                    full_connect_7_ready <= 1'b0;
                end
            endcase
        end
    end

    //assign d_out = sum[26:19];
    assign d_out = ((sum * M) >> 16) + Za;

    assign full_connect_7_complete = layer_count == layer_num;

endmodule