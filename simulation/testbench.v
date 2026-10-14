`timescale 1ns / 1ps

module secded_wrapper_tb;

    reg         clk;
    reg  [15:0] sw;
    wire [15:0] led;
    wire [3:0]  an;
    wire [6:0]  seg;
    wire        dp;

    integer error_count;
    integer d;
    integer j;
    integer k;

    secded_wrapper UUT (
        .clk(clk),
        .sw(sw),
        .led(led),
        .an(an),
        .seg(seg),
        .dp(dp)
    );

    always #5 clk = ~clk;

    // Reference model inputs
    wire [3:0] din;
    wire [7:0] error_mask;

    assign din        = sw[3:0];
    assign error_mask = sw[11:4];

    // Independent behavioral SECDED encoder
    wire p1;
    wire p2;
    wire p4;
    wire p0;

    assign p1 = din[3] ^ din[2] ^ din[0];
    assign p2 = din[3] ^ din[1] ^ din[0];
    assign p4 = din[2] ^ din[1] ^ din[0];

    assign p0 = p1 ^ p2 ^ p4 ^
                din[3] ^ din[2] ^ din[1] ^ din[0];

    wire [7:0] expected_codeword;
    wire [7:0] received_codeword;

    assign expected_codeword = {
        p0, din[0], din[1], din[2],
        p4, din[3], p2, p1
    };

    assign received_codeword = expected_codeword ^ error_mask;

    initial begin
        clk = 1'b0;
        sw = 16'b0;
        error_count = 0;

        // Allow the design to settle before testing.
        #20;

        $display("========================================");
        $display("SECDED Wrapper Testbench");
        $display("Testing 16 datawords, 8 single-bit");
        $display("errors, and 28 double-bit errors");
        $display("========================================");

        for (d = 0; d < 16; d = d + 1) begin

            // ----------------------------------------
            // Test 1: No error
            // ----------------------------------------

            sw = {4'b0000, 8'b00000000, d[3:0]};
            #20;

            if (led[7:0] !== expected_codeword) begin
                error_count = error_count + 1;
                $display(
                    "FAIL no-error: data=%0d corrected=%b expected=%b",
                    d, led[7:0], expected_codeword
                );
            end

            if ({led[11], led[10], led[9], led[8]} !== 4'b1001) begin
                error_count = error_count + 1;
                $display(
                    "FAIL no-error status: data=%0d status=%b%b%b%b",
                    d, led[11], led[10], led[9], led[8]
                );
            end

            // ----------------------------------------
            // Test 2: Every single-bit error
            // ----------------------------------------

            for (j = 0; j < 8; j = j + 1) begin

                sw = {
                    4'b0000,
                    (8'b00000001 << j),
                    d[3:0]
                };

                #20;

                // A single-bit error must be corrected.
                if (led[7:0] !== expected_codeword) begin
                    error_count = error_count + 1;
                    $display(
                        "FAIL single-error: data=%0d bit=%0d corrected=%b expected=%b",
                        d, j + 1, led[7:0], expected_codeword
                    );
                end

                // Expected status:
                // data_valid=1, double_error=0,
                // single_error_corrected=1, no_error=0.
                if ({led[11], led[10], led[9], led[8]} !== 4'b1010) begin
                    error_count = error_count + 1;
                    $display(
                        "FAIL single-error status: data=%0d bit=%0d status=%b%b%b%b",
                        d, j + 1, led[11], led[10], led[9], led[8]
                    );
                end
            end

            // ----------------------------------------
            // Test 3: Every double-bit error
            // ----------------------------------------

            for (j = 0; j < 8; j = j + 1) begin
                for (k = j + 1; k < 8; k = k + 1) begin

                    sw = {
                        4'b0000,
                        ((8'b00000001 << j) |
                         (8'b00000001 << k)),
                        d[3:0]
                    };

                    #20;

                    // Expected status:
                    // data_valid=0, double_error=1,
                    // single_error_corrected=0, no_error=0.
                    if ({led[11], led[10], led[9], led[8]} !== 4'b0100) begin
                        error_count = error_count + 1;
                        $display(
                            "FAIL double-error status: data=%0d bits=%0d,%0d status=%b%b%b%b",
                            d, j + 1, k + 1,
                            led[11], led[10], led[9], led[8]
                        );
                    end
                end
            end
        end

        $display("========================================");

        if (error_count == 0)
            $display("ALL WRAPPER TESTS PASSED");
        else
            $display("%0d FAILURES DETECTED", error_count);

        $display("========================================");

        $finish;
    end

endmodule
