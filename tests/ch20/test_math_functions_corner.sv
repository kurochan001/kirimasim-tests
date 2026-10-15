/*
:name: test_math_functions_corner
:description: $clog2 and the real math functions at simple arguments
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_functions_corner.expected
*/
// $clog2 and the real math functions at simple arguments
`timescale 1ns/1ps

module test_math_functions_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: $clog2 corner cases
    task test_clog2();
        int result;

        // Powers of 2
        result = $clog2(1);
        if (result == 0) begin
            $display("PASS: $clog2(1) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: $clog2(1) = %0d (expected 0)", result);
            fail_count++;
        end

        result = $clog2(2);
        if (result == 1) begin
            $display("PASS: $clog2(2) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: $clog2(2) = %0d (expected 1)", result);
            fail_count++;
        end

        result = $clog2(256);
        if (result == 8) begin
            $display("PASS: $clog2(256) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: $clog2(256) = %0d (expected 8)", result);
            fail_count++;
        end

        // Non-powers of 2
        result = $clog2(5);
        if (result == 3) begin
            $display("PASS: $clog2(5) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: $clog2(5) = %0d (expected 3)", result);
            fail_count++;
        end

        // Zero
        result = $clog2(0);
        // An argument of 0 gives 0 (20.8.1).
        if (result == 0) begin
            $display("PASS: $clog2(0) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: $clog2(0) = %0d", result);
            fail_count++;
        end
    endtask

    // Test 2: $ln (natural log)
    task test_ln();
        real result;

        result = $ln(1.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            $display("PASS: $ln(1.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $ln(1.0) = %f (expected 0.0)", result);
            fail_count++;
        end

        result = $ln(2.718281828);
        if (result > 0.99 && result < 1.01) begin
            $display("PASS: $ln(e) ~ %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $ln(e) = %f (expected ~1.0)", result);
            fail_count++;
        end

        result = $ln(10.0);
        if (result > 2.30 && result < 2.31) begin
            $display("PASS: $ln(10) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $ln(10) = %f", result);
            fail_count++;
        end
    endtask

    // Test 3: $log10
    task test_log10();
        real result;

        result = $log10(1.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            $display("PASS: $log10(1.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $log10(1.0) = %f (expected 0.0)", result);
            fail_count++;
        end

        result = $log10(10.0);
        if (result > 1.0 - 1e-9 && result < 1.0 + 1e-9) begin
            $display("PASS: $log10(10.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $log10(10.0) = %f (expected 1.0)", result);
            fail_count++;
        end

        result = $log10(100.0);
        if (result > 2.0 - 1e-9 && result < 2.0 + 1e-9) begin
            $display("PASS: $log10(100.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $log10(100.0) = %f (expected 2.0)", result);
            fail_count++;
        end
    endtask

    // Test 4: $exp
    task test_exp();
        real result;

        result = $exp(0.0);
        if (result > 1.0 - 1e-9 && result < 1.0 + 1e-9) begin
            $display("PASS: $exp(0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $exp(0.0) = %f (expected 1.0)", result);
            fail_count++;
        end

        result = $exp(1.0);
        if (result > 2.71 && result < 2.72) begin
            $display("PASS: $exp(1.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $exp(1.0) = %f (expected ~2.718)", result);
            fail_count++;
        end
    endtask

    // Test 5: $sqrt
    task test_sqrt();
        real result;

        result = $sqrt(0.0);
        if (result == 0.0) begin
            $display("PASS: $sqrt(0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $sqrt(0.0) = %f", result);
            fail_count++;
        end

        result = $sqrt(1.0);
        if (result == 1.0) begin
            $display("PASS: $sqrt(1.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $sqrt(1.0) = %f", result);
            fail_count++;
        end

        result = $sqrt(4.0);
        if (result == 2.0) begin
            $display("PASS: $sqrt(4.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $sqrt(4.0) = %f (expected 2.0)", result);
            fail_count++;
        end

        result = $sqrt(2.0);
        if (result > 1.414 && result < 1.415) begin
            $display("PASS: $sqrt(2.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $sqrt(2.0) = %f", result);
            fail_count++;
        end
    endtask

    // Test 6: $pow
    task test_pow();
        real result;

        result = $pow(2.0, 3.0);
        if (result > 8.0 - 1e-9 && result < 8.0 + 1e-9) begin
            $display("PASS: $pow(2.0, 3.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $pow(2.0, 3.0) = %f (expected 8.0)", result);
            fail_count++;
        end

        result = $pow(10.0, 0.0);
        if (result > 1.0 - 1e-9 && result < 1.0 + 1e-9) begin
            $display("PASS: $pow(10.0, 0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $pow(10.0, 0.0) = %f (expected 1.0)", result);
            fail_count++;
        end

        result = $pow(2.0, -1.0);
        if (result > 0.5 - 1e-9 && result < 0.5 + 1e-9) begin
            $display("PASS: $pow(2.0, -1.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $pow(2.0, -1.0) = %f (expected 0.5)", result);
            fail_count++;
        end
    endtask

    // Test 7: Trigonometric functions
    task test_trig();
        real result;
        static real pi = 3.14159265358979;

        result = $sin(0.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            $display("PASS: $sin(0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $sin(0.0) = %f", result);
            fail_count++;
        end

        result = $cos(0.0);
        if (result > 1.0 - 1e-9 && result < 1.0 + 1e-9) begin
            $display("PASS: $cos(0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $cos(0.0) = %f (expected 1.0)", result);
            fail_count++;
        end

        result = $sin(pi / 2.0);
        if (result > 0.999 && result < 1.001) begin
            $display("PASS: $sin(pi/2) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $sin(pi/2) = %f (expected 1.0)", result);
            fail_count++;
        end

        result = $tan(0.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            $display("PASS: $tan(0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $tan(0.0) = %f", result);
            fail_count++;
        end
    endtask

    // Test 8: Inverse trig functions
    task test_inverse_trig();
        real result;
        static real pi = 3.14159265358979;

        result = $asin(0.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            $display("PASS: $asin(0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $asin(0.0) = %f", result);
            fail_count++;
        end

        result = $acos(1.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            $display("PASS: $acos(1.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $acos(1.0) = %f", result);
            fail_count++;
        end

        result = $atan(0.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            $display("PASS: $atan(0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $atan(0.0) = %f", result);
            fail_count++;
        end

        result = $atan2(1.0, 1.0);
        if (result > 0.78 && result < 0.79) begin
            $display("PASS: $atan2(1.0, 1.0) = %f (pi/4)", result);
            pass_count++;
        end else begin
            $display("FAIL: $atan2(1.0, 1.0) = %f", result);
            fail_count++;
        end
    endtask

    // Test 9: Hyperbolic functions
    task test_hyperbolic();
        real result;

        result = $sinh(0.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            $display("PASS: $sinh(0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $sinh(0.0) = %f", result);
            fail_count++;
        end

        result = $cosh(0.0);
        if (result > 1.0 - 1e-9 && result < 1.0 + 1e-9) begin
            $display("PASS: $cosh(0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $cosh(0.0) = %f (expected 1.0)", result);
            fail_count++;
        end

        result = $tanh(0.0);
        if (result > 0.0 - 1e-9 && result < 0.0 + 1e-9) begin
            $display("PASS: $tanh(0.0) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $tanh(0.0) = %f", result);
            fail_count++;
        end
    endtask

    // Test 10: $floor, $ceil, $round
    task test_rounding();
        real result;

        result = $floor(3.7);
        if (result == 3.0) begin
            $display("PASS: $floor(3.7) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $floor(3.7) = %f (expected 3.0)", result);
            fail_count++;
        end

        result = $ceil(3.2);
        if (result == 4.0) begin
            $display("PASS: $ceil(3.2) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $ceil(3.2) = %f (expected 4.0)", result);
            fail_count++;
        end

        // Negative values
        result = $floor(-3.2);
        if (result == -4.0) begin
            $display("PASS: $floor(-3.2) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $floor(-3.2) = %f (expected -4.0)", result);
            fail_count++;
        end

        result = $ceil(-3.7);
        if (result == -3.0) begin
            $display("PASS: $ceil(-3.7) = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: $ceil(-3.7) = %f (expected -3.0)", result);
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Math Functions Corner Cases Test ===");

        test_clog2();
        test_ln();
        test_log10();
        test_exp();
        test_sqrt();
        test_pow();
        test_trig();
        test_inverse_trig();
        test_hyperbolic();
        test_rounding();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
