`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 01:57:25 PM
// Design Name: 
// Module Name: counter_8bit
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

module counter_8bit(
    input [7:0] x, 
    output [3:0] count 
    );
    
    wire [2:0] c03, c47;
    wire carry1, carry2;
    
    counter_4bit C03 (.x(x[3:0]), .count(c03));
    counter_4bit C47 (.x(x[7:4]), .count(c47));
    
    full_adder F1(.a(c03[0]), .b(c47[0]), .cin(1'b0), .sum(count[0]), .cout(carry1));
    full_adder F2(.a(c03[1]), .b(c47[1]), .cin(carry1), .sum(count[1]), .cout(carry2));
    full_adder F3(.a(c03[2]), .b(c47[2]), .cin(carry2), .sum(count[2]), .cout(count[3]));
    
endmodule
