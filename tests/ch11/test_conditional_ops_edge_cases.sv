/*
:name: test_conditional_ops_edge_cases
:description: Test: Conditional operations edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_ops_edge_cases.expected
*/
// Test: Conditional operations edge cases
// IEEE 1800-2023 Section 11.4.11 Conditional operator
// Tests corner cases: conditional/ternary operations

`timescale 1ns/1ps

module test_conditional_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    int a, b, result;
    logic cond;
    logic [7:0] val8;

    initial begin
        $display("TEST: Conditional operations edge cases");

        // Test 1: True condition
        begin
            cond = 1'b1;
            result = cond ? 10 : 20;
            if (result == 10) begin
                $display("  [PASS] True condition");
                passed++;
            end else begin
                $display("  [FAIL] True: %0d", result);
                failed++;
            end
        end

        // Test 2: False condition
        begin
            cond = 1'b0;
            result = cond ? 10 : 20;
            if (result == 20) begin
                $display("  [PASS] False condition");
                passed++;
            end else begin
                $display("  [FAIL] False: %0d", result);
                failed++;
            end
        end

        // Test 3: Expression condition
        begin
            a = 5;
            b = 3;
            result = (a > b) ? a : b;
            if (result == 5) begin
                $display("  [PASS] Expression condition");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", result);
                failed++;
            end
        end

        // Test 4: Nested conditional
        begin
            a = 2;
            result = (a == 1) ? 10 : (a == 2) ? 20 : 30;
            if (result == 20) begin
                $display("  [PASS] Nested conditional");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0d", result);
                failed++;
            end
        end

        // Test 5: Min function
        begin
            a = 15;
            b = 8;
            result = (a < b) ? a : b;
            if (result == 8) begin
                $display("  [PASS] Min function");
                passed++;
            end else begin
                $display("  [FAIL] Min: %0d", result);
                failed++;
            end
        end

        // Test 6: Max function
        begin
            a = 15;
            b = 8;
            result = (a > b) ? a : b;
            if (result == 15) begin
                $display("  [PASS] Max function");
                passed++;
            end else begin
                $display("  [FAIL] Max: %0d", result);
                failed++;
            end
        end

        // Test 7: Absolute value
        begin
            a = -5;
            result = (a < 0) ? -a : a;
            if (result == 5) begin
                $display("  [PASS] Absolute value");
                passed++;
            end else begin
                $display("  [FAIL] Abs: %0d", result);
                failed++;
            end
        end

        // Test 8: Conditional with vectors
        begin
            cond = 1'b1;
            val8 = cond ? 8'hAA : 8'h55;
            if (val8 == 8'hAA) begin
                $display("  [PASS] Conditional with vectors");
                passed++;
            end else begin
                $display("  [FAIL] Vec: %h", val8);
                failed++;
            end
        end

        // Test 9: Chained conditional
        begin
            a = 3;
            result = (a == 1) ? 100 :
                     (a == 2) ? 200 :
                     (a == 3) ? 300 : 400;
            if (result == 300) begin
                $display("  [PASS] Chained conditional");
                passed++;
            end else begin
                $display("  [FAIL] Chain: %0d", result);
                failed++;
            end
        end

        // Test 10: Conditional as LHS value
        begin
            a = 10;
            b = 20;
            cond = 1'b0;
            result = cond ? a * 2 : b * 2;
            if (result == 40) begin
                $display("  [PASS] Conditional as LHS value");
                passed++;
            end else begin
                $display("  [FAIL] LHS: %0d", result);
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
