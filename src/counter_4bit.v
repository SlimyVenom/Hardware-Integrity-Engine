`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 01:39:28 PM
// Design Name: 
// Module Name: counter_4bit
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

module counter_4bit(
    input [3:0] x,
    output[2:0] count 
    );
    
    wire [1:0] c01, c23;
    wire carry;
    
    counter_2bit C01(.a(x[0]), .b(x[1]), .count(c01));
    counter_2bit C23(.a(x[2]), .b(x[3]), .count(c23));
    
    full_adder F01(.a(c01[0]), .b(c23[0]), .cin(1'b0), .sum(count[0]), .cout(carry));
    full_adder F23(.a(c01[1]), .b(c23[1]), .cin(carry), .sum(count[1]), .cout(count[2]));
    
endmodule
