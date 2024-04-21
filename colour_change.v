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
    output wire [DATA_WIDTH-1:0] ram_pix1,
    output wire [DATA_WIDTH-1:0] ram_pix2,
    
    
    /*
     * Control
     */
    input wire [3:0]            sw,
    input wire [3:0]            btn
);

wire enable;

reg mode;


//data in  addr
reg [DATA_WIDTH-1:0] dina;

reg wea1; 
wire wea2; 


reg [7:0] gaussian [2:0][2:0];
reg [23:0] window [8:0];


wire [7:0] red;
wire [7:0] blu;
wire [7:0] gre;

reg [10:0] tred;
reg [10:0] tblu;
reg [10:0] tgre;

reg [9:0] re;
reg [9:0] bl;
reg [9:0] gr;
reg [9:0] grey;

reg button_prev_1;
reg button_prev_2;

wire [5:0] brightness; 
reg [10:0] vcount;

reg [9:0] Y;
reg [9:0] U;
reg [9:0] V;

wire line_end = (hcount == 2199); 
wire frame_end = (vcount == 1125); 

reg[6:0] brightness_factor; 


initial begin
    wea1 <= 1;
    mode <= 0;

end

assign {red, blu, gre} = i_vid_data;
assign win =   {window[0], window[1], window[2],
                window[3], window[4], window[5],
                window[6], window[7], window[8]};
                
//assign wea2 = !wea1;



