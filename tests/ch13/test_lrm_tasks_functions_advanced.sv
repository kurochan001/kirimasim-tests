/*
:name: test_lrm_tasks_functions_advanced
:description: Tasks and Functions - Advanced Corner Cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4 13.4.2 13.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_lrm_tasks_functions_advanced.expected
*/
// IEEE 1800-2023 §13 Tasks and Functions - Advanced Corner Cases
// Tests for recursive functions, static locals, scope rules

module test_lrm_tasks_functions_advanced;
    int pass_count = 0;
    int fail_count = 0;
    int test_count = 0;

    // Test 1: Recursive function with automatic storage (§13.4.2)
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        else return n * factorial(n - 1);
    endfunction

    // Test 2: Function with static local variable (§13.4.1)
    function int counter();
        static int count = 0;
        count++;
        return count;
    endfunction

    // Test 3: Function with output parameter for array (§13.4)
    function automatic void reverse_array(input int unsigned arr[4], output int unsigned result[4]);
        for (int i = 0; i < 4; i++)
            result[i] = arr[3-i];
    endfunction

    // Test 4: Task with output parameters (§13.3)
    task automatic swap(inout int a, inout int b);
        int temp;
        temp = a;
        a = b;
        b = temp;
    endtask

    // Test 5: Function with default arguments (§13.4)
    function int add_with_default(int a, int b = 10, int c = 20);
        return a + b + c;
    endfunction

    // Test 6: Helper function for chained calls (§13.4)
    function int double_it(int y);
        return y * 2;
    endfunction

    function int outer_func(int x);
        return double_it(x) + x;
    endfunction

    // Test 7: Function with ref parameter (§13.5.2)
    function automatic void increment_ref(ref int val);
        val++;
    endfunction

    // Test 8: Void function (§13.4)
    int global_var;
    function void set_global(int val);
        global_var = val;
    endfunction

    // Test 9: Static function counter with multiple calls
    function int call_counter();
        static int calls = 0;
        calls++;
        return calls;
    endfunction

    // Test 10: Recursive fibonacci
    function automatic int fibonacci(int n);
        if (n <= 0) return 0;
        if (n == 1) return 1;
        return fibonacci(n-1) + fibonacci(n-2);
    endfunction

    initial begin
        int result;
        int a, b;
        int unsigned arr[4];
        int unsigned rev[4];

        $display("=== IEEE 1800-2023 §13 Tasks/Functions Advanced ===");

        // Test 1: Recursive factorial
        test_count++;
        result = factorial(5);
        if (result == 120) begin
            pass_count++;
            $display("Test 1 PASS: factorial(5) = %0d", result);
        end else begin
            fail_count++;
            $display("Test 1 FAIL: factorial(5) = %0d (expected 120)", result);
        end

        // Test 2: Static local variable persistence
        test_count++;
        result = counter();  // Should return 1
        result = counter();  // Should return 2
        result = counter();  // Should return 3
        if (result == 3) begin
            pass_count++;
            $display("Test 2 PASS: counter() after 3 calls = %0d", result);
        end else begin
            fail_count++;
            $display("Test 2 FAIL: counter() = %0d (expected 3)", result);
        end

        // Test 3: Array via output parameter
        test_count++;
        arr = '{1, 2, 3, 4};
        reverse_array(arr, rev);
        if (rev[0] == 4 && rev[1] == 3 && rev[2] == 2 && rev[3] == 1) begin
            pass_count++;
            $display("Test 3 PASS: reverse_array works");
        end else begin
            fail_count++;
            $display("Test 3 FAIL: reverse_array = {%0d,%0d,%0d,%0d}", rev[0], rev[1], rev[2], rev[3]);
        end

        // Test 4: Task with inout
        test_count++;
        a = 10;
        b = 20;
        swap(a, b);
        if (a == 20 && b == 10) begin
            pass_count++;
            $display("Test 4 PASS: swap(10,20) gives a=%0d b=%0d", a, b);
        end else begin
            fail_count++;
            $display("Test 4 FAIL: swap failed a=%0d b=%0d", a, b);
        end

        // Test 5: Default arguments
        test_count++;
        result = add_with_default(5);  // 5 + 10 + 20 = 35
        if (result == 35) begin
            pass_count++;
            $display("Test 5 PASS: add_with_default(5) = %0d", result);
        end else begin
            fail_count++;
            $display("Test 5 FAIL: add_with_default(5) = %0d (expected 35)", result);
        end

        // Test 6: Default argument partial override
        test_count++;
        result = add_with_default(5, 15);  // 5 + 15 + 20 = 40
        if (result == 40) begin
            pass_count++;
            $display("Test 6 PASS: add_with_default(5,15) = %0d", result);
        end else begin
            fail_count++;
            $display("Test 6 FAIL: add_with_default(5,15) = %0d (expected 40)", result);
        end

        // Test 7: Void function with side effect
        test_count++;
        global_var = 0;
        set_global(42);
        if (global_var == 42) begin
            pass_count++;
            $display("Test 7 PASS: void function set global to %0d", global_var);
        end else begin
            fail_count++;
            $display("Test 7 FAIL: global_var = %0d (expected 42)", global_var);
        end

        // Test 8: Ref parameter modification
        test_count++;
        a = 100;
        increment_ref(a);
        if (a == 101) begin
            pass_count++;
            $display("Test 8 PASS: increment_ref changed a to %0d", a);
        end else begin
            fail_count++;
            $display("Test 8 FAIL: a = %0d (expected 101)", a);
        end

        // Test 9: Static counter independence
        test_count++;
        begin
            int c1, c2, c3;
            c1 = call_counter();
            c2 = call_counter();
            c3 = call_counter();
            if (c1 == 1 && c2 == 2 && c3 == 3) begin
                pass_count++;
                $display("Test 9 PASS: call_counter returns %0d,%0d,%0d", c1, c2, c3);
            end else begin
                fail_count++;
                $display("Test 9 FAIL: call_counter = %0d,%0d,%0d", c1, c2, c3);
            end
        end

        // Test 10: Fibonacci recursive
        test_count++;
        result = fibonacci(10);
        if (result == 55) begin
            pass_count++;
            $display("Test 10 PASS: fibonacci(10) = %0d", result);
        end else begin
            fail_count++;
            $display("Test 10 FAIL: fibonacci(10) = %0d (expected 55)", result);
        end

        // Test 11: Deep recursion
        test_count++;
        result = factorial(10);
        if (result == 3628800) begin
            pass_count++;
            $display("Test 11 PASS: factorial(10) = %0d", result);
        end else begin
            fail_count++;
            $display("Test 11 FAIL: factorial(10) = %0d (expected 3628800)", result);
        end

        // Test 12: All default arguments
        test_count++;
        result = add_with_default(5, 10, 20);  // 5 + 10 + 20 = 35
        if (result == 35) begin
            pass_count++;
            $display("Test 12 PASS: explicit all args = %0d", result);
        end else begin
            fail_count++;
            $display("Test 12 FAIL: explicit all args = %0d", result);
        end

        // Summary
        $display("\n=== Summary ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
