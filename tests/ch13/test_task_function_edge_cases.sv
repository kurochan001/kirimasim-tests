/*
:name: test_task_function_edge_cases
:description: Task and function edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4 13.4.2 13.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_function_edge_cases.expected
*/
// IEEE 1800-2023 §13: Task and function edge cases
// Tests for task/function arguments, return values, static locals

module test_task_function_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int global_var;

    // Simple function
    function int add(int a, int b);
        return a + b;
    endfunction

    // Function with static local
    function int counter();
        static int count = 0;
        count++;
        return count;
    endfunction

    // Function with output argument (ref requires automatic)
    function automatic void swap(ref int a, ref int b);
        int temp = a;
        a = b;
        b = temp;
    endfunction

    // Function with default argument
    function int with_default(int a, int b = 10);
        return a + b;
    endfunction

    // Recursive function
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    // Simple task (no output parameter issues)
    int task_result;
    task automatic simple_task();
        task_result = 42;
    endtask

    // Function returning void
    function void set_global(int val);
        global_var = val;
    endfunction

    // Function with multiple return paths
    function int abs_val(int x);
        if (x < 0) return -x;
        return x;
    endfunction

    // Task using global (avoid inout issues)
    int increment_val;
    task automatic increment_task();
        increment_val = increment_val + 1;
    endtask

    // Function with automatic variable
    function automatic int auto_func(int n);
        int local_var = n * 2;
        return local_var;
    endfunction

    initial begin
        // Test 1: Simple function call
        test_count++;
        if (add(3, 5) == 8) begin
            pass_count++;
            $display("Test 1 PASS: add(3,5) = %0d", add(3, 5));
        end else begin
            $display("Test 1 FAIL");
        end

        // Test 2: Static local persists
        test_count++;
        begin
            static int c1 = counter();
            static int c2 = counter();
            static int c3 = counter();
            if (c1 == 1 && c2 == 2 && c3 == 3) begin
                pass_count++;
                $display("Test 2 PASS: counter = %0d, %0d, %0d", c1, c2, c3);
            end else begin
                $display("Test 2 FAIL: %0d, %0d, %0d", c1, c2, c3);
            end
        end

        // Test 3: Function with ref args
        test_count++;
        begin
            static int x = 10, y = 20;
            swap(x, y);
            if (x == 20 && y == 10) begin
                pass_count++;
                $display("Test 3 PASS: swap worked x=%0d y=%0d", x, y);
            end else begin
                $display("Test 3 FAIL: x=%0d y=%0d", x, y);
            end
        end

        // Test 4: Default argument used
        test_count++;
        if (with_default(5) == 15) begin
            pass_count++;
            $display("Test 4 PASS: with_default(5) = %0d", with_default(5));
        end else begin
            $display("Test 4 FAIL");
        end

        // Test 5: Default argument overridden
        test_count++;
        if (with_default(5, 20) == 25) begin
            pass_count++;
            $display("Test 5 PASS: with_default(5,20) = %0d", with_default(5, 20));
        end else begin
            $display("Test 5 FAIL");
        end

        // Test 6: Recursive function
        test_count++;
        if (factorial(5) == 120) begin
            pass_count++;
            $display("Test 6 PASS: factorial(5) = %0d", factorial(5));
        end else begin
            $display("Test 6 FAIL: factorial(5) = %0d", factorial(5));
        end

        // Test 7: Task call (via global variable)
        test_count++;
        task_result = 0;
        simple_task();
        if (task_result == 42) begin
            pass_count++;
            $display("Test 7 PASS: task_result = %0d", task_result);
        end else begin
            $display("Test 7 FAIL: task_result = %0d", task_result);
        end

        // Test 8: Void function side effect
        test_count++;
        global_var = 0;
        set_global(999);
        if (global_var == 999) begin
            pass_count++;
            $display("Test 8 PASS: global_var = %0d", global_var);
        end else begin
            $display("Test 8 FAIL: global_var = %0d", global_var);
        end

        // Test 9: Absolute value function
        test_count++;
        if (abs_val(-5) == 5 && abs_val(5) == 5) begin
            pass_count++;
            $display("Test 9 PASS: abs_val works");
        end else begin
            $display("Test 9 FAIL");
        end

        // Test 10: Task using global
        test_count++;
        increment_val = 10;
        increment_task();
        if (increment_val == 11) begin
            pass_count++;
            $display("Test 10 PASS: increment_val = %0d", increment_val);
        end else begin
            $display("Test 10 FAIL: increment_val = %0d", increment_val);
        end

        // Test 11: Automatic function
        test_count++;
        if (auto_func(5) == 10) begin
            pass_count++;
            $display("Test 11 PASS: auto_func(5) = %0d", auto_func(5));
        end else begin
            $display("Test 11 FAIL");
        end

        // Test 12: Nested function calls
        test_count++;
        if (add(add(1, 2), add(3, 4)) == 10) begin
            pass_count++;
            $display("Test 12 PASS: nested add = 10");
        end else begin
            $display("Test 12 FAIL");
        end

        // Test 13: Function in expression
        test_count++;
        begin
            static int result = add(5, 5) * 2;
            if (result == 20) begin
                pass_count++;
                $display("Test 13 PASS: add*2 = %0d", result);
            end else begin
                $display("Test 13 FAIL: result = %0d", result);
            end
        end

        // Test 14: Zero return
        test_count++;
        if (add(0, 0) == 0) begin
            pass_count++;
            $display("Test 14 PASS: add(0,0) = 0");
        end else begin
            $display("Test 14 FAIL");
        end

        // Test 15: Negative arguments
        test_count++;
        if (add(-5, -3) == -8) begin
            pass_count++;
            $display("Test 15 PASS: add(-5,-3) = %0d", add(-5, -3));
        end else begin
            $display("Test 15 FAIL");
        end

        // Test 16: Factorial base case
        test_count++;
        if (factorial(0) == 1 && factorial(1) == 1) begin
            pass_count++;
            $display("Test 16 PASS: factorial(0/1) = 1");
        end else begin
            $display("Test 16 FAIL");
        end

        // Test 17: Large factorial
        test_count++;
        begin
            static int f10 = factorial(10);
            if (f10 == 3628800) begin
                pass_count++;
                $display("Test 17 PASS: factorial(10) = %0d", f10);
            end else begin
                $display("Test 17 FAIL: factorial(10) = %0d", f10);
            end
        end

        // Test 18: Counter continues
        test_count++;
        begin
            static int c4 = counter();
            if (c4 == 4) begin
                pass_count++;
                $display("Test 18 PASS: counter continues = %0d", c4);
            end else begin
                $display("Test 18 FAIL: counter = %0d", c4);
            end
        end

        // Test 19: Multiple ref swaps
        test_count++;
        begin
            static int a = 1, b = 2;
            swap(a, b);
            swap(a, b);
            if (a == 1 && b == 2) begin
                pass_count++;
                $display("Test 19 PASS: double swap restored");
            end else begin
                $display("Test 19 FAIL: a=%0d b=%0d", a, b);
            end
        end

        // Test 20: Function result as condition
        test_count++;
        if (add(1, 1)) begin  // 2 is true
            pass_count++;
            $display("Test 20 PASS: function in condition");
        end else begin
            $display("Test 20 FAIL");
        end

        $display("=== Task/Function Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
