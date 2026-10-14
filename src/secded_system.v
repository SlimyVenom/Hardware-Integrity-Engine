`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2026 01:49:38 PM
// Design Name: 
// Module Name: secded_system
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


module secded_system (
    input  wire [3:0] data_in,
    input  wire [7:0] error_mask,
    output wire [7:0] codeword,
    output wire [7:0] received,
    output wire [7:0] corrected_codeword,
    output wire [3:0] data_out,
    output wire [2:0] syndrome,
    output wire [3:0] error_weight,
    output wire       no_error,
    output wire       single_error_corrected,
    output wire       double_error_detected,
    output wire       data_valid
);

    wire [7:0] transmitted;
    secded_encoder ENC (
        .data_in(data_in),
        .codeword(transmitted)
    );

    assign codeword = transmitted;

    wire [7:0] rx = transmitted ^ error_mask;
    assign received = rx;
    
    wire [7:0] mon_diff;
    wire mon_eq, mon_within;
    
    hamming_distance8 MONITOR (
        .A(codeword),
        .B(received),
        .threshold(4'b1),
        .difference(mon_diff),
        .distance(error_weight),
        .equal(mon_eq),
        .within_threshold(mon_within)
    );
    
    secded_decoder DEC (
        .received(received),
        .data_out(data_out),
        .corrected_codeword(corrected_codeword),
        .syndrome(syndrome),
        .no_error(no_error),
        .single_error_corrected(single_error_corrected),
        .double_error_detected(double_error_detected),
        .data_valid(data_valid)
    );
    

endmodule