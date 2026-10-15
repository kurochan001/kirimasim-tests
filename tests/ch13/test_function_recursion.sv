/*
:name: test_function_recursion
:description: Recursive Functions (§13.4.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_recursion.expected
*/
// IEEE 1800-2023 Recursive Functions (§13.4.2)
// Tests recursive function calls

module test_function_recursion;

    // Factorial function
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    // Fibonacci function
    function automatic int fibonacci(int n);
        if (n <= 1) return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
    endfunction

    // GCD using Euclidean algorithm
    function automatic int gcd(int a, int b);
        if (b == 0) return a;
        return gcd(b, a % b);
    endfunction

    initial begin
        int result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Factorial
        result = factorial(5);
        if (result == 120) begin
            $display("PASS: factorial(5) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: factorial(5) = %0d, expected 120", result);
            fail_count++;
        end

        result = factorial(0);
        if (result == 1) begin
            $display("PASS: factorial(0) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: factorial(0) = %0d, expected 1", result);
            fail_count++;
        end

        // Test 2: Fibonacci
        result = fibonacci(10);
        if (result == 55) begin
            $display("PASS: fibonacci(10) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: fibonacci(10) = %0d, expected 55", result);
            fail_count++;
        end

        result = fibonacci(0);
        if (result == 0) begin
            $display("PASS: fibonacci(0) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: fibonacci(0) = %0d, expected 0", result);
            fail_count++;
        end

        // Test 3: GCD
        result = gcd(48, 18);
        if (result == 6) begin
            $display("PASS: gcd(48, 18) = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: gcd(48, 18) = %0d, expected 6", result);
            fail_count++;
        end

        result = gcd(17, 13);
        if (result == 1) begin
            $display("PASS: gcd(17, 13) = %0d (coprime)", result);
            pass_count++;
        end else begin
            $display("FAIL: gcd(17, 13) = %0d, expected 1", result);
            fail_count++;
        end

        $display("");
        $display("=== Recursion Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
