`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2026 01:49:58 PM
// Design Name: 
// Module Name: display_controller
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



module display_controller(
    input              clk,
    input  [4:0]       digit0,     // bit[4]=1 â†' dash; bit[3:0]=hex
    input  [4:0]       digit1,
    input  [4:0]       digit2,
    input  [4:0]       digit3,
    output [3:0]       an,
    output [6:0]       seg,
    output             dp
);

    parameter REFRESH_COUNT = 17'd99999;

    reg [16:0] refresh_counter = 17'd0;
    reg [1:0]  active_display  = 2'b0;

    always @(posedge clk) begin
        if (refresh_counter == REFRESH_COUNT) begin
            refresh_counter <= 17'd0;
            active_display  <= active_display + 2'b1;
        end else begin
            refresh_counter <= refresh_counter + 17'd1;
        end
    end

    reg [4:0] selected_digit;
    always @(*) begin
        case (active_display)
            2'b00: selected_digit = digit0;
            2'b01: selected_digit = digit1;
            2'b10: selected_digit = digit2;
            2'b11: selected_digit = digit3;
            default: selected_digit = 5'b1_0000;
        endcase
    end

    reg [6:0] seg_temp;
    always @(*) begin
        case (selected_digit)
            5'd0:  seg_temp = 7'b1000000;  // 0
            5'd1:  seg_temp = 7'b1111001;  // 1
            5'd2:  seg_temp = 7'b0100100;  // 2
            5'd3:  seg_temp = 7'b0110000;  // 3
            5'd4:  seg_temp = 7'b0011001;  // 4
            5'd5:  seg_temp = 7'b0010010;  // 5
            5'd6:  seg_temp = 7'b0000010;  // 6
            5'd7:  seg_temp = 7'b1111000;  // 7
            5'd8:  seg_temp = 7'b0000000;  // 8
            5'd9:  seg_temp = 7'b0010000;  // 9
            5'd10: seg_temp = 7'b0001000;  // A
            5'd11: seg_temp = 7'b0000011;  // b
            5'd12: seg_temp = 7'b1000110;  // C
            5'd13: seg_temp = 7'b0100001;  // d
            5'd14: seg_temp = 7'b0000110;  // E
            5'd15: seg_temp = 7'b0001110;  // F
            5'd16: seg_temp = 7'b0111111;  // dash (g only)
            default: seg_temp = 7'b1111111; // blank
        endcase
    end

    assign seg = seg_temp;
    assign dp  = 1'b1;

    assign an[0] = (active_display == 2'b00) ? 1'b0 : 1'b1;
    assign an[1] = (active_display == 2'b01) ? 1'b0 : 1'b1;
    assign an[2] = (active_display == 2'b10) ? 1'b0 : 1'b1;
    assign an[3] = (active_display == 2'b11) ? 1'b0 : 1'b1;

endmodule