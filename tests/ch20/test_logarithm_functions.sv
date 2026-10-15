/*
:name: test_logarithm_functions
:description: Logarithm Functions Test
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logarithm_functions.expected
*/
// IEEE 1800-2023 Logarithm Functions Test
// Target: $ln, $log10, $exp - Logarithm and exponential functions
// IEEE 1800-2023 Section 20.8.2

`timescale 1ns/1ps

module test_logarithm_functions;
    int pass_count = 0;
    int fail_count = 0;

    // Helper task with tolerance for floating-point comparison
    task automatic check_real(input string name, input real actual, input real expected, input real tolerance);
        real diff;
        diff = actual - expected;
        if (diff < 0) diff = -diff;
        if (diff <= tolerance) begin
            $display("  PASS: %s (actual=%0.6f, expected=%0.6f)", name, actual, expected);
            pass_count++;
        end else begin
            $display("  FAIL: %s (actual=%0.6f, expected=%0.6f, diff=%0.6f)", name, actual, expected, diff);
            fail_count++;
        end
    endtask

    task automatic check(input string name, input bit condition);
        if (condition) begin
            $display("  PASS: %s", name);
            pass_count++;
        end else begin
            $display("  FAIL: %s", name);
            fail_count++;
        end
    endtask

    initial begin
        real result;
        real e_val;

        $display("=== Logarithm Functions Test ===");
        $display("");

        // Get e value for testing
        e_val = $exp(1.0);
        $display("Note: e = $exp(1.0) = %0.10f", e_val);
        $display("");

        // ===== Test 1: Natural logarithm $ln =====
        $display("Test 1: Natural logarithm ($ln)");

        result = $ln(1.0);
        check_real("$ln(1.0) = 0", result, 0.0, 0.0001);

        result = $ln(e_val);
        check_real("$ln(e) = 1", result, 1.0, 0.0001);

        result = $ln(e_val * e_val);
        check_real("$ln(e^2) = 2", result, 2.0, 0.0001);

        result = $ln(10.0);
        check_real("$ln(10) ≈ 2.3026", result, 2.302585, 0.0001);

        // ===== Test 2: Common logarithm $log10 =====
        $display("");
        $display("Test 2: Common logarithm ($log10)");

        result = $log10(1.0);
        check_real("$log10(1.0) = 0", result, 0.0, 0.0001);

        result = $log10(10.0);
        check_real("$log10(10) = 1", result, 1.0, 0.0001);

        result = $log10(100.0);
        check_real("$log10(100) = 2", result, 2.0, 0.0001);

        result = $log10(1000.0);
        check_real("$log10(1000) = 3", result, 3.0, 0.0001);

        result = $log10(2.0);
        check_real("$log10(2) ≈ 0.3010", result, 0.30103, 0.0001);

        // ===== Test 3: Exponential function $exp =====
        $display("");
        $display("Test 3: Exponential function ($exp)");

        result = $exp(0.0);
        check_real("$exp(0) = 1", result, 1.0, 0.0001);

        result = $exp(1.0);
        check_real("$exp(1) = e ≈ 2.7183", result, 2.71828, 0.0001);

        result = $exp(2.0);
        check_real("$exp(2) ≈ 7.389", result, 7.38906, 0.001);

        result = $exp(-1.0);
        check_real("$exp(-1) ≈ 0.3679", result, 0.36788, 0.0001);

        // ===== Test 4: Identity relationships =====
        $display("");
        $display("Test 4: Identity relationships");

        result = $exp($ln(5.0));
        check_real("$exp($ln(5)) = 5", result, 5.0, 0.0001);

        result = $ln($exp(3.0));
        check_real("$ln($exp(3)) = 3", result, 3.0, 0.0001);

        // ===== Test 5: Small and large values =====
        $display("");
        $display("Test 5: Small and large values");

        result = $ln(0.5);
        check_real("$ln(0.5) ≈ -0.693", result, -0.69315, 0.0001);

        result = $exp(10.0);
        check_real("$exp(10) ≈ 22026", result, 22026.47, 1.0);

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
