`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.04.2024 16:18:19
// Design Name: 
// Module Name: randomiser
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module randomiser(
    input clk,
    input n_rst,
    input [23:0] window_0,
  input [3:0] sw, 
input [23:0] window_0,
input [23:0] window_0,
    output reg [23:0]kernel_output
    );

    reg[7:0] tgre, tblue, tred;
 always@(posedge clk) begin 
    if(!n_rst) begin 
        kernel_output <= 0;
    end else begin 
        case(sw)
            4'b0100:
            begin
                tgre <= window_0[7:0]/9 + window_1[7:0]/9 + window[2][7:0]/9 + 
                        window[3][7:0]/9 + window[4][7:0]/9 + window[5][7:0]/9 + 
                        window[6][7:0]/9 + window[7][7:0]/9 + window[8][7:0]/9;
                
                tblu <= window[0][15:8]/9 + window[1][15:8]/9 + window[2][15:8]/9 +
                        window[3][15:8]/9 + window[4][15:8]/9 + window[5][15:8]/9 +
                        window[6][15:8]/9 + window[7][15:8]/9 + window[8][15:8]/9;
                
                tred <= window[0][23:16]/9 + window[1][23:16]/9 + window[2][23:16]/9 + 
                        window[3][23:16]/9 + window[4][23:16]/9 + window[5][23:16]/9 + 
                        window[6][23:16]/9 + window[7][23:16]/9 + window[8][23:16]/9;
                        
                kernel_output <= {tred,tblu,tgre};
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
                        
                        
                        
                kernel_output <= {tred>>3, tblu>>3, tgre>>3};
            end
            4'b0110:
            begin
                tgre <= window[4][7:0];
                
                tblu <= window[4][15:8];
                
                tred <= window[4][23:16];
                
                 kernel_output<= {tred, tblu, tgre};
            end
            
            4'b0111:
            begin
                tgre <= window[6][7:0] - window[8][7:0];
                
                tblu <= window[6][15:8] - window[8][15:8];
                
                tred <= window[6][23:16] - window[8][23:16];
                        
                        
                        
                kernel_output <= {tred>>1, tblu>>1, tgre>>1};
            end
            
            default:
                kernel_output <= kernel_output;
 end

endmodule
