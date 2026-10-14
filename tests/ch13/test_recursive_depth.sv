/*
:name: test_recursive_depth
:description: Recursive Functions
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_recursive_depth.expected
*/
// IEEE 1800-2023 Section 13.4.2: Recursive Functions
// Tests deep recursion and mutual recursion

module test_recursive_depth;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Classic factorial
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    // Test 2: Fibonacci with recursion
    function automatic int fibonacci(int n);
        if (n <= 1) return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
    endfunction

    // Test 3: Deep recursion (sum 1 to n)
    function automatic int sum_recursive(int n);
        if (n <= 0) return 0;
        return n + sum_recursive(n - 1);
    endfunction

    // Test 4: Mutual recursion - is_even/is_odd
    function automatic bit is_even(int n);
        if (n == 0) return 1;
        return is_odd(n - 1);
    endfunction

    function automatic bit is_odd(int n);
        if (n == 0) return 0;
        return is_even(n - 1);
    endfunction

    // Test 5: Binary tree-like recursion
    function automatic int tree_sum(int depth, int value);
        if (depth == 0) return value;
        return tree_sum(depth - 1, value) + tree_sum(depth - 1, value);
    endfunction

    // Test 6: GCD using Euclidean algorithm
    function automatic int gcd(int a, int b);
        if (b == 0) return a;
        return gcd(b, a % b);
    endfunction

    // Test 7: Power function
    function automatic int power(int base, int exp);
        if (exp == 0) return 1;
        if (exp == 1) return base;
        return base * power(base, exp - 1);
    endfunction

    // Test 8: Ackermann function (limited for testing)
    function automatic int ackermann(int m, int n);
        if (m == 0) return n + 1;
        if (n == 0) return ackermann(m - 1, 1);
        return ackermann(m - 1, ackermann(m, n - 1));
    endfunction

    initial begin
        // Test 1: Factorial
        if (factorial(5) == 120 && factorial(0) == 1) pass_count++;
        else begin fail_count++; $display("FAIL: factorial"); end

        // Test 2: Fibonacci
        if (fibonacci(10) == 55 && fibonacci(0) == 0 && fibonacci(1) == 1) pass_count++;
        else begin fail_count++; $display("FAIL: fibonacci"); end

        // Test 3: Deep sum (1+2+...+100 = 5050)
        if (sum_recursive(100) == 5050) pass_count++;
        else begin fail_count++; $display("FAIL: sum recursive"); end

        // Test 4: Mutual recursion
        if (is_even(10) && !is_even(7) && is_odd(7) && !is_odd(10)) pass_count++;
        else begin fail_count++; $display("FAIL: mutual recursion"); end

        // Test 5: Tree sum (depth=3, value=1 -> 2^3 = 8)
        if (tree_sum(3, 1) == 8) pass_count++;
        else begin fail_count++; $display("FAIL: tree sum"); end

        // Test 6: GCD
        if (gcd(48, 18) == 6 && gcd(17, 13) == 1) pass_count++;
        else begin fail_count++; $display("FAIL: gcd"); end

        // Test 7: Power
        if (power(2, 10) == 1024 && power(3, 4) == 81) pass_count++;
        else begin fail_count++; $display("FAIL: power"); end

        // Test 8: Ackermann (small values only)
        if (ackermann(2, 2) == 7 && ackermann(1, 3) == 5) pass_count++;
        else begin fail_count++; $display("FAIL: ackermann"); end

        if (fail_count == 0)
            $display("TEST PASSED (%0d/8)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
