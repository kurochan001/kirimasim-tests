/*
:name: test_functions_tasks_edge_cases
:description: Test: Functions and Tasks edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4 13.5.2 13.5.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_functions_tasks_edge_cases.expected
*/
// Test: Functions and Tasks edge cases
// IEEE 1800-2023 Section 13 Tasks and Functions
// Tests corner cases: return values, arguments, automatic, recursion

`timescale 1ns/1ps

module test_functions_tasks_edge_cases;
    int passed = 0;
    int failed = 0;

    // Simple function
    function int add(int a, int b);
        return a + b;
    endfunction

    // Function with default argument
    function int multiply(int a, int b = 2);
        return a * b;
    endfunction

    // Recursive function
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        else return n * factorial(n - 1);
    endfunction

    // Function returning void (like task)
    function automatic void increment(ref int x);
        x++;
    endfunction

    // Task with delay
    task delay_task(input int cycles);
        repeat(cycles) #1;
    endtask

    // Task with output
    task compute(input int a, input int b, output int sum, output int prod);
        sum = a + b;
        prod = a * b;
    endtask

    initial begin
        $display("TEST: Functions and Tasks edge cases");

        // Test 1: Simple function call
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add(3, 4);
            if (result == 7) begin
                $display("  [PASS] Simple function call");
                passed++;
            end else begin
                $display("  [FAIL] Function: %0d", result);
                failed++;
            end
        end

        // Test 2: Function with default argument
        begin
            static int r1 = multiply(5);     // Uses default b=2
            static int r2 = multiply(5, 3);  // Override b=3
            if (r1 == 10 && r2 == 15) begin
                $display("  [PASS] Default argument");
                passed++;
            end else begin
                $display("  [FAIL] Default: %0d, %0d", r1, r2);
                failed++;
            end
        end

        // Test 3: Recursive function
        begin
            static int fact5 = factorial(5);
            if (fact5 == 120) begin
                $display("  [PASS] Recursive function (5! = 120)");
                passed++;
            end else begin
                $display("  [FAIL] Recursive: %0d", fact5);
                failed++;
            end
        end

        // Test 4: Function with ref argument
        begin
            static int x = 10;
            increment(x);
            if (x == 11) begin
                $display("  [PASS] Ref argument increment");
                passed++;
            end else begin
                $display("  [FAIL] Ref: %0d", x);
                failed++;
            end
        end

        // Test 5: Task call completes
        begin
            static int x = 0;
            int s, p;
            compute(2, 3, s, p);  // Just test task completes
            if (s == 5 && p == 6) begin
                $display("  [PASS] Task completes normally");
                passed++;
            end else begin
                $display("  [FAIL] Task completion");
                failed++;
            end
        end

        // Test 6: Task with output arguments
        begin
            int s, p;
            compute(4, 5, s, p);
            if (s == 9 && p == 20) begin
                $display("  [PASS] Task output arguments");
                passed++;
            end else begin
                $display("  [FAIL] Output: %0d, %0d", s, p);
                failed++;
            end
        end

        // Test 7: Function in expression
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add(1, 2) * add(3, 4);
            if (result == 21) begin
                $display("  [PASS] Function in expression");
                passed++;
            end else begin
                $display("  [FAIL] Expr: %0d", result);
                failed++;
            end
        end

        // Test 8: Nested function calls
        begin
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = add(add(1, 2), add(3, 4));
            if (result == 10) begin
                $display("  [PASS] Nested function calls");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %0d", result);
                failed++;
            end
        end

        // Test 9: Function in conditional
        begin
            static int cond = 1;
            static int result;
            // Assigned here so the result does not depend on the order of static initializers.
            result = cond ? add(1, 2) : add(3, 4);
            if (result == 3) begin
                $display("  [PASS] Function in conditional");
                passed++;
            end else begin
                $display("  [FAIL] Conditional: %0d", result);
                failed++;
            end
        end

        // Test 10: Multiple function calls in loop
        begin
            static int sum = 0;
            for (int i = 0; i < 3; i++) begin
                sum = add(sum, i);
            end
            if (sum == 3) begin
                $display("  [PASS] Function calls in loop");
                passed++;
            end else begin
                $display("  [FAIL] Loop: %0d", sum);
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
