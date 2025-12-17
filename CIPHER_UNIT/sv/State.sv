`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2025 02:22:41 PM
// Design Name: 
// Module Name: State
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


module State(
input logic CLK,enable,CLR,             // Clock and Write Enable
input logic [31:0] state_i [3:0],   // State Input
output logic [31:0] state_o [3:0]   // State Output
    );
    
    always_ff@(posedge CLK)
    begin
        if(CLR)
            begin    // Only write when Enable is High
                state_o [0]= 0;
                state_o [1]= 0;
                state_o [2]= 0;
                state_o [3]= 0;
            end
       if(enable)
            begin    // Only write when Enable is High
                state_o <= state_i; // Write input to output
            end
                    
    end
endmodule
