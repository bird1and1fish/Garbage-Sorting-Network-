module Relu3(
    input clk,
    input rst,
    input layer_3_relu_begin,
    input [7:0] d_in,
    input conv_2_ready,
    input conv_2_write_complete,
    output reg [7:0] d_out,
    output reg rd_en = 1'b0,
    output reg [6:0] layer_3_read_addr = 7'd0,
    output reg relu_3_ready = 1'b0,
    output relu_3_complete
);

    // ����״̬����ȷ��������ظ�ִ��
    parameter
        VACANT = 3'd0,
        WAIT_CONV2 = 3'd1,
        GO_ON = 3'd2;
    reg [2:0] state = 3'd0;
    always @(posedge clk) begin
        if(!rst) begin
            state <= VACANT;
        end
        else begin
            case(state)
                VACANT: begin
                    if(layer_3_relu_begin) begin
                        state <= WAIT_CONV2;
                    end
                end
                WAIT_CONV2: begin
                    if(conv_2_write_complete) begin
                        state <= GO_ON;
                    end
                end
                GO_ON: begin
                    if(relu_3_complete) begin
                        state <= VACANT;
                    end
                end
                default: begin
                    state <= VACANT;
                end
            endcase
        end
    end

    // ���ڶ�������д������ö�ʹ��
    always @(posedge clk) begin
        if(!rst) begin
            rd_en <= 1'b0;
        end
        else begin
            case(state)
                VACANT: begin
                    rd_en <= 1'b0;
                end
                WAIT_CONV2: begin
                    if(conv_2_ready) begin
                        rd_en <= 1'b1;
                    end
                end
                GO_ON: begin
                    rd_en <= 1'b1;
                end
                default: begin
                    rd_en <= 1'b0;
                end
            endcase
            // if(layer_3_relu_begin) begin
            //     if(!relu_3_complete) begin
            //         rd_en <= 1'b1;
            //     end
            //     else begin
            //         rd_en <= 1'b0;
            //     end
            // end
            // else begin
            //     rd_en <= 1'b0;
            // end
        end
    end

    // ���ö���ַ�Լ��������ػ�
    parameter pool_stride = 2'd2;
    parameter  input_raw = 6'd24;
    parameter 
        POOL_ONE = 3'd0,
        POOL_TWO = 3'd1,
        POOL_THREE = 3'd2,
        POOL_FOUR = 3'd3;
    // �ػ�����˴�С
    parameter pool_size = 3'd4;
    reg [2:0] pool_count = POOL_TWO;
    // �ػ�������׵�ַ
    reg [6:0] head_addr = 7'd0;
    parameter input_raw_div = 4'd12;
    // �ػ������׵�ַ��һ���еĸı����
    reg [3:0] head_addr_jump_count = 4'd0;
    parameter input_line_div = 4'd12;
    // �ػ������׵�ַ�ı������
    reg [3:0] line_count = 4'd0;
    always @(posedge clk) begin
        if(!rst) begin
            layer_3_read_addr <= 7'd0;
            d_out <= 8'd0;
            pool_count <= POOL_TWO;
            head_addr <= 7'd0;
            head_addr_jump_count <= 4'd0;
            relu_3_ready <= 1'b0;
            line_count <= 4'd0;
        end
        else begin
            case(state)
                VACANT: begin
                    layer_3_read_addr <= 7'd0;
                    d_out <= 8'd0;
                    pool_count <= POOL_TWO;
                    head_addr <= 7'd0;
                    head_addr_jump_count <= 4'd0;
                    relu_3_ready <= 1'b0;
                    line_count <= 4'd0;
                end
                WAIT_CONV2: begin
                    if(conv_2_ready) begin
                        pool_count <= pool_count < pool_size - 1? pool_count + 3'd1:POOL_ONE;
                        // ���ݳػ�����˴�С������ͼ���������ram��ַ
                        case(pool_count)
                            POOL_ONE: begin
                                layer_3_read_addr <= head_addr;
                                if(d_in > d_out) begin
                                    d_out <= d_in;
                                end
                                relu_3_ready <= 1'b1;
                            end
                            POOL_TWO: begin
                                layer_3_read_addr <= head_addr + 7'd1;
                                d_out <= d_in;
                                relu_3_ready <= 1'b0;
                            end
                            POOL_THREE: begin
                                layer_3_read_addr <= head_addr + 7'd1 + input_raw;
                                if(d_in > d_out) begin
                                    d_out <= d_in;
                                end
                            end
                            POOL_FOUR: begin
                                layer_3_read_addr <= head_addr + input_raw;
                                head_addr_jump_count <= head_addr_jump_count < input_raw_div - 1? head_addr_jump_count + 4'd1:4'd0;
                                if(head_addr_jump_count < input_raw_div - 1) begin
                                    head_addr <= head_addr + pool_stride;
                                end
                                else begin
                                    head_addr <= head_addr == input_raw - pool_stride? input_raw << 1:0;
                                    if(line_count < input_line_div) begin
                                        line_count <= line_count + 4'd1;
                                    end
                                end
                                if(d_in > d_out) begin
                                    d_out <= d_in;
                                end
                            end
                            default: begin
                                layer_3_read_addr <= head_addr;
                            end
                        endcase
                    end
                end
                GO_ON: begin
                    pool_count <= pool_count < pool_size - 1? pool_count + 3'd1:POOL_ONE;
                    // ���ݳػ�����˴�С������ͼ���������ram��ַ
                    case(pool_count)
                        POOL_ONE: begin
                            layer_3_read_addr <= head_addr;
                            if(d_in > d_out) begin
                                d_out <= d_in;
                            end
                            relu_3_ready <= 1'b1;
                        end
                        POOL_TWO: begin
                            layer_3_read_addr <= head_addr + 7'd1;
                            d_out <= d_in;
                            relu_3_ready <= 1'b0;
                        end
                        POOL_THREE: begin
                            layer_3_read_addr <= head_addr + 7'd1 + input_raw;
                            if(d_in > d_out) begin
                                d_out <= d_in;
                            end
                        end
                        POOL_FOUR: begin
                            layer_3_read_addr <= head_addr + input_raw;
                            head_addr_jump_count <= head_addr_jump_count < input_raw_div - 1? head_addr_jump_count + 4'd1:4'd0;
                            if(head_addr_jump_count < input_raw_div - 1) begin
                                head_addr <= head_addr + pool_stride;
                            end
                            else begin
                                head_addr <= head_addr == input_raw - pool_stride? input_raw << 1:0;
                                if(line_count < input_line_div) begin
                                    line_count <= line_count + 4'd1;
                                end
                            end
                            if(d_in > d_out) begin
                                d_out <= d_in;
                            end
                        end
                        default: begin
                            layer_3_read_addr <= head_addr;
                        end
                    endcase
                end
                default: begin
                    layer_3_read_addr <= 7'd0;
                    d_out <= 8'd0;
                    pool_count <= POOL_TWO;
                    head_addr <= 7'd0;
                    head_addr_jump_count <= 4'd0;
                    relu_3_ready <= 1'b0;
                    line_count <= 4'd0;
                end
            endcase
        end
    end

    // �жϳػ����Ƿ���ɣ���ɺ󷵻�������
    assign relu_3_complete = line_count == input_line_div;

endmodule