/*
:name: test_math_functions_2
:description: Math functions at points with exact results, within a small tolerance
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_math_functions_2.expected
*/
// IEEE 1800-2023 Section 20.8 - Math functions
// Tests: $sin, $cos, $tan, $asin, $acos, $atan, $sinh, $cosh, $tanh
// Tests: $asinh, $acosh, $atanh, $atan2, $hypot
// Tests: $sqrt, $pow, $exp, $log10, $ln
// Tests: $ceil, $floor
module test_math_functions_2;
    real r, r1, r2;
    int passed = 0;
    int failed = 0;

    initial begin
        // Trigonometric functions
        r = $sin(0.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        r = $cos(0.0);
        if (r > 1.0 - 1e-9 && r < 1.0 + 1e-9) passed++; else failed++;

        r = $tan(0.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        // Inverse trigonometric functions
        r = $asin(0.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        r = $acos(1.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        r = $atan(0.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        r = $atan2(0.0, 1.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        // Hyperbolic functions
        r = $sinh(0.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        r = $cosh(0.0);
        if (r > 1.0 - 1e-9 && r < 1.0 + 1e-9) passed++; else failed++;

        r = $tanh(0.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        // Inverse hyperbolic functions
        r = $asinh(0.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        r = $acosh(1.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        r = $atanh(0.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        // Exponential and logarithmic functions
        r = $exp(0.0);
        if (r > 1.0 - 1e-9 && r < 1.0 + 1e-9) passed++; else failed++;

        r = $ln(1.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        r = $log10(1.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        // Power and root functions
        r = $sqrt(4.0);
        if (r == 2.0) passed++; else failed++;

        r = $pow(2.0, 3.0);
        if (r > 8.0 - 1e-9 && r < 8.0 + 1e-9) passed++; else failed++;

        r = $hypot(3.0, 4.0);
        if (r > 5.0 - 1e-9 && r < 5.0 + 1e-9) passed++; else failed++;

        // Rounding functions
        r = $ceil(1.1);
        if (r == 2.0) passed++; else failed++;

        r = $floor(1.9);
        if (r == 1.0) passed++; else failed++;

        // Edge cases
        r = $sqrt(0.0);
        if (r == 0.0) passed++; else failed++;

        r = $pow(0.0, 1.0);
        if (r > 0.0 - 1e-9 && r < 0.0 + 1e-9) passed++; else failed++;

        r = $pow(1.0, 0.0);
        if (r > 1.0 - 1e-9 && r < 1.0 + 1e-9) passed++; else failed++;

        // Special values
        r = $sin(3.14159265358979 / 2.0);
        if (r > 0.99 && r < 1.01) passed++; else failed++;

        r = $cos(3.14159265358979);
        if (r > -1.01 && r < -0.99) passed++; else failed++;

        // Report results
        if (failed == 0)
            $display("PASS: All %0d math function tests passed", passed);
        else
            $display("FAIL: %0d passed, %0d failed", passed, failed);

        $finish;
    end
endmodule
