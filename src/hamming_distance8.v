`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 01:23:39 PM
// Design Name: 
// Module Name: hamming_distance8
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

module hamming_distance8 (
    input wire [7:0] A,
    input wire [7:0] B,
    input wire [3:0] threshold,
    output wire [7:0] difference,
    output wire [3:0] distance,
    output wire equal,
    output wire within_threshold
);

    assign difference = A ^ B;
    counter_8bit C8B (.x(difference), .count(distance));
    comparator_8bit COM8B(.a(A), .b(B), .out(equal));
    comparator_4bit COM4B(.d(distance), .t(threshold), .out(within_threshold));

endmodule





