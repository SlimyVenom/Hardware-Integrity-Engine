`timescale 1ns / 1ps

module display_controller(
    input        clk,
    input  [3:0] digit0,
    input  [3:0] digit1,
    input  [3:0] digit2,
    input  [3:0] digit3,
    output [3:0] an,
    output [6:0] seg,
    output       dp
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

    reg [3:0] selected_digit;

    always @(*) begin
        case (active_display)
            2'b00: selected_digit = digit0;
            2'b01: selected_digit = digit1;
            2'b10: selected_digit = digit2;
            2'b11: selected_digit = digit3;
            default: selected_digit = 4'b1111;
        endcase
    end

    reg [6:0] seg_temp;

    always @(*) begin
        case (selected_digit)
            4'd0:    seg_temp = 7'b1000000;
            4'd1:    seg_temp = 7'b1111001;
            4'd2:    seg_temp = 7'b0100100;
            4'd3:    seg_temp = 7'b0110000;
            4'd4:    seg_temp = 7'b0011001;
            4'd5:    seg_temp = 7'b0010010;
            4'd6:    seg_temp = 7'b0000010;
            4'd7:    seg_temp = 7'b1111000;
            4'd8:    seg_temp = 7'b0000000;
            4'd9:    seg_temp = 7'b0010000;
            4'b1111: seg_temp = 7'b0111111;
            default: seg_temp = 7'b1111111;
        endcase
    end

    assign seg = seg_temp;

    assign an[0] = (active_display == 2'b00) ? 1'b0 : 1'b1;
    assign an[1] = (active_display == 2'b01) ? 1'b0 : 1'b1;
    assign an[2] = (active_display == 2'b10) ? 1'b0 : 1'b1;
    assign an[3] = (active_display == 2'b11) ? 1'b0 : 1'b1;

    assign dp = 1'b1;

endmodule
