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
    output wire [215:0] win,
    
    output reg [11:0] hcount,
    output reg [DATA_WIDTH-1:0] data_rd_1,
    output reg [DATA_WIDTH-1:0] data_rd_2,
    
    
    /*
     * Control
     */
    input wire [3:0]            sw
);

wire enable;

reg mode;


// 2 adresses for 2 row buffers
//reg [10:0] addrw1;
//reg [10:0] addrw2;



//reg [11:0] hcount;


// 3 output pix for 3 row buffers

wire [DATA_WIDTH-1:0] ram_pix1;
wire [DATA_WIDTH-1:0] ram_pix2;


//data in  addr
reg [DATA_WIDTH-1:0] dina;

reg wea1; 
wire wea2; 


reg [7:0] gaussian [2:0][2:0];
reg [23:0] window [8:0];


wire [7:0] red;
wire [7:0] blu;
wire [7:0] gre;
reg [7:0] tred;
reg [7:0] tblu;
reg [7:0] tgre;
reg [9:0] re;
reg [9:0] bl;
reg [9:0] gr;

    // new
reg [9:0] Y;
reg [9:0] U;
reg [9:0] V;
    // new
reg [9:0] grey;


initial begin
    wea1 <= 1;
    mode <= 0;
//    wea2 <= 0;
////    gaussian[0][0] = 1; gaussian[0][1] = 2; gaussian[0][2] = 1;
////    gaussian[1][0] = 1; gaussian[1][1] = 4; gaussian[1][2] = 1;
////    gaussian[2][0] = 1; gaussian[2][1] = 2; gaussian[2][2] = 1;
end

assign {red, blu, gre} = i_vid_data;
assign win =   {window[0], window[1], window[2],
                window[3], window[4], window[5],
                window[6], window[7], window[8]};
                
//assign wea2 = !wea1;
// new
// random constant values
wire [5:0] brightness; 
reg [9:0] vcount;
wire line_end = (hcount == 2200); 
wire frame_end = (vcount == 931); 
// new

