`timescale 1ns / 1ps

module mux_2to1_8bit(
    input  [7:0] in0,
    input  [7:0] in1,
    input        sel,
    output [7:0] out
);

    assign out[0] = (in0[0] & ~sel) | (in1[0] & sel);
    assign out[1] = (in0[1] & ~sel) | (in1[1] & sel);
    assign out[2] = (in0[2] & ~sel) | (in1[2] & sel);
    assign out[3] = (in0[3] & ~sel) | (in1[3] & sel);
    assign out[4] = (in0[4] & ~sel) | (in1[4] & sel);
    assign out[5] = (in0[5] & ~sel) | (in1[5] & sel);
    assign out[6] = (in0[6] & ~sel) | (in1[6] & sel);
    assign out[7] = (in0[7] & ~sel) | (in1[7] & sel);

endmoduled
