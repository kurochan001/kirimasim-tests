/*
:name: test_function_argument_passing
:description: Passing function arguments by value (IEEE 1800-2023 Section 13.5.1)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.1 13.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_argument_passing.expected
*/
// IEEE 1800-2023 Section 13.5.1 - Passing function arguments by value
module test_function_argument_passing;
    int pass_count = 0;
    int fail_count = 0;

    function automatic int add_values(int a, int b);
        return a + b;
    endfunction

    function automatic int multiply_values(int a, int b);
        return a * b;
    endfunction

    function automatic int compute_expr(int a, int b, int c);
        return a + b * c;
    endfunction

    function automatic int max_value(int a, int b);
        if (a > b) return a;
        else return b;
    endfunction

    initial begin
        int result;

        $display("=== IEEE 1800-2023 Parameter Passing Tests ===");

        // Test 1: Simple add
        $display("Test 1: Add");
        result = add_values(10, 20);
        if (result == 30) begin $display("Test 1 PASS: %0d", result); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", result); fail_count++; end

        // Test 2: Simple multiply
        $display("Test 2: Multiply");
        result = multiply_values(6, 7);
        if (result == 42) begin $display("Test 2 PASS: %0d", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", result); fail_count++; end

        // Test 3: Expression
        $display("Test 3: Expression");
        result = compute_expr(10, 5, 3);
        if (result == 25) begin $display("Test 3 PASS: %0d", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", result); fail_count++; end

        // Test 4: Max first
        $display("Test 4: Max first");
        result = max_value(100, 50);
        if (result == 100) begin $display("Test 4 PASS: %0d", result); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", result); fail_count++; end

        // Test 5: Max second
        $display("Test 5: Max second");
        result = max_value(30, 80);
        if (result == 80) begin $display("Test 5 PASS: %0d", result); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", result); fail_count++; end

        // Test 6: Nested calls
        $display("Test 6: Nested");
        result = add_values(multiply_values(2, 3), multiply_values(4, 5));
        if (result == 26) begin $display("Test 6 PASS: %0d", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", result); fail_count++; end

        // Test 7: Negative
        $display("Test 7: Negative");
        result = add_values(-10, 30);
        if (result == 20) begin $display("Test 7 PASS: %0d", result); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", result); fail_count++; end

        // Test 8: Zero
        $display("Test 8: Zero");
        result = multiply_values(0, 100);
        if (result == 0) begin $display("Test 8 PASS: %0d", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
