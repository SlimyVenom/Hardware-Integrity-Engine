`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 02:11:55 PM
// Design Name: 
// Module Name: comparator_8bit
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


module comparator_8bit(
    input [7:0] a, b,
    output out
    );
    
    wire [7:0] diff;
    
    assign diff[0] =  a[0] ^ b[0] ;
    assign diff[1] =  a[1] ^ b[1] ;
    assign diff[2] =  a[2] ^ b[2] ;
    assign diff[3] =  a[3] ^ b[3] ;
    assign diff[4] =  a[4] ^ b[4] ;
    assign diff[5] =  a[5] ^ b[5] ;
    assign diff[6] =  a[6] ^ b[6] ;
    assign diff[7] =  a[7] ^ b[7] ;
    
    assign out = ~(diff[0] | diff[1] | diff[2] | diff[3] | diff[4] | diff[5] | diff[6] | diff[7]);
    
endmodule
