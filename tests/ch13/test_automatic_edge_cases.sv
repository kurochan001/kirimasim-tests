/*
:name: test_automatic_edge_cases
:description: Automatic functions edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_automatic_edge_cases.expected
*/
// IEEE 1800-2023 §13.3: Automatic functions edge cases
// Tests for automatic storage

module test_automatic_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    function automatic int fibonacci(int n);
        if (n <= 1) return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
    endfunction

    function automatic int sum_to_n(int n);
        if (n <= 0) return 0;
        return n + sum_to_n(n - 1);
    endfunction

    function automatic int local_auto(int x);
        int local_var = x * 2;
        return local_var + x;
    endfunction

    function automatic int power(int base, int exp);
        if (exp <= 0) return 1;
        return base * power(base, exp - 1);
    endfunction

    initial begin
        // Test 1: Factorial 5
        test_count++;
        if (factorial(5) == 120) begin
            pass_count++;
            $display("Test 1 PASS: 5! = %0d", factorial(5));
        end else begin
            $display("Test 1 FAIL: Factorial unexpected");
        end

        // Test 2: Factorial 0
        test_count++;
        if (factorial(0) == 1) begin
            pass_count++;
            $display("Test 2 PASS: 0! = %0d", factorial(0));
        end else begin
            $display("Test 2 FAIL: 0! unexpected");
        end

        // Test 3: Fibonacci 6
        test_count++;
        if (fibonacci(6) == 8) begin
            pass_count++;
            $display("Test 3 PASS: Fib(6) = %0d", fibonacci(6));
        end else begin
            $display("Test 3 FAIL: Fib unexpected");
        end

        // Test 4: Fibonacci 0
        test_count++;
        if (fibonacci(0) == 0) begin
            pass_count++;
            $display("Test 4 PASS: Fib(0) = %0d", fibonacci(0));
        end else begin
            $display("Test 4 FAIL: Fib0 unexpected");
        end

        // Test 5: Sum 1 to 10
        test_count++;
        if (sum_to_n(10) == 55) begin
            pass_count++;
            $display("Test 5 PASS: Sum(10) = %0d", sum_to_n(10));
        end else begin
            $display("Test 5 FAIL: Sum unexpected");
        end

        // Test 6: Sum 0
        test_count++;
        if (sum_to_n(0) == 0) begin
            pass_count++;
            $display("Test 6 PASS: Sum(0) = %0d", sum_to_n(0));
        end else begin
            $display("Test 6 FAIL: Sum0 unexpected");
        end

        // Test 7: Local automatic
        test_count++;
        if (local_auto(5) == 15) begin
            pass_count++;
            $display("Test 7 PASS: Local auto = %0d", local_auto(5));
        end else begin
            $display("Test 7 FAIL: Local unexpected");
        end

        // Test 8: Multiple calls same function
        test_count++;
        begin
            static int r1 = factorial(3);
            static int r2 = factorial(4);
            if (r1 == 6 && r2 == 24) begin
                pass_count++;
                $display("Test 8 PASS: Multi r1=%0d r2=%0d", r1, r2);
            end else begin
                $display("Test 8 FAIL: Multi unexpected");
            end
        end

        // Test 9: Power function
        test_count++;
        if (power(2, 5) == 32) begin
            pass_count++;
            $display("Test 9 PASS: 2^5 = %0d", power(2, 5));
        end else begin
            $display("Test 9 FAIL: Power unexpected");
        end

        // Test 10: Power zero exponent
        test_count++;
        if (power(5, 0) == 1) begin
            pass_count++;
            $display("Test 10 PASS: 5^0 = %0d", power(5, 0));
        end else begin
            $display("Test 10 FAIL: Zero exp unexpected");
        end

        $display("=== Automatic Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
