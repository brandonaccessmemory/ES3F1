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
    output reg [5:0] brightness
    );
    
//generates a random piece depending on the value of random
initial begin 
    brightness = 0;
 end
 always@(posedge clk) begin 
    if(!n_rst) begin 
        brightness <= 0;
    end else begin 
    
        if ( brightness == 50 ) begin 
            brightness <= 0;
        end else begin 
            brightness <= brightness + 5;
        end
    end
 end

endmodule

