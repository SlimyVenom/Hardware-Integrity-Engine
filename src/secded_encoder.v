`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2026 01:54:36 PM
// Design Name: 
// Module Name: secded_encoder
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


module secded_encoder(
    input wire [3:0] data_in,
    output wire [7:0] codeword
);
    wire d3 = data_in[3];
    wire d2 = data_in[2];
    wire d1 = data_in[1];
    wire d0 = data_in[0];

    wire p1 = d3 ^ d2 ^ d0;
    wire p2 = d3 ^ d1 ^ d0;
    wire p4 = d2 ^ d1 ^ d0;
    wire p0 = p1 ^ p2 ^ d3 ^ p4 ^ d2 ^ d1 ^ d0;

    assign codeword[0] = p1;
    assign codeword[1] = p2;
    assign codeword[2] = d3;
    assign codeword[3] = p4;
    assign codeword[4] = d2;
    assign codeword[5] = d1;
    assign codeword[6] = d0;
    assign codeword[7] = p0;
    
endmodule
