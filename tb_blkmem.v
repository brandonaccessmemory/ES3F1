`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2024 18:44:10
// Design Name: 
// Module Name: tb_blkmem
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


module tb_blkmem();
    // Inputs
    reg clk;
    reg wea;                  // write enable signal
    reg [10:0] addra;               // address
    reg signed [23:0] dina;     // data in


    // Outputs
    wire [71:0] douta;          // data out

    // Instantiate the Unit Under Test (UUT)
    blk_mem_gen_0 inst0(
        .clka(clk),
        .wea(wea),
        .addra(addra),
        .dina(dina),
        .douta(douta)
    );

    always begin
        #15 clk =~clk;
    end

    task writeStuff;    //write to address
        begin
            addra <= addra + 1;
            dina <= dina+1;
        end
    endtask

    task readStuff; // read the at address
        begin
            addra <= addra + 1;
        end
    endtask

    reg [1:0] writing;
    integer counter;
    initial begin
        // Initialize Inputs
        clk = 0;
        addra = 0;
        dina = 16;
        counter = 0;
        writing = 2'b10; //idle state
        // Wait 100 ns for global reset to finish
        #100;
        wea <= 1;
        writing <=1;
    end

    always @(posedge clk)begin
        case(writing)
            1: if(counter<10) begin
                    writeStuff;
                    counter <=counter+1;
                end else begin
                    writing <=0;    // change state to reading
                    counter <=0;
                    addra <= 0;
                    wea <=0;    // stop writing
                end
            0:  if(counter<10) begin
                    readStuff;
                    counter <=counter+1;
                end else begin // change addra to zero and do nothing
                    addra <= 0;
                    writing <=2'b10; //goto idle state
                end
            2: if(1) begin
                    //do nothing
                end
        endcase
    end
endmodule
