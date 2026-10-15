/*
:name: test_mod_ops_edge_cases
:description: Modulus operator on constants and variables
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mod_ops_edge_cases.expected
*/
// Modulus operator on constants and variables
// IEEE 1800-2023 Section 11.4.3 Arithmetic operators
// Tests corner cases: modulus operations

`timescale 1ns/1ps

module test_mod_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        int a, b, result;

        $display("TEST: Modulus operator edge cases");

        // Test 1: Basic modulus
        begin
            result = 10 % 3;
            if (result == 1) begin
                $display("  [PASS] Basic modulus");
                passed++;
            end else begin
                $display("  [FAIL] Basic: %0d", result);
                failed++;
            end
        end

        // Test 2: Modulus with zero remainder
        begin
            result = 12 % 4;
            if (result == 0) begin
                $display("  [PASS] Modulus with zero remainder");
                passed++;
            end else begin
                $display("  [FAIL] ZeroRem: %0d", result);
                failed++;
            end
        end

        // Test 3: Modulus small by large
        begin
            result = 5 % 10;
            if (result == 5) begin
                $display("  [PASS] Modulus small by large");
                passed++;
            end else begin
                $display("  [FAIL] SmallLarge: %0d", result);
                failed++;
            end
        end

        // Test 4: Modulus by 2
        begin
            result = 15 % 2;
            if (result == 1) begin
                $display("  [PASS] Modulus by 2");
                passed++;
            end else begin
                $display("  [FAIL] Mod2: %0d", result);
                failed++;
            end
        end

        // Test 5: Even number mod 2
        begin
            result = 16 % 2;
            if (result == 0) begin
                $display("  [PASS] Even number mod 2");
                passed++;
            end else begin
                $display("  [FAIL] EvenMod2: %0d", result);
                failed++;
            end
        end

        // Test 6: Modulus by 1
        begin
            result = 100 % 1;
            if (result == 0) begin
                $display("  [PASS] Modulus by 1");
                passed++;
            end else begin
                $display("  [FAIL] Mod1: %0d", result);
                failed++;
            end
        end

        // Test 7: Large modulus
        begin
            result = 1000 % 7;
            if (result == 6) begin
                $display("  [PASS] Large modulus");
                passed++;
            end else begin
                $display("  [FAIL] Large: %0d", result);
                failed++;
            end
        end

        // Test 8: Power of 2 modulus
        begin
            result = 255 % 16;
            if (result == 15) begin
                $display("  [PASS] Power of 2 modulus");
                passed++;
            end else begin
                $display("  [FAIL] Pow2Mod: %0d", result);
                failed++;
            end
        end

        // Test 9: Variable modulus
        begin
            a = 100;
            b = 7;
            result = a % b;
            if (result == 2) begin
                $display("  [PASS] Variable modulus");
                passed++;
            end else begin
                $display("  [FAIL] VarMod: %0d", result);
                failed++;
            end
        end

        // Test 10: Chained modulus
        begin
            result = (100 % 17) % 5;
            // 100 % 17 = 15, 15 % 5 = 0
            if (result == 0) begin
                $display("  [PASS] Chained modulus");
                passed++;
            end else begin
                $display("  [FAIL] Chain: %0d", result);
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
