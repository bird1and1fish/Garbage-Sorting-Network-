module ahb_cnn # (
    parameter HEX_FILE_PATH = "D:/Quartus/ConvolutionNet/Garbage-Sorting-Network-/img/mem.hex"
)   (

    input   hsel,
    input   hclk,
    input   hrst,

    input   [31:0]  haddr,
    input   [1:0]   htrans,
    input   [2:0]   hsize,
    input           hwrite,
    input   [31:0]  hwdata,

    output  reg [31:0]  hrdata,
    output              hready,

    input               cnn_en,
    output  [15:0]  cnn_res
    
);

    // Always Ready
    assign hready = 1'b1;

    // Memory Array
    reg [31:0]  memory[0:783];

    // Registers to store Adress Phase Signals
    reg [31:0]  hwdata_mask;
    reg         we;
    reg [31:0]  hwaddr_buf;

    initial begin
        (*ram_style = "block"*) $readmemh(HEX_FILE_PATH, memory);
    end

    // Sample the Address Phase   
    always @(posedge hclk or negedge hrst) begin
        if (~hrst) begin
            we <= 1'b0;
            hwaddr_buf <= 32'h0;
        end
        else begin
            we <= hsel & hwrite & htrans[1];
            hwaddr_buf <= haddr;

            // casez (hsize[1:0])
            //     2'b1?: hwdata_mask <=  32'hFFFFFFFF;                        // Word write
            //     2'b01: hwdata_mask <= (32'h0000FFFF << (16 * haddr[1]));    // Halfword write
            //     2'b00: hwdata_mask <= (32'h000000FF << (8 * haddr[1:0]));   // Byte write
            // endcase
        end
    end

    reg [31:0] memory_buf;
    wire [9:0] pixel_idx;

    // Read and Write Memory
    always @ (posedge hclk) begin
        if (we)
            memory[hwaddr_buf[11:2]] <= hwdata;
        // if (we)
        //     memory[hwaddr_buf[16:2]] <= (hwdata & hwdata_mask) | (hrdata & ~hwdata_mask);
        // hrdata <= memory[haddr[16:2]];
        memory_buf <= memory[ pixel_idx ];
    end

    wire [7:0] r = (memory_buf[15:11]*128)>>5+127;
    wire [7:0] g = (memory_buf[10:5]*128)>>6+127;
    wire [7:0] b = (memory_buf[4:0]*128)>>5+127;
    
    wire [23:0] d_in = {r,g,b};
    wire [7:0] net_out;
    wire net_complete;

    assign cnn_res = {7'b0, net_complete, net_out};

    GarbageSortTop GarbageSortTop(.clk(hclk), .rst(hrst), .d_in(d_in), .conv_start(cnn_en), .read_addr(pixel_idx), .net_out(net_out), .net_complete(net_complete));

endmodule
