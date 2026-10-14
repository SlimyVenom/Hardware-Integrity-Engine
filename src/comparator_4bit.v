`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 02:31:44 PM
// Design Name: 
// Module Name: comparator_4bit
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


module comparator_4bit(
    input [3:0] d, t,
    output out
    );
    
    wire [3:0] eq, gt;
    
    assign eq[0] = ~(d[0] ^ t[0]);
    assign eq[1] = ~(d[1] ^ t[1]);
    assign eq[2] = ~(d[2] ^ t[2]);
    assign eq[3] = ~(d[3] ^ t[3]);
    
    assign gt[0] = d[0] & ~t[0];
    assign gt[1] = d[1] & ~t[1];
    assign gt[2] = d[2] & ~t[2];
    assign gt[3] = d[3] & ~t[3];
    
    assign out = ~(gt[3] | (gt[2] & eq[3]) | (gt[1] & eq[2] & eq[3]) | (gt[0] & eq[1] & eq[2]) & eq[3]);
    
endmodule
