`timescale 1ns / 1ps

module hardware_integrity_engine_tb();

    // ============================================================
    // Testbench signals
    // ============================================================
    reg         clk;
    reg  [15:0] sw;
    wire [15:0] led;
    wire [3:0]  an;
    wire [6:0]  seg;
    wire        dp;

    // ============================================================
    // Instantiate the Design Under Test (DUT)
    // ============================================================
    hardware_integrity_engine UUT(
        .clk(clk),
        .sw(sw),
        .led(led),
        .an(an),
        .seg(seg),
        .dp(dp)
    );

    // ============================================================
    // 100 MHz clock generation (10ns period)
    // ============================================================
    always #5 clk = ~clk;

    // ============================================================
    // Expected values (behavioral reference model)
    // ============================================================
    reg [7:0] expected_error_pattern;
    reg [3:0] expected_error_distance;
    reg       expected_exact_match;
    reg       expected_integrity_valid;

    integer error_count = 0;
    integer test_count  = 0;

    // ============================================================
    // Test procedure
    // ============================================================
    initial begin
        clk = 0;
        sw  = 16'b0;

        // Header
        $display("============================================================");
        $display("     Testing Hardware Integrity Engine");
        $display("============================================================");
        $display("Testing ALL 65,536 reference/received data pairs...");
        $display("For each pair, testing ALL 16 threshold values (0-15)");
        $display("Total tests: 1,048,576");
        $display("============================================================");
        $display("");

        #20;

        // ============================================================
        // EXHAUSTIVE TEST: all reference values, received values,
        // and thresholds
        // ============================================================
        for (integer reference = 0; reference < 256; reference = reference + 1) begin
            for (integer received = 0; received < 256; received = received + 1) begin

                // ----------------------------------------------------
                // Step 1: Capture reference data (SW8 = 0)
                // ----------------------------------------------------
                sw = {8'b0, 1'b0, reference[7:0]};
                #10;

                // ----------------------------------------------------
                // Step 2: Capture received data (SW8 = 1)
                // ----------------------------------------------------
                sw = {8'b0, 1'b1, received[7:0]};
                #10;

                // ----------------------------------------------------
                // Step 3: Test all 16 thresholds
                // ----------------------------------------------------
                for (integer threshold = 0;
                     threshold < 16;
                     threshold = threshold + 1) begin

                    sw[12:9] = threshold[3:0];
                    #10;

                    test_count = test_count + 1;

                    // Compute expected values (behavioral reference model)
                    expected_error_pattern =
                        reference[7:0] ^ received[7:0];

                    expected_error_distance = 0;

                    for (integer i = 0; i < 8; i = i + 1) begin
                        expected_error_distance =
                            expected_error_distance + expected_error_pattern[i];
                    end

                    expected_exact_match =
                        (expected_error_distance == 0) ? 1'b1 : 1'b0;

                    expected_integrity_valid =
                        (expected_error_distance <= threshold) ? 1'b1 : 1'b0;

                    // ----------------------------------------------------
                    // Verify all outputs
                    // ----------------------------------------------------
                    if ((led[7:0] == expected_error_pattern) &&
                        (led[15]  == expected_exact_match) &&
                        (led[14]  == expected_integrity_valid)) begin
                        // PASS - silently continue
                    end else begin
                        // FAIL - print details
                        error_count = error_count + 1;

                        $display("============================================================");
                        $display("ERROR DETECTED!");
                        $display("Reference = %d (0x%h)", reference, reference);
                        $display("Received  = %d (0x%h)", received, received);
                        $display("Threshold = %d", threshold);

                        $display(
                            "Expected: error_pattern=%b exact_match=%d integrity_valid=%d (distance=%d)",
                            expected_error_pattern,
                            expected_exact_match,
                            expected_integrity_valid,
                            expected_error_distance
                        );

                        $display(
                            "Got:      error_pattern=%b exact_match=%d integrity_valid=%d",
                            led[7:0],
                            led[15],
                            led[14]
                        );

                        $display("============================================================");
                    end
                end
            end

            // Progress indicator every 32 reference values
            if (reference % 32 == 0) begin
                $display(
                    "Progress: reference = %0d/255, tests run = %0d, errors = %0d",
                    reference,
                    test_count,
                    error_count
                );
            end
        end

        // ============================================================
        // Final Summary
        // ============================================================
        $display("");
        $display("============================================================");
        $display("                    TEST COMPLETE");
        $display("============================================================");
        $display("Total tests: %0d", test_count);
        $display("Errors:      %0d", error_count);
        $display("");

        if (error_count == 0) begin
            $display("ALL TESTS PASSED!");
            $display("All %0d test cases verified successfully!", test_count);
        end else begin
            $display("%0d TESTS FAILED!", error_count);
            $display("Please check the errors above.");
        end

        $display("============================================================");
        $finish;
    end

endmodule
