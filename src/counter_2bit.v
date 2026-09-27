`timescale 1ns / 1ps

module counter_2bit(
    input a, b,
    output [1:0] count
    );
    
    assign count[0] = a ^ b;
    assign count[1] = a & b;
endmodule
