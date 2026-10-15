/*
:name: test_ternary_ops_edge_cases
:description: Conditional operator on int and vector operands
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ternary_ops_edge_cases.expected
*/
// Conditional operator on int and vector operands
// IEEE 1800-2023 Section 11.4.11 Conditional operator
// Tests corner cases: ternary operator operations

`timescale 1ns/1ps

module test_ternary_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        int a, b, result;
        logic cond;
        logic [7:0] byte_a, byte_b, byte_r;

        $display("TEST: Ternary/conditional operator edge cases");

        // Test 1: Basic true condition
        begin
            cond = 1;
            result = cond ? 10 : 20;
            if (result == 10) begin
                $display("  [PASS] Basic true condition");
                passed++;
            end else begin
                $display("  [FAIL] TrueCond: %0d", result);
                failed++;
            end
        end

        // Test 2: Basic false condition
        begin
            cond = 0;
            result = cond ? 10 : 20;
            if (result == 20) begin
                $display("  [PASS] Basic false condition");
                passed++;
            end else begin
                $display("  [FAIL] FalseCond: %0d", result);
                failed++;
            end
        end

        // Test 3: Expression condition
        begin
            a = 5;
            b = 3;
            result = (a > b) ? 100 : 200;
            if (result == 100) begin
                $display("  [PASS] Expression condition");
                passed++;
            end else begin
                $display("  [FAIL] ExprCond: %0d", result);
                failed++;
            end
        end

        // Test 4: Nested ternary
        begin
            a = 2;
            result = (a == 1) ? 10 : (a == 2) ? 20 : 30;
            if (result == 20) begin
                $display("  [PASS] Nested ternary");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0d", result);
                failed++;
            end
        end

        // Test 5: Ternary with variables
        begin
            a = 50;
            b = 100;
            cond = 1;
            result = cond ? a : b;
            if (result == 50) begin
                $display("  [PASS] Ternary with variables");
                passed++;
            end else begin
                $display("  [FAIL] VarTern: %0d", result);
                failed++;
            end
        end

        // Test 6: Ternary in expression
        begin
            a = 5;
            b = 10;
            result = (a < b ? a : b) + 5;
            if (result == 10) begin
                $display("  [PASS] Ternary in expression");
                passed++;
            end else begin
                $display("  [FAIL] TernExpr: %0d", result);
                failed++;
            end
        end

        // Test 7: Ternary byte values
        begin
            byte_a = 8'hAA;
            byte_b = 8'h55;
            byte_r = 1 ? byte_a : byte_b;
            if (byte_r == 8'hAA) begin
                $display("  [PASS] Ternary byte values");
                passed++;
            end else begin
                $display("  [FAIL] ByteTern: %0h", byte_r);
                failed++;
            end
        end

        // Test 8: Zero condition
        begin
            a = 0;
            result = a ? 1 : 2;
            if (result == 2) begin
                $display("  [PASS] Zero condition");
                passed++;
            end else begin
                $display("  [FAIL] ZeroCond: %0d", result);
                failed++;
            end
        end

        // Test 9: Non-zero condition
        begin
            a = 5;
            result = a ? 1 : 2;
            if (result == 1) begin
                $display("  [PASS] Non-zero condition");
                passed++;
            end else begin
                $display("  [FAIL] NonZero: %0d", result);
                failed++;
            end
        end

        // Test 10: Ternary assignment
        begin
            cond = 1;
            a = 0;
            a = cond ? 42 : a;
            if (a == 42) begin
                $display("  [PASS] Ternary assignment");
                passed++;
            end else begin
                $display("  [FAIL] TernAssign: %0d", a);
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
