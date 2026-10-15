/*
:name: test_relational_ops_edge_cases
:description: Relational operators on equal, ordered and negative int values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_relational_ops_edge_cases.expected
*/
// Relational operators on equal, ordered and negative int values
// IEEE 1800-2023 Section 11.4.4 Relational operators
// Tests corner cases: relational operations

`timescale 1ns/1ps

module test_relational_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    int a, b;
    logic result;

    initial begin
        $display("TEST: Relational operations edge cases");

        // Test 1: Less than true
        begin
            a = 5;
            b = 10;
            result = (a < b);
            if (result == 1'b1) begin
                $display("  [PASS] Less than true");
                passed++;
            end else begin
                $display("  [FAIL] LT true: %b", result);
                failed++;
            end
        end

        // Test 2: Less than false
        begin
            a = 10;
            b = 5;
            result = (a < b);
            if (result == 1'b0) begin
                $display("  [PASS] Less than false");
                passed++;
            end else begin
                $display("  [FAIL] LT false: %b", result);
                failed++;
            end
        end

        // Test 3: Greater than true
        begin
            a = 20;
            b = 10;
            result = (a > b);
            if (result == 1'b1) begin
                $display("  [PASS] Greater than true");
                passed++;
            end else begin
                $display("  [FAIL] GT true: %b", result);
                failed++;
            end
        end

        // Test 4: Greater than false
        begin
            a = 5;
            b = 10;
            result = (a > b);
            if (result == 1'b0) begin
                $display("  [PASS] Greater than false");
                passed++;
            end else begin
                $display("  [FAIL] GT false: %b", result);
                failed++;
            end
        end

        // Test 5: Less than or equal (less)
        begin
            a = 5;
            b = 10;
            result = (a <= b);
            if (result == 1'b1) begin
                $display("  [PASS] Less than or equal (less)");
                passed++;
            end else begin
                $display("  [FAIL] LE less: %b", result);
                failed++;
            end
        end

        // Test 6: Less than or equal (equal)
        begin
            a = 10;
            b = 10;
            result = (a <= b);
            if (result == 1'b1) begin
                $display("  [PASS] Less than or equal (equal)");
                passed++;
            end else begin
                $display("  [FAIL] LE equal: %b", result);
                failed++;
            end
        end

        // Test 7: Greater than or equal (greater)
        begin
            a = 15;
            b = 10;
            result = (a >= b);
            if (result == 1'b1) begin
                $display("  [PASS] Greater than or equal (greater)");
                passed++;
            end else begin
                $display("  [FAIL] GE greater: %b", result);
                failed++;
            end
        end

        // Test 8: Greater than or equal (equal)
        begin
            a = 10;
            b = 10;
            result = (a >= b);
            if (result == 1'b1) begin
                $display("  [PASS] Greater than or equal (equal)");
                passed++;
            end else begin
                $display("  [FAIL] GE equal: %b", result);
                failed++;
            end
        end

        // Test 9: Negative comparison
        begin
            a = -5;
            b = 5;
            result = (a < b);
            if (result == 1'b1) begin
                $display("  [PASS] Negative comparison");
                passed++;
            end else begin
                $display("  [FAIL] Neg cmp: %b", result);
                failed++;
            end
        end

        // Test 10: Zero comparison
        begin
            a = 0;
            b = 0;
            result = (a >= b) && (a <= b);
            if (result == 1'b1) begin
                $display("  [PASS] Zero comparison");
                passed++;
            end else begin
                $display("  [FAIL] Zero cmp: %b", result);
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
