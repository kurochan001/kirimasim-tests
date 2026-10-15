/*
:name: test_expressions_edge_cases
:description: Test: Expressions edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 11.4.7 11.4.11 11.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expressions_edge_cases.expected
*/
// Test: Expressions edge cases
// IEEE 1800-2023 Section 11 Expressions
// Tests corner cases: operator precedence, type coercion, complex expressions

`timescale 1ns/1ps

module test_expressions_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Expressions edge cases");

        // Test 1: Operator precedence (* before +)
        begin
            static int result = 2 + 3 * 4;
            if (result == 14) begin
                $display("  [PASS] Precedence: 2+3*4 = 14");
                passed++;
            end else begin
                $display("  [FAIL] Precedence: %0d", result);
                failed++;
            end
        end

        // Test 2: Parentheses override precedence
        begin
            static int result = (2 + 3) * 4;
            if (result == 20) begin
                $display("  [PASS] Parentheses: (2+3)*4 = 20");
                passed++;
            end else begin
                $display("  [FAIL] Parens: %0d", result);
                failed++;
            end
        end

        // Test 3: Mixed signed/unsigned
        begin
            static logic [7:0] unsigned_val = 8'hFF;  // 255
            static int signed_val = -1;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = signed_val + int'(unsigned_val);
            if (result == 254) begin
                $display("  [PASS] Mixed signed/unsigned");
                passed++;
            end else begin
                $display("  [FAIL] Mixed: %0d", result);
                failed++;
            end
        end

        // Test 4: Short-circuit evaluation
        begin
            static int a = 0;
            static int b = 0;
            // In && evaluation, if first is false, second not evaluated
            if (a != 0 && (b = 1)) begin
                // Won't reach here
            end
            if (b == 0) begin
                $display("  [PASS] Short-circuit &&");
                passed++;
            end else begin
                $display("  [FAIL] Short-circuit");
                failed++;
            end
        end

        // Test 5: Comparison chain
        begin
            static int a = 5;
            if (0 < a && a < 10) begin
                $display("  [PASS] Range check 0 < 5 < 10");
                passed++;
            end else begin
                $display("  [FAIL] Range check");
                failed++;
            end
        end

        // Test 6: Ternary nested
        begin
            static int val = 2;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = (val == 1) ? 10 : (val == 2) ? 20 : 30;
            if (result == 20) begin
                $display("  [PASS] Nested ternary");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0d", result);
                failed++;
            end
        end

        // Test 7: Assignment in expression
        begin
            static int a = 0;
            static int b = 0;
            b = (a = 5);
            if (a == 5 && b == 5) begin
                $display("  [PASS] Assignment expression");
                passed++;
            end else begin
                $display("  [FAIL] Assign expr");
                failed++;
            end
        end

        // Test 8: Increment operators
        begin
            static int x = 5;
            static int pre;
            static int post;
            // Assigned here so the result does not depend on the order of static initializers.
            pre = ++x;  // x=6, pre=6
            post = x++;  // post=6, x=7
            if (pre == 6 && post == 6 && x == 7) begin
                $display("  [PASS] Increment operators");
                passed++;
            end else begin
                $display("  [FAIL] Increment");
                failed++;
            end
        end

        // Test 9: Decrement operators
        begin
            static int x = 5;
            static int pre;
            static int post;
            // Assigned here so the result does not depend on the order of static initializers.
            pre = --x;  // x=4, pre=4
            post = x--;  // post=4, x=3
            if (pre == 4 && post == 4 && x == 3) begin
                $display("  [PASS] Decrement operators");
                passed++;
            end else begin
                $display("  [FAIL] Decrement");
                failed++;
            end
        end

        // Test 10: Unary minus
        begin
            static int a = 10;
            static int b;
            static int c;
            // Assigned here so the result does not depend on the order of static initializers.
            b = -a;
            c = -(-a);
            if (b == -10 && c == 10) begin
                $display("  [PASS] Unary minus");
                passed++;
            end else begin
                $display("  [FAIL] Unary");
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
