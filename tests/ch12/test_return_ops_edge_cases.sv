/*
:name: test_return_ops_edge_cases
:description: Test: Return statement edge cases
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8 13.4.1 13.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_return_ops_edge_cases.expected
*/
// Test: Return statement edge cases
// IEEE 1800-2023 Section 12.8 Jump statements
// Tests corner cases: function return statements

`timescale 1ns/1ps

module test_return_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    // Test functions
    function int simple_return();
        return 42;
    endfunction

    function int conditional_return(int x);
        if (x > 0) return x;
        return 0;
    endfunction

    function int early_return(int x);
        if (x < 0) return -1;
        if (x == 0) return 0;
        return x;
    endfunction

    function int loop_return(int n);
        for (int i = 0; i < 100; i++) begin
            if (i == n) return i * 2;
        end
        return -1;
    endfunction

    // automatic: a recursive call needs its own copy of n (13.4.2)
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    function int sum_to(int n);
        static int s = 0;
        for (int i = 1; i <= n; i++) s += i;
        return s;
    endfunction

    initial begin
        int result;

        $display("TEST: Return statement edge cases");

        // Test 1: Simple return
        begin
            result = simple_return();
            if (result == 42) begin
                $display("  [PASS] Simple return");
                passed++;
            end else begin
                $display("  [FAIL] Simple: %0d", result);
                failed++;
            end
        end

        // Test 2: Conditional return positive
        begin
            result = conditional_return(10);
            if (result == 10) begin
                $display("  [PASS] Conditional return positive");
                passed++;
            end else begin
                $display("  [FAIL] CondPos: %0d", result);
                failed++;
            end
        end

        // Test 3: Conditional return zero
        begin
            result = conditional_return(-5);
            if (result == 0) begin
                $display("  [PASS] Conditional return zero");
                passed++;
            end else begin
                $display("  [FAIL] CondZero: %0d", result);
                failed++;
            end
        end

        // Test 4: Early return negative
        begin
            result = early_return(-10);
            if (result == -1) begin
                $display("  [PASS] Early return negative");
                passed++;
            end else begin
                $display("  [FAIL] EarlyNeg: %0d", result);
                failed++;
            end
        end

        // Test 5: Early return zero
        begin
            result = early_return(0);
            if (result == 0) begin
                $display("  [PASS] Early return zero");
                passed++;
            end else begin
                $display("  [FAIL] EarlyZero: %0d", result);
                failed++;
            end
        end

        // Test 6: Early return positive
        begin
            result = early_return(5);
            if (result == 5) begin
                $display("  [PASS] Early return positive");
                passed++;
            end else begin
                $display("  [FAIL] EarlyPos: %0d", result);
                failed++;
            end
        end

        // Test 7: Loop return
        begin
            result = loop_return(5);
            if (result == 10) begin
                $display("  [PASS] Loop return");
                passed++;
            end else begin
                $display("  [FAIL] Loop: %0d", result);
                failed++;
            end
        end

        // Test 8: Recursive return
        begin
            result = factorial(5);
            if (result == 120) begin
                $display("  [PASS] Recursive return");
                passed++;
            end else begin
                $display("  [FAIL] Recursive: %0d", result);
                failed++;
            end
        end

        // Test 9: Sum function
        begin
            result = sum_to(10);
            if (result == 55) begin
                $display("  [PASS] Sum function");
                passed++;
            end else begin
                $display("  [FAIL] Sum: %0d", result);
                failed++;
            end
        end

        // Test 10: Return in expression
        begin
            result = simple_return() + 8;
            if (result == 50) begin
                $display("  [PASS] Return in expression");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", result);
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
        $finish;
        end
    end
endmodule
