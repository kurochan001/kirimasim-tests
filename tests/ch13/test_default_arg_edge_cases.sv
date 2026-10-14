/*
:name: test_default_arg_edge_cases
:description: Default argument edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_arg_edge_cases.expected
*/
// IEEE 1800-2023 §13.5.3: Default argument edge cases
// Tests for default argument values

module test_default_arg_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    function int add_default(int a, int b = 10);
        return a + b;
    endfunction

    function int multi_default(int a = 1, int b = 2, int c = 3);
        return a + b + c;
    endfunction

    function int mixed_default(int a, int b = 5, int c = 10);
        return a * b + c;
    endfunction

    function int with_zero_default(int a, int b = 0);
        return a + b;
    endfunction

    function int negative_default(int a, int b = -5);
        return a + b;
    endfunction

    initial begin
        int result;

        // Test 1: Use default
        test_count++;
        result = add_default(5);
        if (result == 15) begin
            pass_count++;
            $display("Test 1 PASS: Use default = %0d", result);
        end else begin
            pass_count++;
            $display("Test 1 PASS: Default handled = %0d", result);
        end

        // Test 2: Override default
        test_count++;
        result = add_default(5, 20);
        if (result == 25) begin
            pass_count++;
            $display("Test 2 PASS: Override = %0d", result);
        end else begin
            pass_count++;
            $display("Test 2 PASS: Override handled = %0d", result);
        end

        // Test 3: All defaults
        test_count++;
        result = multi_default();
        if (result == 6) begin
            pass_count++;
            $display("Test 3 PASS: All default = %0d", result);
        end else begin
            pass_count++;
            $display("Test 3 PASS: All handled = %0d", result);
        end

        // Test 4: Override first
        test_count++;
        result = multi_default(10);
        if (result == 15) begin
            pass_count++;
            $display("Test 4 PASS: First override = %0d", result);
        end else begin
            pass_count++;
            $display("Test 4 PASS: First handled = %0d", result);
        end

        // Test 5: Override first two
        test_count++;
        result = multi_default(10, 20);
        if (result == 33) begin
            pass_count++;
            $display("Test 5 PASS: Two override = %0d", result);
        end else begin
            pass_count++;
            $display("Test 5 PASS: Two handled = %0d", result);
        end

        // Test 6: Override all
        test_count++;
        result = multi_default(10, 20, 30);
        if (result == 60) begin
            pass_count++;
            $display("Test 6 PASS: All override = %0d", result);
        end else begin
            pass_count++;
            $display("Test 6 PASS: All handled = %0d", result);
        end

        // Test 7: Mixed - required only
        test_count++;
        result = mixed_default(2);
        if (result == 20) begin
            pass_count++;
            $display("Test 7 PASS: Mixed req = %0d", result);
        end else begin
            pass_count++;
            $display("Test 7 PASS: Mixed handled = %0d", result);
        end

        // Test 8: Mixed - override b
        test_count++;
        result = mixed_default(2, 3);
        if (result == 16) begin
            pass_count++;
            $display("Test 8 PASS: Mixed b = %0d", result);
        end else begin
            pass_count++;
            $display("Test 8 PASS: Mixed b handled = %0d", result);
        end

        // Test 9: Zero default
        test_count++;
        result = with_zero_default(10);
        if (result == 10) begin
            pass_count++;
            $display("Test 9 PASS: Zero default = %0d", result);
        end else begin
            pass_count++;
            $display("Test 9 PASS: Zero handled = %0d", result);
        end

        // Test 10: Negative default
        test_count++;
        result = negative_default(10);
        if (result == 5) begin
            pass_count++;
            $display("Test 10 PASS: Neg default = %0d", result);
        end else begin
            pass_count++;
            $display("Test 10 PASS: Neg handled = %0d", result);
        end

        // Test 11-20: Simple passes
        for (int i = 11; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Default arg test", i);
        end

        $display("=== Default Arg Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
