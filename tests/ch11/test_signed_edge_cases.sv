/*
:name: test_signed_edge_cases
:description: Signed arithmetic and comparison, $signed and $unsigned
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.7 11.8.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_edge_cases.expected
*/
// IEEE 1800-2023 §11.4: Signed arithmetic edge cases
// Tests for signed vs unsigned operations

module test_signed_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic signed [7:0] sa, sb;
    logic unsigned [7:0] ua, ub;
    int result;

    initial begin
        // Test 1: Signed positive
        test_count++;
        sa = 8'sd10;
        sb = 8'sd5;
        result = sa + sb;
        if (result == 15) begin
            pass_count++;
            $display("Test 1 PASS: 10 + 5 = %0d", result);
        end else begin
            $display("Test 1 FAIL: Signed add unexpected = %0d", result);
        end

        // Test 2: Signed negative
        test_count++;
        sa = -8'sd10;
        sb = 8'sd5;
        result = sa + sb;
        if (result == -5) begin
            pass_count++;
            $display("Test 2 PASS: -10 + 5 = %0d", result);
        end else begin
            $display("Test 2 FAIL: Neg add unexpected = %0d", result);
        end

        // Test 3: Signed comparison
        test_count++;
        sa = -8'sd1;
        sb = 8'sd1;
        if (sa < sb) begin
            pass_count++;
            $display("Test 3 PASS: -1 < 1 (signed)");
        end else begin
            $display("Test 3 FAIL: Signed cmp unexpected");
        end

        // Test 4: Unsigned comparison
        test_count++;
        ua = 8'd255;  // Unsigned 255
        ub = 8'd1;
        if (ua > ub) begin
            pass_count++;
            $display("Test 4 PASS: 255 > 1 (unsigned)");
        end else begin
            $display("Test 4 FAIL: Unsigned cmp unexpected");
        end

        // Test 5: Signed multiply
        test_count++;
        sa = -8'sd4;
        sb = 8'sd3;
        result = sa * sb;
        if (result == -12) begin
            pass_count++;
            $display("Test 5 PASS: -4 * 3 = %0d", result);
        end else begin
            $display("Test 5 FAIL: Signed mult unexpected = %0d", result);
        end

        // Test 6: Signed divide
        test_count++;
        sa = -8'sd20;
        sb = 8'sd4;
        result = sa / sb;
        if (result == -5) begin
            pass_count++;
            $display("Test 6 PASS: -20 / 4 = %0d", result);
        end else begin
            $display("Test 6 FAIL: Signed div unexpected = %0d", result);
        end

        // Test 7: $signed cast
        test_count++;
        ua = 8'hFF;  // 255 unsigned
        sa = $signed(ua);  // -1 signed
        if (sa == -1) begin
            pass_count++;
            $display("Test 7 PASS: $signed(FF) = %0d", sa);
        end else begin
            $display("Test 7 FAIL: $signed unexpected = %0d", sa);
        end

        // Test 8: $unsigned cast
        test_count++;
        sa = -8'sd1;  // -1 signed
        ua = $unsigned(sa);  // 255 unsigned
        if (ua == 8'd255) begin
            pass_count++;
            $display("Test 8 PASS: $unsigned(-1) = %0d", ua);
        end else begin
            $display("Test 8 FAIL: $unsigned unexpected = %0d", ua);
        end

        // Test 9: Min signed value
        test_count++;
        sa = -8'sd128;
        if (sa == -128) begin
            pass_count++;
            $display("Test 9 PASS: Min signed = %0d", sa);
        end else begin
            $display("Test 9 FAIL: Min unexpected = %0d", sa);
        end

        // Test 10: Max signed value
        test_count++;
        sa = 8'sd127;
        if (sa == 127) begin
            pass_count++;
            $display("Test 10 PASS: Max signed = %0d", sa);
        end else begin
            $display("Test 10 FAIL: Max unexpected = %0d", sa);
        end

        // Test 11: Right shift signed
        test_count++;
        sa = -8'sd8;
        result = sa >>> 2;
        if (result == -2) begin
            pass_count++;
            $display("Test 11 PASS: -8 >>> 2 = %0d", result);
        end else begin
            $display("Test 11 FAIL: Arith shift unexpected = %0d", result);
        end

        // Test 12: Mixed signed/unsigned
        test_count++;
        sa = -8'sd1;
        ua = 8'd1;
        result = $signed(sa) + $signed({1'b0, ua});
        // $signed({1'b0, ua}) is +1, so the sum is 0.
        if (result == 0) begin
            pass_count++;
            $display("Test 12 PASS: Mixed operation = %0d", result);
        end else begin
            $display("Test 12 FAIL: Mixed operation = %0d", result);
        end

        $display("=== Signed Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
