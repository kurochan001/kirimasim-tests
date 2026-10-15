/*
:name: test_output_arg_edge_cases
:description: Output argument edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 13.5.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_output_arg_edge_cases.expected
*/
// IEEE 1800-2023 §13.5: Output argument edge cases
// Tests for output arguments

module test_output_arg_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    function automatic void get_sum(input int a, input int b, output int result);
        result = a + b;
    endfunction

    function automatic void get_multi(input int x, output int doubled, output int tripled);
        doubled = x * 2;
        tripled = x * 3;
    endfunction

    function automatic void compute(input int a, output int sum, output int prod);
        sum = a + 10;
        prod = a * 10;
    endfunction

    task automatic get_values(input int n, output int sq, output int cube);
        sq = n * n;
        cube = n * n * n;
    endtask

    initial begin
        int result, d, t, s, p;

        // Test 1: Simple output
        test_count++;
        get_sum(10, 20, result);
        if (result == 30) begin
            pass_count++;
            $display("Test 1 PASS: Sum = %0d", result);
        end else begin
            $display("Test 1 FAIL: Sum unexpected = %0d", result);
        end

        // Test 2: Multiple outputs
        test_count++;
        get_multi(5, d, t);
        if (d == 10 && t == 15) begin
            pass_count++;
            $display("Test 2 PASS: Multi d=%0d t=%0d", d, t);
        end else begin
            $display("Test 2 FAIL: Multi unexpected");
        end

        // Test 3: Compute function
        test_count++;
        compute(7, s, p);
        if (s == 17 && p == 70) begin
            pass_count++;
            $display("Test 3 PASS: Compute s=%0d p=%0d", s, p);
        end else begin
            $display("Test 3 FAIL: Compute unexpected");
        end

        // Test 4: Zero input
        test_count++;
        get_sum(0, 0, result);
        if (result == 0) begin
            pass_count++;
            $display("Test 4 PASS: Zero = %0d", result);
        end else begin
            $display("Test 4 FAIL: Zero unexpected = %0d", result);
        end

        // Test 5: Negative input
        test_count++;
        get_sum(-5, 10, result);
        if (result == 5) begin
            pass_count++;
            $display("Test 5 PASS: Negative = %0d", result);
        end else begin
            $display("Test 5 FAIL: Neg unexpected = %0d", result);
        end

        // Test 6: Task output
        test_count++;
        get_values(3, s, p);
        if (s == 9 && p == 27) begin
            pass_count++;
            $display("Test 6 PASS: Task s=%0d p=%0d", s, p);
        end else begin
            $display("Test 6 FAIL: Task unexpected");
        end

        // Test 7: Overwrite previous value
        test_count++;
        result = 999;
        get_sum(1, 2, result);
        if (result == 3) begin
            pass_count++;
            $display("Test 7 PASS: Overwrite = %0d", result);
        end else begin
            $display("Test 7 FAIL: Overwrite unexpected = %0d", result);
        end

        // Test 8: Chain calls
        test_count++;
        get_sum(5, 5, result);
        get_sum(result, 10, result);
        if (result == 20) begin
            pass_count++;
            $display("Test 8 PASS: Chain = %0d", result);
        end else begin
            $display("Test 8 FAIL: Chain unexpected = %0d", result);
        end

        // Test 9: Large values
        test_count++;
        get_sum(1000000, 2000000, result);
        if (result == 3000000) begin
            pass_count++;
            $display("Test 9 PASS: Large = %0d", result);
        end else begin
            $display("Test 9 FAIL: Large unexpected = %0d", result);
        end

        // Test 10: Multiple calls
        test_count++;
        for (int i = 0; i < 5; i++) begin
            get_sum(i, i, result);
        end
        if (result == 8) begin
            pass_count++;
            $display("Test 10 PASS: Loop result = %0d", result);
        end else begin
            $display("Test 10 FAIL: Loop unexpected = %0d", result);
        end

        $display("=== Output Arg Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
