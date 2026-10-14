/*
:name: test_auto_func
:description: Automatic Function Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.3 13.4.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_auto_func.expected
*/
// IEEE 1800-2023 Section 13.4.3 - Automatic Function Tests
module test_auto_func;
    int pass_count = 0;
    int fail_count = 0;

    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    function automatic int fib(int n);
        if (n <= 1) return n;
        return fib(n - 1) + fib(n - 2);
    endfunction

    function automatic int sum_to_n(int n);
        if (n <= 0) return 0;
        return n + sum_to_n(n - 1);
    endfunction

    function automatic int power(int base, int exp);
        if (exp == 0) return 1;
        return base * power(base, exp - 1);
    endfunction

    initial begin
        int result;

        $display("=== IEEE 1800-2023 Automatic Function Tests ===");

        // Test 1: Factorial 5
        $display("Test 1: Factorial 5");
        result = factorial(5);
        if (result == 120) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Factorial 1
        $display("Test 2: Factorial 1");
        result = factorial(1);
        if (result == 1) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Fibonacci 6
        $display("Test 3: Fibonacci 6");
        result = fib(6);
        if (result == 8) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Fibonacci 0
        $display("Test 4: Fibonacci 0");
        result = fib(0);
        if (result == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Sum to 10
        $display("Test 5: Sum to 10");
        result = sum_to_n(10);
        if (result == 55) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Sum to 0
        $display("Test 6: Sum to 0");
        result = sum_to_n(0);
        if (result == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: Power 2^5
        $display("Test 7: Power 2^5");
        result = power(2, 5);
        if (result == 32) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Power x^0
        $display("Test 8: Power x^0");
        result = power(10, 0);
        if (result == 1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
