/*
:name: test_function_task_edge_cases
:description: Function and task edge cases: return values, lifetimes, ref arguments and recursion
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4 6.21 13.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_task_edge_cases.expected
*/
// Function and task edge cases: return values, task execution, automatic and static lifetimes

module test_function_task_edge_cases;
    int pass_count = 0;
    int fail_count = 0;

    // Basic function
    function int add(int a, int b);
        return a + b;
    endfunction

    // Function with multiple returns
    function int abs_val(int x);
        if (x < 0)
            return -x;
        else
            return x;
    endfunction

    // Function with local variables
    function int factorial(int n);
        int result;
        result = 1;  // a static function's local initializer runs only once
        for (int i = 2; i <= n; i++)
            result = result * i;
        return result;
    endfunction

    // Automatic function with recursion
    function automatic int fib(int n);
        if (n <= 1)
            return n;
        return fib(n-1) + fib(n-2);
    endfunction

    // Function with output argument - must be automatic for ref
    function automatic void swap(ref int a, ref int b);
        int temp = a;
        a = b;
        b = temp;
    endfunction

    // Task with delay (simplified - no actual delay)
    task simple_task(input int val, output int result);
        result = val * 2;
    endtask

    // Task with ref argument - must be automatic for ref
    task automatic increment_ref(ref int val);
        val = val + 1;
    endtask

    // Static function with local static
    function int counter();
        static int count = 0;
        count++;
        return count;
    endfunction

    // Variables
    int x, y, result;

    initial begin
        $display("=== Function/Task Edge Cases Test ===");

        // Test basic function
        $display("\n--- Basic Function ---");
        result = add(10, 20);
        if (result == 30) begin
            $display("PASS: basic function");
            pass_count++;
        end else begin
            $display("FAIL: basic function = %0d", result);
            fail_count++;
        end

        // Test multiple returns
        $display("\n--- Multiple Returns ---");
        if (abs_val(-5) == 5 && abs_val(3) == 3) begin
            $display("PASS: multiple returns");
            pass_count++;
        end else begin
            $display("FAIL: multiple returns");
            fail_count++;
        end

        // Test local variables
        $display("\n--- Local Variables ---");
        result = factorial(5);
        if (result == 120) begin
            $display("PASS: local variables (5! = %0d)", result);
            pass_count++;
        end else begin
            $display("FAIL: local variables = %0d", result);
            fail_count++;
        end

        // Test recursive function
        $display("\n--- Recursive Function ---");
        result = fib(7);
        if (result == 13) begin
            $display("PASS: recursive function (fib(7) = %0d)", result);
            pass_count++;
        end else begin
            $display("FAIL: recursive function = %0d", result);
            fail_count++;
        end

        // Test ref arguments
        $display("\n--- Ref Arguments ---");
        x = 10;
        y = 20;
        swap(x, y);
        if (x == 20 && y == 10) begin
            $display("PASS: ref arguments (x=%0d, y=%0d)", x, y);
            pass_count++;
        end else begin
            $display("FAIL: ref arguments (x=%0d, y=%0d)", x, y);
            fail_count++;
        end

        // Test simple task
        $display("\n--- Simple Task ---");
        simple_task(15, result);
        if (result == 30) begin
            $display("PASS: simple task");
            pass_count++;
        end else begin
            $display("FAIL: simple task = %0d", result);
            fail_count++;
        end

        // Test task with ref
        $display("\n--- Task with Ref ---");
        x = 100;
        increment_ref(x);
        if (x == 101) begin
            $display("PASS: task with ref");
            pass_count++;
        end else begin
            $display("FAIL: task with ref = %0d", x);
            fail_count++;
        end

        // Test static local variable: it keeps its value between calls (6.21)
        $display("\n--- Static Local ---");
        x = counter();
        y = counter();
        result = counter();
        if (x == 1 && y == 2 && result == 3) begin
            $display("PASS: static local (x=%0d y=%0d r=%0d)", x, y, result);
            pass_count++;
        end else begin
            $display("FAIL: static local x=%0d y=%0d r=%0d", x, y, result);
            fail_count++;
        end

        // Test function as expression
        $display("\n--- Function as Expression ---");
        if (add(5, add(3, 2)) == 10) begin
            $display("PASS: nested function calls");
            pass_count++;
        end else begin
            $display("FAIL: nested function calls");
            fail_count++;
        end

        // Test void function
        $display("\n--- Void Function Call ---");
        x = 1;
        y = 2;
        swap(x, y);
        if (x == 2 && y == 1) begin
            $display("PASS: void function executed");
            pass_count++;
        end else begin
            $display("FAIL: void function swap x=%0d y=%0d", x, y);
            fail_count++;
        end

        $display("");
        $display("=== Summary: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
