/*
:name: test_param_pass_edge_cases
:description: Test: Parameter passing edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 13.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_pass_edge_cases.expected
*/
// Test: Parameter passing edge cases
// IEEE 1800-2023 Section 13.5 Subroutine calls and argument passing
// Tests corner cases: function parameter passing

`timescale 1ns/1ps

module test_param_pass_edge_cases;
    int passed = 0;
    int failed = 0;

    function int add_vals(int a, int b);
        return a + b;
    endfunction

    function int multiply_vals(int a, int b);
        return a * b;
    endfunction

    function void set_output(input int in_val, output int out_val);
        out_val = in_val * 3;
    endfunction

    function int compute(int x, int y, int z);
        return x + y * z;
    endfunction

    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    function int abs_val(int x);
        return (x < 0) ? -x : x;
    endfunction

    initial begin
        int val, out;

        $display("TEST: Parameter passing edge cases");

        // Test 1: Input parameters
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add_vals(3, 4);
            if (result == 7) begin
                $display("  [PASS] Input parameters");
                passed++;
            end else begin
                $display("  [FAIL] Input: %0d", result);
                failed++;
            end
        end

        // Test 2: Multiply function
        begin
            static int result = multiply_vals(5, 6);
            if (result == 30) begin
                $display("  [PASS] Multiply function");
                passed++;
            end else begin
                $display("  [FAIL] Mul: %0d", result);
                failed++;
            end
        end

        // Test 3: Output parameter
        begin
            set_output(7, out);
            if (out == 21) begin
                $display("  [PASS] Output parameter");
                passed++;
            end else begin
                $display("  [FAIL] Output: %0d", out);
                failed++;
            end
        end

        // Test 4: Multiple parameters
        begin
            static int result = compute(1, 2, 3);
            if (result == 7) begin  // 1 + 2*3
                $display("  [PASS] Multiple parameters");
                passed++;
            end else begin
                $display("  [FAIL] Multi: %0d", result);
                failed++;
            end
        end

        // Test 5: Multiple calls same function
        begin
            static int r1;
            static int r2;
            // Assigned here so the result does not depend on the order of static initializers.
            r1 = add_vals(1, 2);
            r2 = add_vals(10, 20);
            if (r1 == 3 && r2 == 30) begin
                $display("  [PASS] Multiple calls");
                passed++;
            end else begin
                $display("  [FAIL] MultiCall: %0d, %0d", r1, r2);
                failed++;
            end
        end

        // Test 6: Nested function calls
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add_vals(add_vals(1, 2), add_vals(3, 4));
            if (result == 10) begin
                $display("  [PASS] Nested calls");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0d", result);
                failed++;
            end
        end

        // Test 7: Expression as argument
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add_vals(2 * 3, 4 + 5);
            if (result == 15) begin
                $display("  [PASS] Expression argument");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", result);
                failed++;
            end
        end

        // Test 8: Recursive function
        begin
            static int result = factorial(5);
            if (result == 120) begin
                $display("  [PASS] Recursive function");
                passed++;
            end else begin
                $display("  [FAIL] Recursive: %0d", result);
                failed++;
            end
        end

        // Test 9: Conditional in function
        begin
            static int result = abs_val(-42);
            if (result == 42) begin
                $display("  [PASS] Conditional function");
                passed++;
            end else begin
                $display("  [FAIL] Cond: %0d", result);
                failed++;
            end
        end

        // Test 10: Zero and negative values
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add_vals(-5, 5);
            if (result == 0) begin
                $display("  [PASS] Zero result");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", result);
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
