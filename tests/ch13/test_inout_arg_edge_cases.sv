/*
:name: test_inout_arg_edge_cases
:description: Inout argument edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 13.5.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inout_arg_edge_cases.expected
*/
// IEEE 1800-2023 §13.5: Inout argument edge cases
// Tests for inout arguments

module test_inout_arg_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    function automatic void add_to(inout int x, input int val);
        x = x + val;
    endfunction

    function automatic void multiply_by(inout int x, input int factor);
        x = x * factor;
    endfunction

    function automatic void increment(inout int x);
        x++;
    endfunction

    task automatic modify_both(inout int a, inout int b);
        int temp = a;
        a = a + b;
        b = temp * 2;
    endtask

    initial begin
        int val, a, b;

        // Test 1: Add to value
        test_count++;
        val = 10;
        add_to(val, 5);
        if (val == 15) begin
            pass_count++;
            $display("Test 1 PASS: Add to = %0d", val);
        end else begin
            $display("Test 1 FAIL: Add unexpected = %0d", val);
        end

        // Test 2: Multiply
        test_count++;
        val = 7;
        multiply_by(val, 3);
        if (val == 21) begin
            pass_count++;
            $display("Test 2 PASS: Multiply = %0d", val);
        end else begin
            $display("Test 2 FAIL: Mult unexpected = %0d", val);
        end

        // Test 3: Increment
        test_count++;
        val = 0;
        increment(val);
        if (val == 1) begin
            pass_count++;
            $display("Test 3 PASS: Increment = %0d", val);
        end else begin
            $display("Test 3 FAIL: Inc unexpected = %0d", val);
        end

        // Test 4: Chain operations
        test_count++;
        val = 5;
        add_to(val, 5);
        multiply_by(val, 2);
        if (val == 20) begin
            pass_count++;
            $display("Test 4 PASS: Chain = %0d", val);
        end else begin
            $display("Test 4 FAIL: Chain unexpected = %0d", val);
        end

        // Test 5: Multiple increments
        test_count++;
        val = 0;
        for (int i = 0; i < 5; i++) increment(val);
        if (val == 5) begin
            pass_count++;
            $display("Test 5 PASS: Multi inc = %0d", val);
        end else begin
            $display("Test 5 FAIL: Multi unexpected = %0d", val);
        end

        // Test 6: Task with two inouts
        test_count++;
        a = 10;
        b = 3;
        modify_both(a, b);
        if (a == 13 && b == 20) begin
            pass_count++;
            $display("Test 6 PASS: Two inout a=%0d b=%0d", a, b);
        end else begin
            $display("Test 6 FAIL: Two unexpected");
        end

        // Test 7: Zero value
        test_count++;
        val = 0;
        add_to(val, 0);
        if (val == 0) begin
            pass_count++;
            $display("Test 7 PASS: Zero = %0d", val);
        end else begin
            $display("Test 7 FAIL: Zero unexpected = %0d", val);
        end

        // Test 8: Negative result
        test_count++;
        val = 5;
        add_to(val, -10);
        if (val == -5) begin
            pass_count++;
            $display("Test 8 PASS: Negative = %0d", val);
        end else begin
            $display("Test 8 FAIL: Neg unexpected = %0d", val);
        end

        // Test 9: Multiply by zero
        test_count++;
        val = 100;
        multiply_by(val, 0);
        if (val == 0) begin
            pass_count++;
            $display("Test 9 PASS: Mult zero = %0d", val);
        end else begin
            $display("Test 9 FAIL: Zero unexpected = %0d", val);
        end

        // Test 10: Multiply by negative
        test_count++;
        val = 5;
        multiply_by(val, -2);
        if (val == -10) begin
            pass_count++;
            $display("Test 10 PASS: Mult neg = %0d", val);
        end else begin
            $display("Test 10 FAIL: Neg unexpected = %0d", val);
        end

        $display("=== Inout Arg Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
