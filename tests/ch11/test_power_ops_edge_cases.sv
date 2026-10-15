/*
:name: test_power_ops_edge_cases
:description: Power operator with exponents 0 and 1 and bases 0 and 1
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_power_ops_edge_cases.expected
*/
// Power operator with exponents 0 and 1 and bases 0 and 1
// IEEE 1800-2023 Section 11.4.3 Power operator
// Tests corner cases: power operations

`timescale 1ns/1ps

module test_power_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    int a, b, result;
    real rresult;

    initial begin
        $display("TEST: Power operations edge cases");

        // Test 1: Simple power
        begin
            a = 2;
            b = 3;
            result = a ** b;
            if (result == 8) begin
                $display("  [PASS] Simple power");
                passed++;
            end else begin
                $display("  [FAIL] Pow: %0d", result);
                failed++;
            end
        end

        // Test 2: Power of 2
        begin
            result = 2 ** 4;
            if (result == 16) begin
                $display("  [PASS] Power of 2");
                passed++;
            end else begin
                $display("  [FAIL] Pow2: %0d", result);
                failed++;
            end
        end

        // Test 3: Power of 0
        begin
            a = 5;
            result = a ** 0;
            if (result == 1) begin
                $display("  [PASS] Power of 0");
                passed++;
            end else begin
                $display("  [FAIL] Pow0: %0d", result);
                failed++;
            end
        end

        // Test 4: Power of 1
        begin
            a = 7;
            result = a ** 1;
            if (result == 7) begin
                $display("  [PASS] Power of 1");
                passed++;
            end else begin
                $display("  [FAIL] Pow1: %0d", result);
                failed++;
            end
        end

        // Test 5: Base 0
        begin
            result = 0 ** 5;
            if (result == 0) begin
                $display("  [PASS] Base 0");
                passed++;
            end else begin
                $display("  [FAIL] Base0: %0d", result);
                failed++;
            end
        end

        // Test 6: Base 1
        begin
            result = 1 ** 100;
            if (result == 1) begin
                $display("  [PASS] Base 1");
                passed++;
            end else begin
                $display("  [FAIL] Base1: %0d", result);
                failed++;
            end
        end

        // Test 7: Square
        begin
            a = 5;
            result = a ** 2;
            if (result == 25) begin
                $display("  [PASS] Square");
                passed++;
            end else begin
                $display("  [FAIL] Sq: %0d", result);
                failed++;
            end
        end

        // Test 8: Cube
        begin
            a = 3;
            result = a ** 3;
            if (result == 27) begin
                $display("  [PASS] Cube");
                passed++;
            end else begin
                $display("  [FAIL] Cube: %0d", result);
                failed++;
            end
        end

        // Test 9: Power of 10
        begin
            result = 10 ** 3;
            if (result == 1000) begin
                $display("  [PASS] Power of 10");
                passed++;
            end else begin
                $display("  [FAIL] Pow10: %0d", result);
                failed++;
            end
        end

        // Test 10: Large power
        begin
            result = 2 ** 10;
            if (result == 1024) begin
                $display("  [PASS] Large power");
                passed++;
            end else begin
                $display("  [FAIL] LargePow: %0d", result);
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
