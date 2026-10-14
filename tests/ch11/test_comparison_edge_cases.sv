/*
:name: test_comparison_edge_cases
:description: Test: Comparison operators edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comparison_edge_cases.expected
*/
// Test: Comparison operators edge cases
// IEEE 1800-2023 Section 11.4.4-5 Relational and Equality Operators
// Tests corner cases: ==, !=, <, >, <=, >=

`timescale 1ns/1ps

module test_comparison_edge_cases;
    int passed = 0;
    int failed = 0;

    int a, b;
    logic [7:0] x, y;

    initial begin
        $display("TEST: Comparison operators edge cases");

        // Test 1: Equal
        begin
            a = 100;
            b = 100;
            if (a == b) begin
                $display("  [PASS] Equal");
                passed++;
            end else begin
                $display("  [FAIL] Equal");
                failed++;
            end
        end

        // Test 2: Not equal
        begin
            a = 100;
            b = 200;
            if (a != b) begin
                $display("  [PASS] Not equal");
                passed++;
            end else begin
                $display("  [FAIL] NotEq");
                failed++;
            end
        end

        // Test 3: Less than
        begin
            a = 50;
            b = 100;
            if (a < b) begin
                $display("  [PASS] Less than");
                passed++;
            end else begin
                $display("  [FAIL] LT");
                failed++;
            end
        end

        // Test 4: Greater than
        begin
            a = 200;
            b = 100;
            if (a > b) begin
                $display("  [PASS] Greater than");
                passed++;
            end else begin
                $display("  [FAIL] GT");
                failed++;
            end
        end

        // Test 5: Less than or equal
        begin
            a = 100;
            b = 100;
            if (a <= b) begin
                $display("  [PASS] Less or equal");
                passed++;
            end else begin
                $display("  [FAIL] LE");
                failed++;
            end
        end

        // Test 6: Greater than or equal
        begin
            a = 100;
            b = 100;
            if (a >= b) begin
                $display("  [PASS] Greater or equal");
                passed++;
            end else begin
                $display("  [FAIL] GE");
                failed++;
            end
        end

        // Test 7: Negative comparison
        begin
            a = -10;
            b = -5;
            if (a < b) begin
                $display("  [PASS] Negative comparison");
                passed++;
            end else begin
                $display("  [FAIL] Neg");
                failed++;
            end
        end

        // Test 8: Zero comparison
        begin
            a = 0;
            b = 0;
            if (a == b && !(a > b) && !(a < b)) begin
                $display("  [PASS] Zero comparison");
                passed++;
            end else begin
                $display("  [FAIL] Zero");
                failed++;
            end
        end

        // Test 9: Logic comparison
        begin
            x = 8'hAB;
            y = 8'hAB;
            if (x == y) begin
                $display("  [PASS] Logic comparison");
                passed++;
            end else begin
                $display("  [FAIL] Logic");
                failed++;
            end
        end

        // Test 10: Chained comparison
        begin
            a = 50;
            if (a > 40 && a < 60) begin
                $display("  [PASS] Chained comparison");
                passed++;
            end else begin
                $display("  [FAIL] Chain");
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
