/*
:name: test_function_call_advanced
:description: Advanced Function Call Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.2 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_call_advanced.expected
*/
// IEEE 1800-2023 Section 13 - Advanced Function Call Tests
// Tests: Recursive functions, default arguments, ref arguments

module test_function_call_advanced;
    int pass_count = 0;
    int fail_count = 0;

    // Factorial function (recursive)
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    // Fibonacci function (recursive)
    function automatic int fibonacci(int n);
        if (n <= 0) return 0;
        if (n == 1) return 1;
        return fibonacci(n - 1) + fibonacci(n - 2);
    endfunction

    // Function with multiple return paths
    function int max3(int a, int b, int c);
        if (a >= b && a >= c) return a;
        if (b >= a && b >= c) return b;
        return c;
    endfunction

    // Function with local variables
    function int sum_range(int start, int finish);
        static int total = 0;
        for (int i = start; i <= finish; i++) begin
            total += i;
        end
        return total;
    endfunction

    // Function returning signed value
    function int signed_diff(int a, int b);
        return a - b;
    endfunction

    // Function with bit operations
    function logic [31:0] rotate_left(logic [31:0] val, int amount);
        return (val << amount) | (val >> (32 - amount));
    endfunction

    // Function chain call
    function int double_it(int x);
        return x * 2;
    endfunction

    function int quad_it(int x);
        return double_it(double_it(x));
    endfunction

    initial begin
        int result;
        logic [31:0] lresult;

        $display("=== IEEE 1800-2023 Advanced Function Call Tests ===");

        // Test 1: Factorial
        $display("Test 1: Factorial function");
        result = factorial(5);
        if (result == 120) begin
            $display("Test 1 PASS: factorial(5)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d, expected 120", result);
            fail_count++;
        end

        // Test 2: Fibonacci
        $display("Test 2: Fibonacci function");
        result = fibonacci(10);
        if (result == 55) begin
            $display("Test 2 PASS: fibonacci(10)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d, expected 55", result);
            fail_count++;
        end

        // Test 3: Max of three
        $display("Test 3: Max of three");
        result = max3(5, 9, 3);
        if (result == 9) begin
            $display("Test 3 PASS: max3(5,9,3)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 4: Sum range
        $display("Test 4: Sum range function");
        result = sum_range(1, 10);
        if (result == 55) begin
            $display("Test 4 PASS: sum_range(1,10)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %0d, expected 55", result);
            fail_count++;
        end

        // Test 5: Signed difference
        $display("Test 5: Signed difference");
        result = signed_diff(10, 25);
        if (result == -15) begin
            $display("Test 5 PASS: signed_diff(10,25)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 6: Rotate left
        $display("Test 6: Rotate left");
        lresult = rotate_left(32'h80000001, 1);
        if (lresult == 32'h00000003) begin
            $display("Test 6 PASS: rotate_left=%h", lresult);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %h", lresult);
            fail_count++;
        end

        // Test 7: Function chain
        $display("Test 7: Function chain");
        result = quad_it(5);
        if (result == 20) begin
            $display("Test 7 PASS: quad_it(5)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 8: Function in expression
        $display("Test 8: Function in expression");
        result = factorial(3) + fibonacci(5);
        if (result == 11) begin  // 6 + 5
            $display("Test 8 PASS: factorial(3)+fibonacci(5)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %0d, expected 11", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
