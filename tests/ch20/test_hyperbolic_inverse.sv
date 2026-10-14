/*
:name: test_hyperbolic_inverse
:description: Chapter 20.8 - Inverse hyperbolic functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hyperbolic_inverse.expected
*/
// IEEE 1800-2023: Chapter 20.8 - Inverse hyperbolic functions
// Test: $asinh(), $acosh(), $atanh()

module test_hyperbolic_inverse;
    initial begin
        static int passed = 0;
        static int failed = 0;
        static real tolerance = 0.000001;  // Floating point comparison tolerance

        $display("========== Inverse Hyperbolic Functions Tests ==========");

        // ===== Test 1: $asinh(0) = 0 =====
        begin
            static real result = $asinh(0.0);
            if (result >= -tolerance && result <= tolerance) begin
                $display("PASS: $asinh(0) = %f (expected 0)", result);
                passed++;
            end else begin
                $display("FAIL: $asinh(0) = %f, expected 0", result);
                failed++;
            end
        end

        // ===== Test 2: $asinh(1) ≈ 0.881374 =====
        begin
            static real result = $asinh(1.0);
            static real expected = 0.881373587;  // ln(1 + sqrt(2))
            if (result >= expected - tolerance && result <= expected + tolerance) begin
                $display("PASS: $asinh(1) = %f (expected %f)", result, expected);
                passed++;
            end else begin
                $display("FAIL: $asinh(1) = %f, expected %f", result, expected);
                failed++;
            end
        end

        // ===== Test 3: $asinh(-1) ≈ -0.881374 =====
        begin
            static real result = $asinh(-1.0);
            static real expected = -0.881373587;
            if (result >= expected - tolerance && result <= expected + tolerance) begin
                $display("PASS: $asinh(-1) = %f (expected %f)", result, expected);
                passed++;
            end else begin
                $display("FAIL: $asinh(-1) = %f, expected %f", result, expected);
                failed++;
            end
        end

        // ===== Test 4: $asinh(2) ≈ 1.443635 =====
        begin
            static real result = $asinh(2.0);
            static real expected = 1.443635475;
            if (result >= expected - tolerance && result <= expected + tolerance) begin
                $display("PASS: $asinh(2) = %f (expected %f)", result, expected);
                passed++;
            end else begin
                $display("FAIL: $asinh(2) = %f, expected %f", result, expected);
                failed++;
            end
        end

        // ===== Test 5: $acosh(1) = 0 =====
        begin
            static real result = $acosh(1.0);
            if (result >= -tolerance && result <= tolerance) begin
                $display("PASS: $acosh(1) = %f (expected 0)", result);
                passed++;
            end else begin
                $display("FAIL: $acosh(1) = %f, expected 0", result);
                failed++;
            end
        end

        // ===== Test 6: $acosh(2) ≈ 1.316958 =====
        begin
            static real result = $acosh(2.0);
            static real expected = 1.316957897;  // ln(2 + sqrt(3))
            if (result >= expected - tolerance && result <= expected + tolerance) begin
                $display("PASS: $acosh(2) = %f (expected %f)", result, expected);
                passed++;
            end else begin
                $display("FAIL: $acosh(2) = %f, expected %f", result, expected);
                failed++;
            end
        end

        // ===== Test 7: $acosh(3) ≈ 1.762747 =====
        begin
            static real result = $acosh(3.0);
            static real expected = 1.762747174;
            if (result >= expected - tolerance && result <= expected + tolerance) begin
                $display("PASS: $acosh(3) = %f (expected %f)", result, expected);
                passed++;
            end else begin
                $display("FAIL: $acosh(3) = %f, expected %f", result, expected);
                failed++;
            end
        end

        // ===== Test 8: $acosh(10) ≈ 2.993223 =====
        begin
            static real result = $acosh(10.0);
            static real expected = 2.993222847;
            if (result >= expected - tolerance && result <= expected + tolerance) begin
                $display("PASS: $acosh(10) = %f (expected %f)", result, expected);
                passed++;
            end else begin
                $display("FAIL: $acosh(10) = %f, expected %f)", result, expected);
                failed++;
            end
        end

        // ===== Test 9: $atanh(0) = 0 =====
        begin
            static real result = $atanh(0.0);
            if (result >= -tolerance && result <= tolerance) begin
                $display("PASS: $atanh(0) = %f (expected 0)", result);
                passed++;
            end else begin
                $display("FAIL: $atanh(0) = %f, expected 0", result);
                failed++;
            end
        end

        // ===== Test 10: $atanh(0.5) ≈ 0.549306 =====
        begin
            static real result = $atanh(0.5);
            static real expected = 0.549306144;  // 0.5 * ln(3)
            if (result >= expected - tolerance && result <= expected + tolerance) begin
                $display("PASS: $atanh(0.5) = %f (expected %f)", result, expected);
                passed++;
            end else begin
                $display("FAIL: $atanh(0.5) = %f, expected %f", result, expected);
                failed++;
            end
        end

        // ===== Test 11: $atanh(-0.5) ≈ -0.549306 =====
        begin
            static real result = $atanh(-0.5);
            static real expected = -0.549306144;
            if (result >= expected - tolerance && result <= expected + tolerance) begin
                $display("PASS: $atanh(-0.5) = %f (expected %f)", result, expected);
                passed++;
            end else begin
                $display("FAIL: $atanh(-0.5) = %f, expected %f", result, expected);
                failed++;
            end
        end

        // ===== Test 12: $atanh(0.9) ≈ 1.472219 =====
        begin
            static real result = $atanh(0.9);
            static real expected = 1.472219490;
            if (result >= expected - tolerance && result <= expected + tolerance) begin
                $display("PASS: $atanh(0.9) = %f (expected %f)", result, expected);
                passed++;
            end else begin
                $display("FAIL: $atanh(0.9) = %f, expected %f", result, expected);
                failed++;
            end
        end

        // ===== Summary =====
        $display("========================================");
        $display("Inverse Hyperbolic Functions Test Summary:");
        $display("  Passed: %0d", passed);
        $display("  Failed: %0d", failed);
        $display("  Total:  %0d", passed + failed);
        $display("========================================");

        if (failed == 0) begin
            $display("ALL TESTS PASSED");
            $finish(0);
        end else begin
            $display("SOME TESTS FAILED");
            $finish(1);
        end
    end
endmodule