always @ (posedge clk) begin
    if(!n_rst) begin
        o_vid_hsync <= 0;
        o_vid_vsync <= 0; 
        o_vid_VDE <= 0;
        o_vid_data <= 0;
        hcount <= 0;
        vcount <= 0;
        brightness_factor <= 100;

    end
    else begin
        o_vid_hsync <= i_vid_hsync;
        o_vid_vsync <= i_vid_vsync; 
        o_vid_VDE <= i_vid_VDE;
        
        
        if (hcount >= 2199) begin
            hcount <= 0;
           
        // curr_x
        end else
            hcount <= hcount + 1;
        
        // cur_y 
        if (frame_end) 
            vcount <= 0;
        else if (line_end) 
            vcount <= vcount + 1; 
            
        
        //window to apply kernel to
        
        //top row shift reg with row buff 2 input
        window[0] <= window[1];
        window[1] <= window[2];
        window[2] <= ram_pix2;
        
        //middle row shift reg with row buff 1 input
        window[3] <= window[4];
        window[4] <= window[5];
        window[5] <= ram_pix1;
        
        //bottom row shift reg with vid in data input
        window[6] <= window[7];
        window[7] <= window[8];
        window[8] <= i_vid_data;
        
        

        case(sw)
            4'b0001: // blue red swap
                o_vid_data <= {blu, red, gre};
            
            4'b0010: // negative
                o_vid_data <= {8'b11111111-red, 8'b11111111-blu, 8'b11111111-gre};
            
            4'b0011: // greyscale
            begin
                re <= {2'd0,red};
                bl <= {2'd0,blu};
                gr <= {2'd0,gre};
                grey <= (re+bl+gr)/3;
                o_vid_data <= {grey[7:0], grey[7:0], grey[7:0]};
            end
            
            4'b0100: // 3x3 blur
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
                        
                 o_vid_data <= {tred[7:0], tblu[7:0], tgre[7:0]};
            end
            
            4'b0101: //vert sobel gy
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
                        
                re <= (tred>255) ? 255:tred>>2;
                bl <= (tblu>255) ? 255:tblu>>2;
                gr <= (tgre>255) ? 255:tgre>>2;
                o_vid_data <= {re[7:0], bl[7:0], gr[7:0]};
            end
            
            4'b0110: // normal draw using centre pix for testing
            begin
                tgre <= window[4][7:0];
                
                tblu <= window[4][15:8];
                
                tred <= window[4][23:16];
                
                 o_vid_data <= {tred[7:0], tblu[7:0], tgre[7:0]};
            end
            
            4'b0111: // horisontal sobel gy
            begin
                tgre <= (window[0][7:0] + 2*window[1][7:0] + window[2][7:0] 
                       - window[6][7:0] - 2*window[7][7:0] - window[8][7:0]);
                
                tblu <= (window[0][15:8] + 2*window[1][15:8] + window[2][15:8]
                       - window[6][15:8] - 2*window[7][15:8] - window[8][15:8]);
                
                tred <= (window[0][23:16] + 2*window[1][23:16] + window[2][23:16]  
                       - window[6][23:16] - 2*window[7][23:16] - window[8][23:16]);
                        
                re <= (tred>255) ? 255:tred>>2;
                bl <= (tblu>255) ? 255:tblu>>2;
                gr <= (tgre>255) ? 255:tgre>>2;
                o_vid_data <= {re[7:0], bl[7:0], gr[7:0]};

            end
            
            4'b1000: // normal draw using first pix for testing
            begin
                tgre <= window[1][7:0];
                
                tblu <= window[1][15:8];
                
                tred <= window[1][23:16];
                
                 o_vid_data <= {tred[7:0], tblu[7:0], tgre[7:0]};
            end
            
            4'b1001: // laplacian
            begin
                tgre <=                  window[1][7:0]                  + 
                        window[3][7:0] - 4*window[4][7:0] + window[5][7:0] + 
                                         window[7][7:0]                   ;
                
                tblu <=                  window[1][15:8]                  + 
                        window[3][15:8] - 4*window[4][15:8] + window[5][15:8] + 
                                         window[7][15:8]                   ;
                
                tred <=                  window[1][23:16]                  + 
                        window[3][23:16] - 4*window[4][23:16] + window[5][23:16] + 
                                         window[7][23:16]                   ;
                        
                re <= (tred>255) ? 255:tred>>2;
                bl <= (tblu>255) ? 255:tblu>>2;
                gr <= (tgre>255) ? 255:tgre>>2;
                o_vid_data <= {re[7:0], bl[7:0], gr[7:0]};
            end
            
            // 4 way split

            4'b1010: 
            begin 
                // bottom right
                if ((vcount >= 562) && (hcount >= 1100)) 
                   o_vid_data <= i_vid_data;
                // bottom left 
                if ((vcount >= 562) && (hcount <= 1100)) 
                   o_vid_data <= {blu,gre,blu};
                // top right 
                if ((vcount <= 562) && (hcount >= 1100)) 
                   o_vid_data <= {red,gre,red};
                // top left
                if ((vcount <= 562) && (hcount <= 1100)) 
                   o_vid_data <= {red,gre,blu};
            end
            
            // vary brightness
            4'b1011: 
            begin
                button_prev_1 <= btn[1];
                button_prev_2 <= btn[2];
                // brightness reset
                if (btn[0]) 
                    brightness_factor <= 100;
                                    // decrease brightness, high when button_prev is low and btn is high 
                else if (!button_prev_1 && btn[1]) begin
                    brightness_factor <= brightness_factor - 5; 
                    // min limit for brightness
                    if (brightness_factor <= 10)
                        brightness_factor <= 10;
                    
                // increase brightness
                end else if (!button_prev_2 && btn[2]) begin 
                    brightness_factor <= brightness_factor + 5;
                    // max limit for brightness 
                    if (brightness_factor >= 200) 
                        brightness_factor <= 200; 
                end
                    
                tred <= (red * brightness_factor / 100 > 255 ? 255 : red * brightness_factor / 100);
                tblu <= (blu * brightness_factor / 100 > 255 ? 255 : blu * brightness_factor / 100);
                tgre <= (gre * brightness_factor / 100 > 255 ? 255 : gre * brightness_factor / 100); 
                o_vid_data <= {tred[7:0],tblu[7:0],tgre[7:0]};
            end
            
//            // YUV 
//            4'b1100:
//            begin 
//                tred <= (299 * red + 587 * gre + 114 * blu) / 1000;
//                tblu <= (439 * (blu - tred) + 128) / 256;
//                tgre <= (439 * (red - tred) + 128) / 256;
//                Y  <= tred[7:0] + ((359 * tgre[7:0]) / 256);
//                U  <= tred - ((88 * tblu[7:0]) / 256) - ((183 * tgre[7:0]) / 256);
//                V  <= tred + ((454 * tblu[7:0]) / 256);
//                o_vid_data <= {Y,U,V};

//            end 
            
            
            4'b1100: 
            begin 
                tred <= (red + brightness > 255 ? 255 : red + brightness);
                tblu <= (blu + brightness > 255 ? 255 : blu + brightness);
                tgre <= (gre + brightness > 255 ? 255 : gre + brightness); 
                o_vid_data <= {tred[7:0],tblu[7:0],tgre[7:0]};
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
        .wea(wea1),
        .addra(hcount),
        .dina(ram_pix1),
        .addrb(hcount+2),
        .doutb(ram_pix2)
);

randomiser random_inst(
        .clk(clk),
        .n_rst(n_rst),
        .brightness(brightness)
); 

endmodule
