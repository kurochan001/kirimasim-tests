/*
:name: test_func_call_ext
:description: Recursive automatic functions, ref arguments and nested function calls
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.4.2 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_call_ext.expected
*/
// IEEE 1800-2023 §13.4

module test_func_call_ext;
    int pass_count = 0;
    int test_count = 0;

    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    function automatic int fibonacci(int n);
        if (n <= 1) return n;
        return fibonacci(n-1) + fibonacci(n-2);
    endfunction

    function automatic void modify_ref(ref int val);
        val = val * 2;
    endfunction

    function automatic int auto_func(int n);
        int local_var = n;
        return local_var * 2;
    endfunction

    function int add_three(int a, int b, int c);
        return a + b + c;
    endfunction

    initial begin
        int val, val2;

        // Test 1: Recursive factorial
        test_count++;
        val = factorial(5);
        if (val == 120) begin
            $display("Test 1: Factorial PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL val=%0d", val);
        end

        // Test 2: Fibonacci
        test_count++;
        val = fibonacci(10);
        if (val == 55) begin
            $display("Test 2: Fibonacci PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL val=%0d", val);
        end

        // Test 3: Ref argument
        test_count++;
        val = 10;
        modify_ref(val);
        if (val == 20) begin
            $display("Test 3: Ref arg PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL val=%0d", val);
        end

        // Test 4: Automatic function
        test_count++;
        val = auto_func(25);
        if (val == 50) begin
            $display("Test 4: Auto func PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL val=%0d", val);
        end

        // Test 5: Nested calls
        test_count++;
        val = factorial(factorial(3));
        if (val == 720) begin
            $display("Test 5: Nested calls PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL val=%0d", val);
        end

        // Test 6: Expression in call
        test_count++;
        val = factorial(2 + 3);
        if (val == 120) begin
            $display("Test 6: Expr in call PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL val=%0d", val);
        end

        // Test 7: Conditional call
        test_count++;
        val = (1 > 0) ? factorial(4) : fibonacci(4);
        if (val == 24) begin
            $display("Test 7: Conditional call PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL val=%0d", val);
        end

        // Test 8: Multiple args
        test_count++;
        val = add_three(10, 20, 30);
        if (val == 60) begin
            $display("Test 8: Multiple args PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL val=%0d", val);
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
