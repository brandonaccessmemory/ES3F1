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
    input  wire                   clk5x,
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

reg [2:0] mode;


// 3 adresses for 3 row buffers
reg [10:0] addr1;
reg [10:0] addr2;
reg [10:0] addr3;

reg [10:0] hcount;
reg [10:0] vcount;

// 3 output pix for 3 row buffers
wire [DATA_WIDTH-1:0] ram_pix1;
wire [DATA_WIDTH-1:0] ram_pix2;
wire [DATA_WIDTH-1:0] ram_pix3;

//data in  addr
reg [DATA_WIDTH-1:0] dina;

wire wea1; 
wire wea2; 
wire wea3; 

reg [7:0] gaussian [2:0][2:0];

wire [7:0] red;
wire [7:0] blu;
wire [7:0] gre;
reg [9:0] re;
reg [9:0] bl;
reg [9:0] gr;
reg [9:0] grey;

initial begin
//    gaussian[0][0] = 1; gaussian[0][1] = 2; gaussian[0][2] = 1;
//    gaussian[1][0] = 1; gaussian[1][1] = 4; gaussian[1][2] = 1;
//    gaussian[2][0] = 1; gaussian[2][1] = 2; gaussian[2][2] = 1;
    mode <= 3'd0;
end

assign {red, blu, gre} = i_vid_data;

always @(posedge clk5x) begin
//    if(!n_rst) begin
//        o_vid_hsync <= 0;
//        o_vid_vsync <= 0; 
//        o_vid_VDE <= 0;
//        o_vid_data <= 0;
//        hcount <= 0;
//        vcount <= 0;
//    end
    case(mode)
        3'd0: if(1) begin
            mode <=3'd1; 
        end
           
        3'd1: if(1) begin
            mode <=3'd2;
        end
            
        3'd2: if(1) begin
            mode <=3'd3;
        end
        
        3'd3: if(1) begin
            mode <=3'd4;
        end
           
        3'd4: if(1) begin
//            if(!n_rst) begin
//                o_vid_hsync <= 0;
//                o_vid_vsync <= 0; 
//                o_vid_VDE <= 0;
//                o_vid_data <= 0;
//                hcount <= 0;
//                vcount <= 0;
//            end
//            else begin
//                o_vid_hsync <= i_vid_hsync;
//                o_vid_vsync <= i_vid_vsync; 
//                o_vid_VDE <= i_vid_VDE;
        
//                case(sw)
//                    4'b0001:
//                        o_vid_data <= {blu, red, gre};
//                    4'b0010:
//                        o_vid_data <= {8'b11111111-red, 8'b11111111-blu, 8'b11111111-gre};
//                    4'b1001:
//                    begin
//                        re <= {2'd0,red};
//                        bl <= {2'd0,blu};
//                        gr <= {2'd0,gre};
//                        grey <= (re+bl+gr)/8'd3;
//                        o_vid_data <= {grey[7:0], grey[7:0], grey[7:0]};
//                    end
        
                        
//                    default:
//                        o_vid_data <= i_vid_data;
//                endcase
//            end
            
            mode <=3'd0;
        end
           
           
    endcase
//    clk_count <= clk_count + 1'b1;
end

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
//        $display("hsync %d", o_vid_hsync);
//        $display("vsync %d", o_vid_vsync);
//        $display("vde %d", o_vid_VDE);
//        o_vid_data <= {blu, red, gre};
        case(sw)
            4'b0001:
                o_vid_data <= {blu, red, gre};
            4'b0011:
                o_vid_data <= {8'b11111111-red, 8'b11111111-blu, 8'b11111111-gre};
            4'b0010:
            begin
                re <= {2'd0,red};
                bl <= {2'd0,blu};
                gr <= {2'd0,gre};
                grey <= (re+bl+gr)/8'd3;
                o_vid_data <= {grey[7:0], grey[7:0], grey[7:0]};
            end
//            4'b0100:
//            begin
                
            
            
//                o_vid_data <= i_vid_data;
//            end
                
            default:
                o_vid_data <= i_vid_data;
        endcase

        

    end
end

blk_mem_gen_0 inst0(
    .clka(clk),
    .wea(wea1),
    .addra(addr1),
    .dina(dina),
    .douta(ram_pix1)
);

blk_mem_gen_1 inst1(
    .clka(clk),
    .wea(wea2),
    .addra(addr2),
    .dina(dina),
    .douta(ram_pix2)
);

blk_mem_gen_2 inst2(
    .clka(clk),
    .wea(wea3),
    .addra(addr3),
    .dina(dina),
    .douta(ram_pix3)
);
endmodule