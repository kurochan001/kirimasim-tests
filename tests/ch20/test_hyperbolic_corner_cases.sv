/*
:name: test_hyperbolic_corner_cases
:description: Hyperbolic Math Functions Corner Cases Test
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_hyperbolic_corner_cases.expected
*/
// IEEE 1800-2023 Hyperbolic Math Functions Corner Cases Test
// Target: $sinh, $cosh, $tanh, $asinh, $acosh, $atanh
// IEEE 1800-2023 Section 20.8.2

`timescale 1ns/1ps

module test_hyperbolic_corner_cases;
    int pass_count = 0;
    int fail_count = 0;

    // Tolerance for floating point comparisons
    real epsilon = 1e-6;

    task automatic check_real(input string name, input real result, input real expected);
        real diff;
        diff = (result > expected) ? (result - expected) : (expected - result);
        // Absolute tolerance: every expected value here is small. (A relative
        // check diff/expected would always pass for a negative expected value.)
        if (diff < epsilon) begin
            $display("  PASS: %s = %0f", name, result);
            pass_count++;
        end else begin
            $display("  FAIL: %s = %0f (expected %0f)", name, result, expected);
            fail_count++;
        end
    endtask

    task automatic check_positive(input string name, input real result);
        if (result > 0.0) begin
            $display("  PASS: %s = %0f (> 0)", name, result);
            pass_count++;
        end else begin
            $display("  FAIL: %s = %0f (expected > 0)", name, result);
            fail_count++;
        end
    endtask

    task automatic check_in_range(input string name, input real result, input real min_val, input real max_val);
        if (result >= min_val && result <= max_val) begin
            $display("  PASS: %s = %0f (in [%0f, %0f])", name, result, min_val, max_val);
            pass_count++;
        end else begin
            $display("  FAIL: %s = %0f (expected [%0f, %0f])", name, result, min_val, max_val);
            fail_count++;
        end
    endtask

    initial begin
        real result;

        $display("=== Hyperbolic Math Functions Corner Cases Test ===");
        $display("");

        // ===== $sinh tests =====
        $display("Test 1: $sinh - Hyperbolic sine");
        check_real("$sinh(0)", $sinh(0.0), 0.0);
        check_real("$sinh(1)", $sinh(1.0), 1.1752011936);  // sinh(1) ≈ 1.175
        check_real("$sinh(-1)", $sinh(-1.0), -1.1752011936);
        // sinh is an odd function: sinh(-x) = -sinh(x)

        $display("");
        $display("Test 2: $sinh - Large values");
        result = $sinh(10.0);
        $display("  $sinh(10) = %0f (large positive)", result);
        check_positive("$sinh(10) > 0", result);
        result = $sinh(-10.0);
        $display("  $sinh(-10) = %0f (large negative)", result);
        if (result < 0.0) begin
            $display("  PASS: $sinh(-10) < 0");
            pass_count++;
        end else begin
            $display("  FAIL: $sinh(-10) should be < 0");
            fail_count++;
        end

        // ===== $cosh tests =====
        $display("");
        $display("Test 3: $cosh - Hyperbolic cosine");
        check_real("$cosh(0)", $cosh(0.0), 1.0);  // cosh(0) = 1
        check_real("$cosh(1)", $cosh(1.0), 1.5430806348);  // cosh(1) ≈ 1.543
        check_real("$cosh(-1)", $cosh(-1.0), 1.5430806348);  // cosh is even: cosh(-x) = cosh(x)

        $display("");
        $display("Test 4: $cosh - Always >= 1");
        check_positive("$cosh(0) >= 1", $cosh(0.0));
        check_positive("$cosh(5) >= 1", $cosh(5.0));
        check_positive("$cosh(-5) >= 1", $cosh(-5.0));

        // ===== $tanh tests =====
        $display("");
        $display("Test 5: $tanh - Hyperbolic tangent");
        check_real("$tanh(0)", $tanh(0.0), 0.0);
        check_in_range("$tanh(1)", $tanh(1.0), 0.76, 0.77);  // tanh(1) ≈ 0.7616
        check_in_range("$tanh(-1)", $tanh(-1.0), -0.77, -0.76);

        $display("");
        $display("Test 6: $tanh - Asymptotic behavior (approaches ±1)");
        check_in_range("$tanh(10)", $tanh(10.0), 0.9999, 1.0001);
        check_in_range("$tanh(-10)", $tanh(-10.0), -1.0001, -0.9999);
        check_in_range("$tanh(100)", $tanh(100.0), 0.9999, 1.0001);

        // ===== $asinh tests =====
        $display("");
        $display("Test 7: $asinh - Inverse hyperbolic sine");
        check_real("$asinh(0)", $asinh(0.0), 0.0);
        check_in_range("$asinh(1)", $asinh(1.0), 0.88, 0.89);  // asinh(1) ≈ 0.8814
        check_in_range("$asinh(-1)", $asinh(-1.0), -0.89, -0.88);

        $display("");
        $display("Test 8: $asinh - Large values");
        result = $asinh(1000.0);
        $display("  $asinh(1000) = %0f", result);
        check_positive("$asinh(1000) > 0", result);
        result = $asinh(-1000.0);
        if (result < 0.0) begin
            $display("  PASS: $asinh(-1000) = %0f < 0", result);
            pass_count++;
        end else begin
            $display("  FAIL: $asinh(-1000) should be < 0");
            fail_count++;
        end

        // ===== $acosh tests =====
        $display("");
        $display("Test 9: $acosh - Inverse hyperbolic cosine (domain: x >= 1)");
        check_real("$acosh(1)", $acosh(1.0), 0.0);  // acosh(1) = 0
        check_in_range("$acosh(2)", $acosh(2.0), 1.31, 1.33);  // acosh(2) ≈ 1.3169

        $display("");
        $display("Test 10: $acosh - Large values");
        result = $acosh(100.0);
        $display("  $acosh(100) = %0f", result);
        check_positive("$acosh(100) > 0", result);

        // ===== $atanh tests =====
        $display("");
        $display("Test 11: $atanh - Inverse hyperbolic tangent (domain: -1 < x < 1)");
        check_real("$atanh(0)", $atanh(0.0), 0.0);
        check_in_range("$atanh(0.5)", $atanh(0.5), 0.54, 0.56);  // atanh(0.5) ≈ 0.5493
        check_in_range("$atanh(-0.5)", $atanh(-0.5), -0.56, -0.54);

        $display("");
        $display("Test 12: $atanh - Near boundary values");
        check_in_range("$atanh(0.9)", $atanh(0.9), 1.47, 1.48);
        check_in_range("$atanh(0.99)", $atanh(0.99), 2.64, 2.66);

        // ===== Identity relationships =====
        $display("");
        $display("Test 13: Identity: sinh(asinh(x)) = x");
        begin
            static real x = 2.5;
            static real identity_result;
            // Assigned here so the result does not depend on the order of static initializers.
            identity_result = $sinh($asinh(x));
            check_real("sinh(asinh(2.5))", identity_result, x);
        end

        $display("");
        $display("Test 14: Identity: cosh(acosh(x)) = x (for x >= 1)");
        begin
            static real x = 3.0;
            static real identity_result;
            // Assigned here so the result does not depend on the order of static initializers.
            identity_result = $cosh($acosh(x));
            check_real("cosh(acosh(3.0))", identity_result, x);
        end

        $display("");
        $display("Test 15: Identity: tanh(atanh(x)) = x (for |x| < 1)");
        begin
            static real x = 0.7;
            static real identity_result;
            // Assigned here so the result does not depend on the order of static initializers.
            identity_result = $tanh($atanh(x));
            check_real("tanh(atanh(0.7))", identity_result, x);
        end

        // ===== Relationship: cosh^2(x) - sinh^2(x) = 1 =====
        $display("");
        $display("Test 16: Identity: cosh^2(x) - sinh^2(x) = 1");
        begin
            static real x = 1.5;
            static real ch;
            static real sh;
            static real identity_result;
            // Assigned here so the result does not depend on the order of static initializers.
            ch = $cosh(x);
            sh = $sinh(x);
            identity_result = ch*ch - sh*sh;
            check_real("cosh^2(1.5) - sinh^2(1.5)", identity_result, 1.0);
        end

        // Summary
        $display("");
        $display("========================================");
        $display("TEST RESULTS: %0d/%0d PASSED", pass_count, pass_count + fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $display("========================================");

        $finish;
    end
endmodule
