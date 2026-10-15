/*
:name: test_function_calls
:description: Function Calls Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.1 13.4.2 13.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_calls.expected
*/
// IEEE 1800-2023 Section 13.4 - Function Calls Tests
// Tests: Function return values, recursive functions, automatic functions

module test_function_calls;
    int pass_count = 0;
    int fail_count = 0;

    // Simple function
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

    // Recursive function (factorial)
    function automatic int factorial(int n);
        if (n <= 1)
            return 1;
        else
            return n * factorial(n - 1);
    endfunction

    // Function with output argument
    function int with_output(int a, output int doubled);
        doubled = a * 2;
        return a + 1;
    endfunction

    // Function with ref argument (must be automatic)
    function automatic void increment(ref int val);
        val = val + 1;
    endfunction

    // Pure function (no side effects)
    function int multiply(input int a, input int b);
        return a * b;
    endfunction

    int result, doubled_val;

    initial begin
        $display("=== IEEE 1800-2023 Function Calls Tests ===");

        // Test 1: Simple function call
        $display("Test 1: Simple function call");
        result = add(5, 3);
        if (result == 8) begin
            $display("Test 1 PASS: add(5,3)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: Function with conditional return
        $display("Test 2: Function with conditional return");
        result = abs_val(-42);
        if (result == 42) begin
            $display("Test 2 PASS: abs_val(-42)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: Recursive function
        $display("Test 3: Recursive function");
        result = factorial(5);
        if (result == 120) begin
            $display("Test 3 PASS: factorial(5)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", result);
            fail_count++;
        end

        // Test 4: Function with output argument
        $display("Test 4: Function with output argument");
        result = with_output(10, doubled_val);
        if (result == 11 && doubled_val == 20) begin
            $display("Test 4 PASS: result=%0d, doubled=%0d", result, doubled_val);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Function with ref argument
        $display("Test 5: Function with ref argument");
        result = 100;
        increment(result);
        if (result == 101) begin
            $display("Test 5 PASS: result=%0d after increment", result);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Nested function calls
        $display("Test 6: Nested function calls");
        result = add(multiply(2, 3), multiply(4, 5));
        if (result == 26) begin
            $display("Test 6 PASS: add(2*3, 4*5)=%0d", result);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Function result as condition
        $display("Test 7: Function result as condition");
        if (abs_val(-10) > 5) begin
            $display("Test 7 PASS: abs_val(-10) > 5");
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Multiple function calls in expression
        $display("Test 8: Multiple function calls in expression");
        result = add(1, 2) + add(3, 4) + add(5, 6);
        if (result == 21) begin
            $display("Test 8 PASS: sum=%0d", result);
            pass_count++;
        end else begin
            $display("Test 8 FAIL");
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
