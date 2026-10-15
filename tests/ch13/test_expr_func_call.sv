/*
:name: test_expr_func_call
:description: Function call expressions test
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.2 13.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_func_call.expected
*/
// Function call expressions test
module test_expr_func_call;
    int pass_count = 0;
    int fail_count = 0;

    // Simple function
    function int add(int a, int b);
        return a + b;
    endfunction

    // Function with default argument
    function int multiply(int a, int b = 2);
        return a * b;
    endfunction

    // Recursive function
    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    // Function returning void with output argument
    function automatic void swap(ref int a, ref int b);
        int temp;
        temp = a;
        a = b;
        b = temp;
    endfunction

    initial begin
        int x, y, result;

        // Test 1: Simple function call
        result = add(3, 4);
        if (result == 7) begin
            $display("PASS: add(3, 4) = 7");
            pass_count++;
        end else begin
            $display("FAIL: add(3,4), expected 7, got %0d", result);
            fail_count++;
        end

        // Test 2: Function with default argument
        result = multiply(5);
        if (result == 10) begin
            $display("PASS: multiply(5) with default = 10");
            pass_count++;
        end else begin
            $display("FAIL: multiply(5), expected 10, got %0d", result);
            fail_count++;
        end

        // Test 3: Override default argument
        result = multiply(5, 3);
        if (result == 15) begin
            $display("PASS: multiply(5, 3) = 15");
            pass_count++;
        end else begin
            $display("FAIL: multiply(5,3), expected 15, got %0d", result);
            fail_count++;
        end

        // Test 4: Recursive function call
        result = factorial(5);
        if (result == 120) begin
            $display("PASS: factorial(5) = 120");
            pass_count++;
        end else begin
            $display("FAIL: factorial(5), expected 120, got %0d", result);
            fail_count++;
        end

        // Test 5: Function with ref arguments
        x = 10; y = 20;
        swap(x, y);
        if (x == 20 && y == 10) begin
            $display("PASS: swap(10, 20) -> x=20, y=10");
            pass_count++;
        end else begin
            $display("FAIL: swap, expected x=20 y=10, got x=%0d y=%0d", x, y);
            fail_count++;
        end

        // Summary
        $display("Function call expressions: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All function call expression tests passed");
        else $display("FAIL: Some function call expression tests failed");
        $finish;
    end
endmodule
