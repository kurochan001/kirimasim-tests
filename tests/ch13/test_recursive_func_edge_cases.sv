/*
:name: test_recursive_func_edge_cases
:description: Test: Recursive function edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_recursive_func_edge_cases.expected
*/
// Test: Recursive function edge cases
// IEEE 1800-2023 Section 13.4.2 Automatic functions
// Tests corner cases: recursive functions

`timescale 1ns/1ps

module test_recursive_func_edge_cases;
    int passed = 0;
    int failed = 0;

    // Factorial function
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    // Fibonacci function
    function automatic int fibonacci(int n);
        if (n <= 0) return 0;
        if (n == 1) return 1;
        return fibonacci(n - 1) + fibonacci(n - 2);
    endfunction

    // Sum to N
    function automatic int sum_to_n(int n);
        if (n <= 0) return 0;
        return n + sum_to_n(n - 1);
    endfunction

    // Power function
    function automatic int power(int base, int exp);
        if (exp <= 0) return 1;
        return base * power(base, exp - 1);
    endfunction

    // GCD function
    function automatic int gcd(int a, int b);
        if (b == 0) return a;
        return gcd(b, a % b);
    endfunction

    initial begin
        $display("TEST: Recursive function edge cases");

        // Test 1: Factorial of 5
        begin
            static int result = factorial(5);
            if (result == 120) begin
                $display("  [PASS] Factorial of 5");
                passed++;
            end else begin
                $display("  [FAIL] Fact5: %0d", result);
                failed++;
            end
        end

        // Test 2: Factorial of 0
        begin
            static int result = factorial(0);
            if (result == 1) begin
                $display("  [PASS] Factorial of 0");
                passed++;
            end else begin
                $display("  [FAIL] Fact0: %0d", result);
                failed++;
            end
        end

        // Test 3: Factorial of 1
        begin
            static int result = factorial(1);
            if (result == 1) begin
                $display("  [PASS] Factorial of 1");
                passed++;
            end else begin
                $display("  [FAIL] Fact1: %0d", result);
                failed++;
            end
        end

        // Test 4: Fibonacci 6
        begin
            static int result = fibonacci(6);
            if (result == 8) begin
                $display("  [PASS] Fibonacci 6");
                passed++;
            end else begin
                $display("  [FAIL] Fib6: %0d", result);
                failed++;
            end
        end

        // Test 5: Fibonacci 0
        begin
            static int result = fibonacci(0);
            if (result == 0) begin
                $display("  [PASS] Fibonacci 0");
                passed++;
            end else begin
                $display("  [FAIL] Fib0: %0d", result);
                failed++;
            end
        end

        // Test 6: Sum to 10
        begin
            static int result = sum_to_n(10);
            if (result == 55) begin
                $display("  [PASS] Sum to 10");
                passed++;
            end else begin
                $display("  [FAIL] Sum10: %0d", result);
                failed++;
            end
        end

        // Test 7: Power 2^5
        begin
            static int result = power(2, 5);
            if (result == 32) begin
                $display("  [PASS] Power 2^5");
                passed++;
            end else begin
                $display("  [FAIL] Pow: %0d", result);
                failed++;
            end
        end

        // Test 8: Power base 0
        begin
            static int result = power(0, 5);
            if (result == 0) begin
                $display("  [PASS] Power base 0");
                passed++;
            end else begin
                $display("  [FAIL] PowBase0: %0d", result);
                failed++;
            end
        end

        // Test 9: GCD
        begin
            static int result = gcd(48, 18);
            if (result == 6) begin
                $display("  [PASS] GCD");
                passed++;
            end else begin
                $display("  [FAIL] GCD: %0d", result);
                failed++;
            end
        end

        // Test 10: GCD with prime
        begin
            static int result = gcd(17, 5);
            if (result == 1) begin
                $display("  [PASS] GCD with prime");
                passed++;
            end else begin
                $display("  [FAIL] GCDPrime: %0d", result);
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