always @ (posedge clk) begin
    if(!n_rst) begin
        o_vid_hsync <= 0;
        o_vid_vsync <= 0; 
        o_vid_VDE <= 0;
        o_vid_data <= 0;
        hcount <= 0;
        vcount <= 0;
    end
    else begin
        o_vid_hsync <= i_vid_hsync;
        o_vid_vsync <= i_vid_vsync; 
        o_vid_VDE <= i_vid_VDE;
        // new
        // curr_x
        if (hcount >= 2200) begin
            hcount <= 0;
            mode <= !mode;
            wea1 <= !wea1;
        end else
            hcount <= hcount + 1;
            
        // cur_y 
        if (frame_end) 
            vcount <= 0;
        else if (line_end) 
            vcount <= vcount + 1; 
        // new
        if (!mode) begin
            data_rd_1 <= ram_pix1;
            data_rd_2 <= ram_pix2;
        end
        else begin
            data_rd_1 <= ram_pix2;
            data_rd_2 <= ram_pix1;
        end
        
        //changing row representation of row buffer
        
        
        
        
        //window to apply kernel to
        
        window[0] <= window[1];
        window[1] <= window[2];
        window[2] <= data_rd_1;
    
        window[3] <= window[4];
        window[4] <= window[5];
        window[5] <= data_rd_2;
        
        window[6] <= window[7];
        window[7] <= window[8];
        window[8] <= i_vid_data;
        
        

        case(sw)
            4'b0001:
                o_vid_data <= {blu, red, gre};
            4'b0010:
                o_vid_data <= {8'b11111111-red, 8'b11111111-blu, 8'b11111111-gre};
            4'b0011:
            begin
                re <= {2'd0,red};
                bl <= {2'd0,blu};
                gr <= {2'd0,gre};
                grey <= (re+bl+gr)>>3;
                o_vid_data <= {grey[7:0], grey[7:0], grey[7:0]};
            end
            // brightness increase new
            4'b1000: 
            begin
//                re <= {red + brightness > 255 ? 255 : red + brightness};
//                bl <= {blu + brightness > 255 ? 255 : blu + brightness};
//                gr <= {gre + brightness > 255 ? 255 : gre + brightness}; 
                re <= (red * 70 / 100 > 255 ? 255 : red * 70 / 100);
                bl <= (blu *  70 / 100 > 255 ? 255 : blu *  70 / 100);
                gr <= (gre * 70 / 100 > 255 ? 255 : gre * 70 / 100); 
                o_vid_data <= {re,bl,gr};
            end
            // brightness increase
            4'b1010: 
            begin 
                re <= (red + brightness > 255 ? 255 : red + brightness);
                bl <= (blu + brightness > 255 ? 255 : blu + brightness);
                gr <= (gre + brightness > 255 ? 255 : gre + brightness); 
                o_vid_data <= {re,bl,gr};
            end
            // RGB to YUV conversion
            4'b1100:
            begin 
                re <= (299 * red + 587 * gre + 114 * blu) / 1000;
                bl <= (439 * (blu - re) + 128) / 256;
                gr <= (439 * (red - re) + 128) / 256;
                o_vid_data <= {re ,bl,gr};
            end
            // YUV test
            4'b1110:
            begin 
                re <= (299 * red + 587 * gre + 114 * blu) / 1000;
                bl <= (439 * (blu - re) + 128) / 256;
                gr <= (439 * (red - re) + 128) / 256;
                o_vid_data <= {re *255,bl *255,gr * 255};
            end
            // YUV test
            4'b1111:
            begin 
                re <= (299 * red + 587 * gre + 114 * blu) / 1000;
                bl <= (439 * (blu - re) + 128) / 256;
                gr <= (439 * (red - re) + 128) / 256;
                Y  <= re + ((359 * gr) / 256);
                U  <= re - ((88 * bl) / 256) - ((183 * gr) / 256);
                V  <= re + ((454 * bl) / 256);
                o_vid_data <= {Y,U,V};
            end 
            // drawing a sprite
            4'b1001: 
            begin 
                if ((hcount >= 300) && (hcount <= 500) && (vcount >= 50) && (vcount <= 100))
                    o_vid_data <= {red,red,red};
                else 
                    o_vid_data <= {red,blu,gre};
            end
            //
            4'b0100:
            begin
                tgre <= window[0][7:0]/9 + window[1][7:0]/9 + window[2][7:0]/9 + 
                        window[3][7:0]/9 + window[4][7:0]/9 + window[5][7:0]/9 + 
                        window[6][7:0]/9 + window[7][7:0]/9 + window[8][7:0]/9;
                
                tblu <= window[0][15:8]/9 + window[1][15:8]/9 + window[2][15:8]/9 +
                        window[3][15:8]/9 + window[4][15:8]/9 + window[5][15:8]/9 +
                        window[6][15:8]/9 + window[7][15:8]/9 + window[8][15:8]/9;
                
                tred <= window[0][23:16]/9 + window[1][23:16]/9 + window[2][23:16]/9 + 
                        window[3][23:16]/9 + window[4][23:16]/9 + window[5][23:16]/9 + 
                        window[6][23:16]/9 + window[7][23:16]/9 + window[8][23:16]/9;
                        
                 o_vid_data <= {tred, tblu, tgre};
            end
            4'b0101:
            begin
                tgre <= window[0][7:0] - window[2][7:0] + 
                        window[3][7:0]*2 - window[5][7:0]*2 + 
                        window[6][7:0] - window[8][7:0];
                
                tblu <= window[0][15:8] - window[2][15:8] +
                        window[3][15:8]*2 - window[5][15:8]*2 +
                        window[6][15:8] - window[8][15:8];
                
                tred <= window[0][23:16] - window[2][23:16] + 
                        window[3][23:16]*2 - window[5][23:16]*2 + 
                        window[6][23:16] - window[8][23:16];
                        
                        
                        
                o_vid_data <= {tred>>3, tblu>>3, tgre>>3};
            end
            4'b0110:
            begin
                tgre <= window[4][7:0];
                
                tblu <= window[4][15:8];
                
                tred <= window[4][23:16];
                
                 o_vid_data <= {tred, tblu, tgre};
            end
            
            4'b0111:
            begin
                tgre <= window[6][7:0] - window[8][7:0];
                
                tblu <= window[6][15:8] - window[8][15:8];
                
                tred <= window[6][23:16] - window[8][23:16];
                        
                        
                        
                o_vid_data <= {tred>>1, tblu>>1, tgre>>1};
            end
            
            default:
                o_vid_data <= i_vid_data;
        endcase

        

    end
end

blk_mem_gen_0 inst0(
        .clka(clk),
        .clkb(clk),
        .wea(wea1),
        .addra(hcount),
        .dina(i_vid_data),
        .addrb(hcount+2),
        .doutb(ram_pix1)
);
blk_mem_gen_1 inst1(
        .clka(clk),
        .clkb(clk),
        .wea(!wea1),
        .addra(hcount),
        .dina(i_vid_data),
        .addrb(hcount+2),
        .doutb(ram_pix2)
);

// new
randomiser random_inst(
        .clk(clk),
        .n_rst(n_rst),
        .brightness(brightness)
); 


endmodule
