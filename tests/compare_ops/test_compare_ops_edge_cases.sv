/*
:name: test_compare_ops_edge_cases
:description: Test: Comparison operators edge cases
:tags: compare_ops
:type: simulation
:lrm: 1800-2023 11.4.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_compare_ops_edge_cases.expected
*/
// Test: Comparison operators edge cases
// IEEE 1800-2023 Section 11.4.4 Relational operators
// Tests corner cases: comparison operations

`timescale 1ns/1ps

module test_compare_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        int a, b;
        logic result;

        $display("TEST: Comparison operators edge cases");

        // Test 1: Less than true
        begin
            a = 5;
            b = 10;
            result = a < b;
            if (result == 1) begin
                $display("  [PASS] Less than true");
                passed++;
            end else begin
                $display("  [FAIL] LtTrue: %0b", result);
                failed++;
            end
        end

        // Test 2: Less than false
        begin
            a = 10;
            b = 5;
            result = a < b;
            if (result == 0) begin
                $display("  [PASS] Less than false");
                passed++;
            end else begin
                $display("  [FAIL] LtFalse: %0b", result);
                failed++;
            end
        end

        // Test 3: Greater than true
        begin
            a = 10;
            b = 5;
            result = a > b;
            if (result == 1) begin
                $display("  [PASS] Greater than true");
                passed++;
            end else begin
                $display("  [FAIL] GtTrue: %0b", result);
                failed++;
            end
        end

        // Test 4: Greater than false
        begin
            a = 5;
            b = 10;
            result = a > b;
            if (result == 0) begin
                $display("  [PASS] Greater than false");
                passed++;
            end else begin
                $display("  [FAIL] GtFalse: %0b", result);
                failed++;
            end
        end

        // Test 5: Less or equal true (less)
        begin
            a = 5;
            b = 10;
            result = a <= b;
            if (result == 1) begin
                $display("  [PASS] Less or equal true (less)");
                passed++;
            end else begin
                $display("  [FAIL] LeLess: %0b", result);
                failed++;
            end
        end

        // Test 6: Less or equal true (equal)
        begin
            a = 10;
            b = 10;
            result = a <= b;
            if (result == 1) begin
                $display("  [PASS] Less or equal true (equal)");
                passed++;
            end else begin
                $display("  [FAIL] LeEqual: %0b", result);
                failed++;
            end
        end

        // Test 7: Greater or equal true (greater)
        begin
            a = 10;
            b = 5;
            result = a >= b;
            if (result == 1) begin
                $display("  [PASS] Greater or equal true (greater)");
                passed++;
            end else begin
                $display("  [FAIL] GeGreater: %0b", result);
                failed++;
            end
        end

        // Test 8: Greater or equal true (equal)
        begin
            a = 10;
            b = 10;
            result = a >= b;
            if (result == 1) begin
                $display("  [PASS] Greater or equal true (equal)");
                passed++;
            end else begin
                $display("  [FAIL] GeEqual: %0b", result);
                failed++;
            end
        end

        // Test 9: Compare with negative
        begin
            a = -5;
            b = 5;
            result = a < b;
            if (result == 1) begin
                $display("  [PASS] Compare with negative");
                passed++;
            end else begin
                $display("  [FAIL] Negative: %0b", result);
                failed++;
            end
        end

        // Test 10: Compare zeros
        begin
            a = 0;
            b = 0;
            result = a <= b && a >= b;
            if (result == 1) begin
                $display("  [PASS] Compare zeros");
                passed++;
            end else begin
                $display("  [FAIL] Zeros: %0b", result);
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
