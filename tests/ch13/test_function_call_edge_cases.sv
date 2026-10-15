/*
:name: test_function_call_edge_cases
:description: Test: Function call edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_call_edge_cases.expected
*/
// Test: Function call edge cases
// IEEE 1800-2023 Section 13.4 Functions
// Tests corner cases: function calls

`timescale 1ns/1ps

module test_function_call_edge_cases;
    int passed = 0;
    int failed = 0;

    // Simple add function
    function int add(int a, int b);
        return a + b;
    endfunction

    // Multiply function
    function int multiply(int a, int b);
        return a * b;
    endfunction

    // Max function
    function int max(int a, int b);
        return (a > b) ? a : b;
    endfunction

    // Abs function
    function int abs_val(int a);
        return (a < 0) ? -a : a;
    endfunction

    // Square function
    function int square(int a);
        return a * a;
    endfunction

    initial begin
        $display("TEST: Function call edge cases");

        // Test 1: Simple function call
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add(3, 4);
            if (result == 7) begin
                $display("  [PASS] Simple function call");
                passed++;
            end else begin
                $display("  [FAIL] Simple: %0d", result);
                failed++;
            end
        end

        // Test 2: Function with zero
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add(5, 0);
            if (result == 5) begin
                $display("  [PASS] Function with zero");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", result);
                failed++;
            end
        end

        // Test 3: Function with negative
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add(-3, 8);
            if (result == 5) begin
                $display("  [PASS] Function with negative");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %0d", result);
                failed++;
            end
        end

        // Test 4: Multiply function
        begin
            static int result = multiply(6, 7);
            if (result == 42) begin
                $display("  [PASS] Multiply function");
                passed++;
            end else begin
                $display("  [FAIL] Mult: %0d", result);
                failed++;
            end
        end

        // Test 5: Max function
        begin
            static int result = max(10, 20);
            if (result == 20) begin
                $display("  [PASS] Max function");
                passed++;
            end else begin
                $display("  [FAIL] Max: %0d", result);
                failed++;
            end
        end

        // Test 6: Abs function
        begin
            static int result = abs_val(-15);
            if (result == 15) begin
                $display("  [PASS] Abs function");
                passed++;
            end else begin
                $display("  [FAIL] Abs: %0d", result);
                failed++;
            end
        end

        // Test 7: Function in expression
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add(10, multiply(2, 3));
            if (result == 16) begin
                $display("  [PASS] Function in expression");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", result);
                failed++;
            end
        end

        // Test 8: Square function
        begin
            static int result = square(5);
            if (result == 25) begin
                $display("  [PASS] Square function");
                passed++;
            end else begin
                $display("  [FAIL] Square: %0d", result);
                failed++;
            end
        end

        // Test 9: Chained function calls
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = max(add(1, 2), add(3, 4));
            if (result == 7) begin
                $display("  [PASS] Chained function calls");
                passed++;
            end else begin
                $display("  [FAIL] Chain: %0d", result);
                failed++;
            end
        end

        // Test 10: Function with variable args
        begin
            static int a = 10;
            static int b = 20;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add(a, b);
            if (result == 30) begin
                $display("  [PASS] Function with variable args");
                passed++;
            end else begin
                $display("  [FAIL] VarArgs: %0d", result);
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
