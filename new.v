`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Alex Bucknall
// 
// Create Date: 19.02.2019 15:33:35
// Design Name: pcam-5c-zybo
// Module Name: colour_change
// Project Name: pcam-5c-zybo
// Target Devices: Zybo Z7 20
// Tool Versions: Vivado 2017.4
// Description: RBG Colour Changing Module (vid_io)
// 
// Dependencies: N/A
// 
// Revision: 0.01
// Revision 0.01 - File Created
// Additional Comments: N/A
// 
//////////////////////////////////////////////////////////////////////////////////


module colour_change #
(
    parameter DATA_WIDTH = 24 // 8 bits for R, G & B
    
)
(
    input  wire                   clk,
    input  wire                   n_rst,

    /*
     * Pixel inputs
     */
    input  wire [DATA_WIDTH-1:0] i_vid_data,
    input  wire                  i_vid_hsync,
    input  wire                  i_vid_vsync,
    input  wire                  i_vid_VDE,

    /*
     * Pixel output
     */
    output reg [DATA_WIDTH-1:0] o_vid_data,
    output reg                  o_vid_hsync,
    output reg                  o_vid_vsync,
    output reg                  o_vid_VDE,
    
    /*
     * Control
     */
    input wire [3:0]            sw
);

wire enable;

// 3 adresses for 3 row buffers
reg [10:0] addr_wr_1;
reg [10:0] addr_wr_2;
reg [10:0] addr_wr_3;
//reg [10:0] addr_rd_1;
//reg [10:0] addr_rd_2;
//reg [10:0] addr_rd_3;

// 3 output pix for 3 row buffers
wire [DATA_WIDTH-1:0] data_rd_1;
wire [DATA_WIDTH-1:0] data_rd_2;
wire [DATA_WIDTH-1:0] data_rd_3;

//data in addr for buffers
reg [DATA_WIDTH-1:0] data_wr_1;
reg [DATA_WIDTH-1:0] data_wr_2;
reg [DATA_WIDTH-1:0] data_wr_3;

// write enables 
wire wea1; 
wire wea2; 
wire wea3; 

// wires for RGB values 
wire [7:0] red;
wire [7:0] blu;
wire [7:0] gre;
reg [9:0] re;
reg [9:0] bl;
reg [9:0] gr;
reg [9:0] grey;

// kernel
reg [23:0] kernel[8:0];
reg [23:0] kernel_output;
// counter to determine which buffer to overwrite  
integer counter;

// hsync set to 1 to denote drawing a new row 
// vsync set to 1 denote drawing a new frame 
initial begin 
    counter = 0;
end 

assign {red, blu, gre} = i_vid_data;

// obtain kernel
// 2200 for one row above, 4400 for one row above 
//always @ (posedge clk) begin 
//    kernel[0] <= kernel[1];
//    kernel[1] <= kernel[2];
//    reading from the buffer 
//    kernel[2] <= bram_out;

//    kernel[3] <= kernel[4];
//    kernel[4] <= kernel[5];
//    kernel[5] <= bram_out_2;
    
//    kernel[6] <= kernel[7];
//    kernel[7] <= kernel[8];
//    kernel[8] <= i_data;
//    blurring , implement switches for different operations
//    kernel_output <= kernel[0]/9 + kernel[1]/9 + kernel[2]/9 + kernel[3]/9 + kernel[4]/9 + kernel[5]/9 + kernel[6]/9 + kernel[7]/9 + kernel[8]/9;
//end
always @ (posedge clk) begin
    if(!n_rst) begin
        o_vid_hsync <= 0;
        o_vid_vsync <= 0; 
        o_vid_VDE <= 0;
        o_vid_data <= 0;
        addr_wr_1 <= 0;
        addr_wr_2 <= 0;
        addr_wr_3 <= 0;
        data_wr_1 <= 0; 
        data_wr_2 <= 0; 
        data_wr_3 <= 0; 
    end
    else begin
        // delay sync and vde signals 
        if (counter > 4044) begin
            o_vid_hsync <= i_vid_hsync;
            o_vid_vsync <= i_vid_vsync; 
            o_vid_VDE <= i_vid_VDE;
            
            // loop from the start 
            if (addr_wr_1 >= 1919) 
                addr_wr_1 <= 0; 
            if (addr_wr_2 >= 1919) 
                addr_wr_2 <= 0; 
            if (addr_wr_3 >= 1919)
                addr_wr_3 <= 0; 
           
            
            // calculate cur_pixel value
            // order of 1,2,3 / 2,3,1 / 3,1,2 
            // request the read
            addr_wr_1 <= addr_wr_1 + 1;
            o_vid_data <= data_rd_1; 
            // buffer next row of data simultaneously 
            
// single pixel operations 
//            case(sw)
//            4'b0001:
//                o_vid_data <= {blu, red, gre};
//            4'b0011:
//                // grayscale image
//                o_vid_data <= {8'b11111111-red, 8'b11111111-blu, 8'b11111111-gre};
//            4'b0010:
//            begin
//                re <= {2'd0,red};
//                bl <= {2'd0,blu};
//                gr <= {2'd0,gre};
//                grey <= (re+bl+gr)/8'd3;
//                o_vid_data <= {grey[7:0], grey[7:0], grey[7:0]};
//            end
//            default:
//                o_vid_data <= i_vid_data;
//            endcase
        // buffer first two rows 
        end else begin 
            // write to buffer 
            data_wr_1 <= i_vid_data;
            addr_wr_1 <= addr_wr_1 + 1;
            // first and last pixel is black
//            if (i_vid_hsync == 1920) begin 
//                addr1 <= addr1 + 1; 
//                addr2 <= addr2 + 1; 
//                addr3 <= addr3 + 1; 
//                dina1 <= 0;
//                dina2 <= 0;
//                dina3 <= 0;
//            end
//            // data in is all 0 for first row
//            if (i_vid_hsync == 1) begin 
//                addr1 <= addr1 + 1;
//                dina2 <= i_vid_VDE; 
//                addr2 <= addr2 + 1;
//            end else begin 
//                dina3 <= i_vid_VDE; 
//                addr3 <= addr3 + 1; 
//            end
            counter <= counter + 1; 
        end 
    end
end

// port A for write operations, port B for read operations
blk_mem_gen_0 inst0(
    .clka(clk), 
    .wea(wea1),
    .addra(addr_wr_1),
    .dina(data_wr_1),
    .clkb(clk),
    .addrb(addr_wr_1 + 2),
    .doutb(data_rd_1)
);

//blk_mem_gen_0 inst0(
//    .clka(clk), 
//    .wea(wea1),
//    .addra(addr1),
//    .dina(dina1),
//    .douta(ram_pix1)
//);

blk_mem_gen_1 inst1(
    .clka(clk), 
    .wea(wea1),
    .addra(addr_wr_2),
    .dina(data_wr_2),
    .clkb(clk),
    .addrb(addr_wr_2 + 2),
    .doutb(data_rd_2)
);

blk_mem_gen_2 inst2(
    .clka(clk), 
    .wea(wea1),
    .addra(addr_wr_3),
    .dina(data_wr_3),
    .clkb(clk),
    .addrb(addr_wr_3 + 3),
    .doutb(data_rd_3)
);


endmodule
