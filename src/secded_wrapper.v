`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2026 01:48:34 PM
// Design Name: 
// Module Name: secded_wrapper
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


module secded_wrapper(
    input  wire        clk,
    input  wire [15:0] sw,
    output wire [15:0] led,
    output wire [3:0]  an,
    output wire [6:0]  seg,
    output wire        dp
);

    wire [3:0] data_in    = sw[3:0];
    wire [7:0] error_mask = sw[11:4];

    wire [7:0] codeword, received, corrected_codeword;
    wire [3:0] data_out, error_weight;
    wire [2:0] syndrome;
    wire       no_error, single_error_corrected, double_error_detected, data_valid;

    secded_system UUT (
        .data_in(data_in),
        .error_mask(error_mask),
        .codeword(codeword),
        .received(received),
        .corrected_codeword(corrected_codeword),
        .data_out(data_out),
        .syndrome(syndrome),
        .error_weight(error_weight),
        .no_error(no_error),
        .single_error_corrected(single_error_corrected),
        .double_error_detected(double_error_detected),
        .data_valid(data_valid)
    );

    assign led[7:0]   = corrected_codeword;
    assign led[8]     = no_error;
    assign led[9]     = single_error_corrected;
    assign led[10]    = double_error_detected;
    assign led[11]    = data_valid;
    assign led[15:12] = 4'b0;

    wire [4:0] disp_I = {1'b0, data_in};
    wire [4:0] disp_O = data_valid ? {1'b0, data_out} : 5'b1_0000;
    wire [4:0] disp_S = {2'b0, syndrome};
    wire [4:0] disp_W = {1'b0, error_weight};

    display_controller DISPLAY (
        .clk(clk),
        .digit0(disp_W),
        .digit1(disp_S),
        .digit2(disp_O),
        .digit3(disp_I),
        .an(an),
        .seg(seg),
        .dp(dp)
    );

endmodule