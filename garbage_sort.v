module GarbageSortTop (
    input clk,
    input rst,
    input [23:0] d_in,
    input conv_start,
    output reg [127:0] pool_out
);

    // ��1�����ʹ���ź�?
    wire image_input_ready;
    // ��1�����?8��������
    wire [63:0] layer_1_conv_tmp;
    // ��1����������Ч�ź�
    wire conv_1_ready;
    // ��1�������������ź�
    wire conv_1_complete;
    // ��2�������ʼ�ź�?
    wire layer_1_input_ready;
    // ��2�����д���?
    wire [6:0] conv_2_ram_write_addr;
    // ��2��������
    wire [7:0] layer_2_conv_tmp [15:0];
    // ��2����������Ч�ź�
    wire conv_2_ready;
    // ��2�������������ź�
    wire conv_2_complete;
    // ��2�����ram���?
    wire [7:0] layer_2_conv [15:0];
    // ��2�����ramд����ź�?
    wire conv_2_write_complete;
    // ��3��ػ���ʹ���ź�?
    wire layer_3_read_en;
    // ��3��ػ������?
    wire [6:0] layer_3_read_addr;
    // ��3��ػ���ʼ�ź�?
    wire layer_3_relu_begin;
    // ��3��ػ����
    wire [7:0] layer_3_max_tmp [15:0];
    // ��3��ػ������Ч�ź�
    wire relu_3_ready;
    // ��3��ػ�����ź�
    wire relu_3_complete;

    // ����ȷ����1�����ʲôʱ���?
    ImageInput ImageInput(.clk(clk), .rst(rst), .conv_start(conv_start), .image_input_ready(image_input_ready));

    // ��1�����?
    genvar j;
    generate
        for(j = 0; j < 8; j = j + 1)
        begin: g0
            // �����ź���
            if(j == 0) begin
                Conv1 Conv1(.clk(clk), .rst(rst), .d_in(d_in), .conv_start(conv_start), .image_input_ready(image_input_ready),
                    .d_out(layer_1_conv_tmp[8 * (j + 1) - 1:8 * j]), .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete));
            end
            else begin
                Conv1 Conv1(.clk(clk), .rst(rst), .d_in(d_in), .conv_start(conv_start), .image_input_ready(image_input_ready),
                    .d_out(layer_1_conv_tmp[8 * (j + 1) - 1:8 * j]));
            end
        end
    endgenerate

    // ����ȷ����2�����ʲôʱ���?
    Layer1Input Layer1Input(.clk(clk), .rst(rst), .conv_start(conv_start), .conv_1_ready(conv_1_ready),
        .layer_1_input_ready(layer_1_input_ready));

    // ��2�����?
    genvar i;
    generate
        for(i = 0; i < 16; i = i + 1)
        begin: g1
            // �����ź���
            if(i == 0) begin
                // ��2�����?
                Conv2 Conv2(.clk(clk), .rst(rst), .d_in(layer_1_conv_tmp), .conv_start(conv_start), .layer_1_input_ready(layer_1_input_ready),
                    .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete), .d_out(layer_2_conv_tmp[i]),
                    .ram_write_addr(conv_2_ram_write_addr), .conv_2_ready(conv_2_ready), .conv_2_complete(conv_2_complete));
                // ��2���������?
                Layer2Input Layer2Input(.clk(clk), .rst(rst), .d_in(layer_2_conv_tmp[i]), .conv_start(conv_start), .wr_en(conv_2_ready),
                    .rd_en(layer_3_read_en), .wr_addr(conv_2_ram_write_addr), .rd_addr(layer_3_read_addr), .d_out(layer_2_conv[i]),
                    .conv_2_write_complete(conv_2_write_complete), .layer_3_relu_begin(layer_3_relu_begin));
                // ��3��ػ�?
                Relu3 Relu3(.clk(clk), .rst(rst), .layer_3_relu_begin(layer_3_relu_begin), .d_in(layer_2_conv[i]), .conv_2_ready(conv_2_ready),
                    .conv_2_write_complete(conv_2_write_complete), .d_out(layer_3_max_tmp[i]), .rd_en(layer_3_read_en),
                    .layer_3_read_addr(layer_3_read_addr), .relu_3_ready(relu_3_ready), .relu_3_complete(relu_3_complete));
            end
            else begin
                Conv2 Conv2(.clk(clk), .rst(rst), .d_in(layer_1_conv_tmp), .conv_start(conv_start), .layer_1_input_ready(layer_1_input_ready),
                    .conv_1_ready(conv_1_ready), .conv_1_complete(conv_1_complete), .d_out(layer_2_conv_tmp[i]));
                Layer2Input Layer2Input(.clk(clk), .rst(rst), .d_in(layer_2_conv_tmp[i]), .conv_start(conv_start), .wr_en(conv_2_ready),
                    .rd_en(layer_3_read_en), .wr_addr(conv_2_ram_write_addr), .rd_addr(layer_3_read_addr),
                    .d_out(layer_2_conv[i]));
                Relu3 Relu3(.clk(clk), .rst(rst), .layer_3_relu_begin(layer_3_relu_begin), .d_in(layer_2_conv[i]), .conv_2_ready(conv_2_ready),
                    .conv_2_write_complete(conv_2_write_complete), .d_out(layer_3_max_tmp[i]));
            end
        end
    endgenerate

    always @(posedge clk) begin
        if(!rst) begin
            pool_out <= 128'd0;
        end
        else begin
            if(relu_3_ready) begin
                pool_out <= {layer_3_max_tmp[15], layer_3_max_tmp[14], layer_3_max_tmp[13], layer_3_max_tmp[12],
                            layer_3_max_tmp[11], layer_3_max_tmp[10], layer_3_max_tmp[9], layer_3_max_tmp[8],
                            layer_3_max_tmp[7], layer_3_max_tmp[6], layer_3_max_tmp[5], layer_3_max_tmp[4], 
                            layer_3_max_tmp[3], layer_3_max_tmp[2], layer_3_max_tmp[1], layer_3_max_tmp[0]};
            end
            else begin
                pool_out <= 128'd0;
            end
        end
    end

endmodule