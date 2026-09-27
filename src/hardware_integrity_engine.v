`timescale 1ns / 1ps

module hardware_integrity_engine(
    input              clk,
    input  [15:0]      sw,
    output [15:0]      led,
    output [3:0]       an,
    output [6:0]       seg,
    output             dp
);

    localparam DASH = 4'b1111;
    localparam ZERO = 4'd0;

    reg [7:0] reference_data = 8'b0;
    reg [7:0] received_data  = 8'b0;

    wire [7:0] reference_data_next;
    wire [7:0] received_data_next;

    mux_2to1_8bit REFERENCE_MUX(
        .in0(sw[7:0]),
        .in1(reference_data),
        .sel(sw[8]),
        .out(reference_data_next)
    );

    mux_2to1_8bit RECEIVED_MUX(
        .in0(received_data),
        .in1(sw[7:0]),
        .sel(sw[8]),
        .out(received_data_next)
    );

    always @(posedge clk) begin
        reference_data <= reference_data_next;
        received_data  <= received_data_next;
    end

    wire [7:0] error_pattern;
    wire [3:0] error_distance;
    wire       exact_match;
    wire       integrity_valid;

    hamming_distance8 INTEGRITY_CORE(
        .A(reference_data),
        .B(received_data),
        .threshold(sw[12:9]),
        .difference(error_pattern),
        .distance(error_distance),
        .equal(exact_match),
        .within_threshold(integrity_valid)
    );

    assign led[7:0]  = error_pattern;
    assign led[13:8] = 6'b0;
    assign led[14]   = integrity_valid;
    assign led[15]   = exact_match;

    display_controller DISPLAY(
        .clk(clk),
        .digit0(error_distance),
        .digit1(ZERO),
        .digit2(DASH),
        .digit3(DASH),
        .an(an),
        .seg(seg),
        .dp(dp)
    );

endmodule
