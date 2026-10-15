/*
:name: test_function_call_3
:description: Test: Function call evaluation
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.2 13.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_call_3.expected
*/
// Test: Function call evaluation

module test_function_call_3;
    int pass_count = 0;
    int total_tests = 25;

    // Simple functions
    function int add(int a, int b);
        return a + b;
    endfunction

    function int multiply(int a, int b);
        return a * b;
    endfunction

    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    function int max_val(int a, int b);
        return (a > b) ? a : b;
    endfunction

    function int min_val(int a, int b);
        return (a < b) ? a : b;
    endfunction

    function int abs_val(int a);
        return (a < 0) ? -a : a;
    endfunction

    function int square(int x);
        return x * x;
    endfunction

    function automatic int fib(int n);
        if (n <= 1) return n;
        return fib(n-1) + fib(n-2);
    endfunction

    function string concat_str(string a, string b);
        return {a, b};
    endfunction

    function logic [7:0] byte_swap(logic [15:0] val);
        return val[7:0];
    endfunction

    function int triple(int x);
        return x * 3;
    endfunction

    function int sum_array(int arr[], int size);
        static int sum = 0;
        for (int i = 0; i < size; i++) begin
            sum = sum + arr[i];
        end
        return sum;
    endfunction

    function void set_value(output int result, input int val);
        result = val * 2;
    endfunction

    function int clamp(int val, int min_v, int max_v);
        if (val < min_v) return min_v;
        if (val > max_v) return max_v;
        return val;
    endfunction

    // Test variables
    int result;
    int arr[5];
    string str_result;

    initial begin
        // Test 1: Simple two-arg function
        result = add(10, 20);
        if (result == 30) begin
            $display("Test 1 PASSED: add(10, 20) = 30");
            pass_count++;
        end else $display("Test 1 FAILED");

        // Test 2: Multiply function
        result = multiply(7, 8);
        if (result == 56) begin
            $display("Test 2 PASSED: multiply(7, 8) = 56");
            pass_count++;
        end else $display("Test 2 FAILED");

        // Test 3: Recursive factorial
        result = factorial(5);
        if (result == 120) begin
            $display("Test 3 PASSED: factorial(5) = 120");
            pass_count++;
        end else $display("Test 3 FAILED");

        // Test 4: Factorial of 1
        result = factorial(1);
        if (result == 1) begin
            $display("Test 4 PASSED: factorial(1) = 1");
            pass_count++;
        end else $display("Test 4 FAILED");

        // Test 5: Max function
        result = max_val(15, 25);
        if (result == 25) begin
            $display("Test 5 PASSED: max_val(15, 25) = 25");
            pass_count++;
        end else $display("Test 5 FAILED");

        // Test 6: Max with equal values
        result = max_val(10, 10);
        if (result == 10) begin
            $display("Test 6 PASSED: max_val(10, 10) = 10");
            pass_count++;
        end else $display("Test 6 FAILED");

        // Test 7: Min function
        result = min_val(15, 25);
        if (result == 15) begin
            $display("Test 7 PASSED: min_val(15, 25) = 15");
            pass_count++;
        end else $display("Test 7 FAILED");

        // Test 8: Abs of positive
        result = abs_val(42);
        if (result == 42) begin
            $display("Test 8 PASSED: abs_val(42) = 42");
            pass_count++;
        end else $display("Test 8 FAILED");

        // Test 9: Abs of negative
        result = abs_val(-42);
        if (result == 42) begin
            $display("Test 9 PASSED: abs_val(-42) = 42");
            pass_count++;
        end else $display("Test 9 FAILED");

        // Test 10: Square function
        result = square(7);
        if (result == 49) begin
            $display("Test 10 PASSED: square(7) = 49");
            pass_count++;
        end else $display("Test 10 FAILED");

        // Test 11: Fibonacci
        result = fib(10);
        if (result == 55) begin
            $display("Test 11 PASSED: fib(10) = 55");
            pass_count++;
        end else $display("Test 11 FAILED");

        // Test 12: Fibonacci base case
        result = fib(0);
        if (result == 0) begin
            $display("Test 12 PASSED: fib(0) = 0");
            pass_count++;
        end else $display("Test 12 FAILED");

        // Test 13: String concatenation function
        str_result = concat_str("Hello", "World");
        if (str_result == "HelloWorld") begin
            $display("Test 13 PASSED: concat_str = HelloWorld");
            pass_count++;
        end else $display("Test 13 FAILED");

        // Test 14: Byte swap
        if (byte_swap(16'hABCD) == 8'hCD) begin
            $display("Test 14 PASSED: byte_swap(0xABCD) = 0xCD");
            pass_count++;
        end else $display("Test 14 FAILED");

        // Test 15: Nested function calls
        result = add(multiply(2, 3), multiply(4, 5));
        if (result == 26) begin
            $display("Test 15 PASSED: add(multiply(2,3), multiply(4,5)) = 26");
            pass_count++;
        end else $display("Test 15 FAILED");

        // Test 16: Function in expression
        result = 10 + triple(5);
        if (result == 25) begin
            $display("Test 16 PASSED: 10 + triple(5) = 25");
            pass_count++;
        end else $display("Test 16 FAILED");

        // Test 17: Function with array
        arr[0] = 1; arr[1] = 2; arr[2] = 3; arr[3] = 4; arr[4] = 5;
        result = sum_array(arr, 5);
        if (result == 15) begin
            $display("Test 17 PASSED: sum_array([1,2,3,4,5]) = 15");
            pass_count++;
        end else $display("Test 17 FAILED");

        // Test 18: Function with output argument
        set_value(result, 25);
        if (result == 50) begin
            $display("Test 18 PASSED: set_value(result, 25) -> 50");
            pass_count++;
        end else $display("Test 18 FAILED");

        // Test 19: Clamp within range
        result = clamp(50, 0, 100);
        if (result == 50) begin
            $display("Test 19 PASSED: clamp(50, 0, 100) = 50");
            pass_count++;
        end else $display("Test 19 FAILED");

        // Test 20: Clamp below range
        result = clamp(-10, 0, 100);
        if (result == 0) begin
            $display("Test 20 PASSED: clamp(-10, 0, 100) = 0");
            pass_count++;
        end else $display("Test 20 FAILED");

        // Test 21: Clamp above range
        result = clamp(150, 0, 100);
        if (result == 100) begin
            $display("Test 21 PASSED: clamp(150, 0, 100) = 100");
            pass_count++;
        end else $display("Test 21 FAILED");

        // Test 22: Chained function calls
        result = square(add(2, 3));
        if (result == 25) begin
            $display("Test 22 PASSED: square(add(2,3)) = 25");
            pass_count++;
        end else $display("Test 22 FAILED");

        // Test 23: Function with zero
        result = add(0, 0);
        if (result == 0) begin
            $display("Test 23 PASSED: add(0, 0) = 0");
            pass_count++;
        end else $display("Test 23 FAILED");

        // Test 24: Function with negative args
        result = add(-10, -20);
        if (result == -30) begin
            $display("Test 24 PASSED: add(-10, -20) = -30");
            pass_count++;
        end else $display("Test 24 FAILED");

        // Test 25: Multiple nested
        result = max_val(min_val(10, 20), min_val(5, 15));
        if (result == 10) begin
            $display("Test 25 PASSED: max(min(10,20), min(5,15)) = 10");
            pass_count++;
        end else $display("Test 25 FAILED");

        if (pass_count == total_tests) $display("PASS: function_call (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: function_call (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
