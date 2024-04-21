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
    
 always@(posedge clk) begin 
    if(!n_rst) begin 
        kernel_output <= 0;
    end else begin 
    
        if ( brightness == 50 ) begin 
            brightness <= 0;
        end else begin 
            brightness <= brightness + 5;
        end
    end
 end

endmodule
