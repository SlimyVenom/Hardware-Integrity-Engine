`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2026 01:56:54 PM
// Design Name: 
// Module Name: secded_decoder
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


module secded_decoder (
    input  wire [7:0] received,
    output wire [3:0] data_out,
    output wire [7:0] corrected_codeword,
    output wire [2:0] syndrome,
    output wire       no_error,
    output wire       single_error_corrected,
    output wire       double_error_detected,
    output wire       data_valid
);

    wire s0 = received[0] ^ received[2] ^ received[4] ^ received[6];
    wire s1 = received[1] ^ received[2] ^ received[5] ^ received[6];
    wire s2 = received[3] ^ received[4] ^ received[5] ^ received[6];

    assign syndrome[0] = s0;
    assign syndrome[1] = s1;
    assign syndrome[2] = s2;

    wire P = received[0] ^ received[1] ^ received[2] ^ received[3] ^
             received[4] ^ received[5] ^ received[6] ^ received[7];

    wire syndrome_nonzero = s0 | s1 | s2;

    wire no_err             = ~syndrome_nonzero & ~P;
    wire single_err_pos8    = ~syndrome_nonzero &  P;
    wire single_err_pos1_7  =  syndrome_nonzero &  P;
    wire double_err         =  syndrome_nonzero & ~P;

    assign no_error               = no_err;
    assign single_error_corrected = single_err_pos8 | single_err_pos1_7;
    assign double_error_detected  = double_err;
    assign data_valid             = ~double_err;

    wire [7:0] syndrome_oh;
    assign syndrome_oh[0] = ~s2 & ~s1 & ~s0;
    assign syndrome_oh[1] = ~s2 & ~s1 &  s0;
    assign syndrome_oh[2] = ~s2 &  s1 & ~s0;
    assign syndrome_oh[3] = ~s2 &  s1 &  s0;
    assign syndrome_oh[4] =  s2 & ~s1 & ~s0;
    assign syndrome_oh[5] =  s2 & ~s1 &  s0;
    assign syndrome_oh[6] =  s2 &  s1 & ~s0;
    assign syndrome_oh[7] =  s2 &  s1 &  s0;

    wire [7:0] mask;
    assign mask[0] = syndrome_oh[1];
    assign mask[1] = syndrome_oh[2];
    assign mask[2] = syndrome_oh[3];
    assign mask[3] = syndrome_oh[4];
    assign mask[4] = syndrome_oh[5];
    assign mask[5] = syndrome_oh[6];
    assign mask[6] = syndrome_oh[7];
    assign mask[7] = syndrome_oh[0] & P;

    assign corrected_codeword = received ^ mask;

    assign data_out[3] = corrected_codeword[2];
    assign data_out[2] = corrected_codeword[4];
    assign data_out[1] = corrected_codeword[5];
    assign data_out[0] = corrected_codeword[6];

endmodule
