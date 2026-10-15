/*
:name: test_package_func
:description: Package functions test
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 26.3 13.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_func.expected
*/
// Package functions test
package func_pkg;
    // Simple function
    function int add(int a, int b);
        return a + b;
    endfunction

    // Function with logic return
    function logic [7:0] invert_byte(logic [7:0] val);
        return ~val;
    endfunction

    // Function with multiple statements
    function int factorial(int n);
        int result;
        result = 1;  // a static function's local initializer runs only once
        for (int i = 2; i <= n; i++) begin
            result = result * i;
        end
        return result;
    endfunction

    // Function using package types
    typedef logic [15:0] data_t;
    function data_t swap_bytes(data_t val);
        return {val[7:0], val[15:8]};
    endfunction

    // Pure function (no side effects)
    function automatic int fib(int n);
        if (n <= 1) return n;
        return fib(n-1) + fib(n-2);
    endfunction

    // Function with output argument
    function int divide_with_rem(int dividend, int divisor, output int remainder);
        remainder = dividend % divisor;
        return dividend / divisor;
    endfunction

    // Function with default argument
    function int scale(int value, int factor = 2);
        return value * factor;
    endfunction
endpackage

module test_package_func;
    import func_pkg::*;

    int pass_count = 0;
    int fail_count = 0;

    int result;
    logic [7:0] byte_result;
    data_t data_result;
    int remainder;

    initial begin
        #1;

        // Test 1: Simple function
        result = add(10, 20);
        if (result == 30) begin
            $display("PASS: Test 1 - Simple function add(%0d)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Simple function failed (%0d)", result);
            fail_count++;
        end

        // Test 2: Logic function
        byte_result = invert_byte(8'hAA);
        if (byte_result == 8'h55) begin
            $display("PASS: Test 2 - Logic function invert(%h)", byte_result);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Logic function failed (%h)", byte_result);
            fail_count++;
        end

        // Test 3: Function with loops
        result = factorial(5);
        if (result == 120) begin
            $display("PASS: Test 3 - Factorial function (5!=%0d)", result);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Factorial failed (%0d)", result);
            fail_count++;
        end

        // Test 4: Function using package types
        data_result = swap_bytes(16'hABCD);
        if (data_result == 16'hCDAB) begin
            $display("PASS: Test 4 - Swap bytes function (%h)", data_result);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Swap bytes failed (%h)", data_result);
            fail_count++;
        end

        // Test 5: Function with output argument and default argument
        result = divide_with_rem(17, 5, remainder);
        if (result == 3 && remainder == 2) begin
            $display("PASS: Test 5 - Divide with remainder (q=%0d, r=%0d)", result, remainder);
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Divide with remainder failed");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
