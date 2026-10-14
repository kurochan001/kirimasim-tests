/*
:name: test_task_call_edge_cases
:description: Test: Task call edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_call_edge_cases.expected
*/
// Test: Task call edge cases
// IEEE 1800-2023 Section 13.3 Tasks
// Tests corner cases: task calls with multiple outputs

`timescale 1ns/1ps

module test_task_call_edge_cases;
    int passed = 0;
    int failed = 0;

    // Task with multiple outputs
    task compute_vals(int a, output int sum, output int diff, output int prod);
        sum = a + 10;
        diff = a - 5;
        prod = a * 2;
    endtask

    // Another multi-output task for variety
    task add_sub(int a, int b, output int sum, output int diff);
        sum = a + b;
        diff = a - b;
    endtask

    initial begin
        $display("TEST: Task call edge cases");

        // Test 1: Multi output basic
        begin
            int s, d, p;
            compute_vals(20, s, d, p);
            if (s == 30 && d == 15 && p == 40) begin
                $display("  [PASS] Multi output basic");
                passed++;
            end else begin
                $display("  [FAIL] Basic: s=%0d d=%0d p=%0d", s, d, p);
                failed++;
            end
        end

        // Test 2: Multi output with zero
        begin
            int s, d, p;
            compute_vals(0, s, d, p);
            if (s == 10 && d == -5 && p == 0) begin
                $display("  [PASS] Multi output with zero");
                passed++;
            end else begin
                $display("  [FAIL] Zero: s=%0d d=%0d p=%0d", s, d, p);
                failed++;
            end
        end

        // Test 3: Multi output with negative
        begin
            int s, d, p;
            compute_vals(-10, s, d, p);
            if (s == 0 && d == -15 && p == -20) begin
                $display("  [PASS] Multi output with negative");
                passed++;
            end else begin
                $display("  [FAIL] Neg: s=%0d d=%0d p=%0d", s, d, p);
                failed++;
            end
        end

        // Test 4: Add-sub task basic
        begin
            int sum, diff;
            add_sub(10, 3, sum, diff);
            if (sum == 13 && diff == 7) begin
                $display("  [PASS] Add-sub task basic");
                passed++;
            end else begin
                $display("  [FAIL] AddSub: sum=%0d diff=%0d", sum, diff);
                failed++;
            end
        end

        // Test 5: Add-sub with zeros
        begin
            int sum, diff;
            add_sub(0, 0, sum, diff);
            if (sum == 0 && diff == 0) begin
                $display("  [PASS] Add-sub with zeros");
                passed++;
            end else begin
                $display("  [FAIL] Zeros: sum=%0d diff=%0d", sum, diff);
                failed++;
            end
        end

        // Test 6: Sequential multi output
        begin
            int s1, d1, p1, s2, d2, p2;
            compute_vals(5, s1, d1, p1);
            compute_vals(10, s2, d2, p2);
            if (s1 + s2 == 35) begin
                $display("  [PASS] Sequential multi output");
                passed++;
            end else begin
                $display("  [FAIL] Seq: s1=%0d s2=%0d", s1, s2);
                failed++;
            end
        end

        // Test 7: Output sum check
        begin
            int s, d, p;
            compute_vals(15, s, d, p);
            if (s + d + p == 65) begin
                $display("  [PASS] Output sum check");
                passed++;
            end else begin
                $display("  [FAIL] Sum: %0d", s + d + p);
                failed++;
            end
        end

        // Test 8: Large values
        begin
            int s, d, p;
            compute_vals(1000, s, d, p);
            if (s == 1010 && d == 995 && p == 2000) begin
                $display("  [PASS] Large values");
                passed++;
            end else begin
                $display("  [FAIL] Large: s=%0d d=%0d p=%0d", s, d, p);
                failed++;
            end
        end

        // Test 9: Expression input
        begin
            int s, d, p;
            compute_vals(3 + 2, s, d, p);
            if (s == 15 && d == 0 && p == 10) begin
                $display("  [PASS] Expression input");
                passed++;
            end else begin
                $display("  [FAIL] Expr: s=%0d d=%0d p=%0d", s, d, p);
                failed++;
            end
        end

        // Test 10: Variable input
        begin
            static int x = 7;
            int s, d, p;
            compute_vals(x, s, d, p);
            if (s == 17 && d == 2 && p == 14) begin
                $display("  [PASS] Variable input");
                passed++;
            end else begin
                $display("  [FAIL] VarIn: s=%0d d=%0d p=%0d", s, d, p);
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
