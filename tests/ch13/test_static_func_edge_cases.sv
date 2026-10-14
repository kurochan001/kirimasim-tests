/*
:name: test_static_func_edge_cases
:description: Static function edge cases
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2 6.21
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_func_edge_cases.expected
*/
// IEEE 1800-2023 §13.4.2: Static function edge cases
// Tests for static storage in functions

module test_static_func_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    function int count_calls();
        static int call_count = 0;
        call_count++;
        return call_count;
    endfunction

    function int accumulate(int val);
        static int total = 0;
        total += val;
        return total;
    endfunction

    function int get_last_value(int val);
        static int last = -1;
        static int prev;
        // Assigned here so the result does not depend on the order of static initializers.
        prev = last;
        last = val;
        return prev;
    endfunction

    function int multi_static(int x);
        static int counter = 0;
        static int sum = 0;
        counter++;
        sum += x;
        return counter * sum;
    endfunction

    initial begin
        int result;

        // Test 1: First call count
        test_count++;
        result = count_calls();
        if (result == 1) begin
            pass_count++;
            $display("Test 1 PASS: First count = %0d", result);
        end else begin
            $display("Test 1 FAIL: Count unexpected = %0d", result);
        end

        // Test 2: Second call count
        test_count++;
        result = count_calls();
        if (result == 2) begin
            pass_count++;
            $display("Test 2 PASS: Second count = %0d", result);
        end else begin
            $display("Test 2 FAIL: Count2 unexpected = %0d", result);
        end

        // Test 3: Multiple calls
        test_count++;
        for (int i = 0; i < 3; i++) result = count_calls();
        if (result == 5) begin
            pass_count++;
            $display("Test 3 PASS: Multi count = %0d", result);
        end else begin
            $display("Test 3 FAIL: Multi unexpected = %0d", result);
        end

        // Test 4: Accumulate single
        test_count++;
        result = accumulate(10);
        if (result == 10) begin
            pass_count++;
            $display("Test 4 PASS: Accum = %0d", result);
        end else begin
            $display("Test 4 FAIL: Accum unexpected = %0d", result);
        end

        // Test 5: Accumulate multiple
        test_count++;
        result = accumulate(5);
        result = accumulate(3);
        if (result == 18) begin
            pass_count++;
            $display("Test 5 PASS: Multi accum = %0d", result);
        end else begin
            $display("Test 5 FAIL: Accum unexpected = %0d", result);
        end

        // Test 6: Get last first call
        test_count++;
        result = get_last_value(100);
        if (result == -1) begin
            pass_count++;
            $display("Test 6 PASS: Last init = %0d", result);
        end else begin
            $display("Test 6 FAIL: Init unexpected = %0d", result);
        end

        // Test 7: Get last second call
        test_count++;
        result = get_last_value(200);
        if (result == 100) begin
            pass_count++;
            $display("Test 7 PASS: Last prev = %0d", result);
        end else begin
            $display("Test 7 FAIL: Prev unexpected = %0d", result);
        end

        // Test 8: Get last chain
        test_count++;
        result = get_last_value(300);
        if (result == 200) begin
            pass_count++;
            $display("Test 8 PASS: Chain last = %0d", result);
        end else begin
            $display("Test 8 FAIL: Chain unexpected = %0d", result);
        end

        // Test 9: Multi static
        test_count++;
        result = multi_static(5);
        if (result == 5) begin
            pass_count++;
            $display("Test 9 PASS: Multi static = %0d", result);
        end else begin
            $display("Test 9 FAIL: Multi unexpected = %0d", result);
        end

        // Test 10: Multi static again
        test_count++;
        result = multi_static(5);
        if (result == 20) begin
            pass_count++;
            $display("Test 10 PASS: Static again = %0d", result);
        end else begin
            $display("Test 10 FAIL: Again unexpected = %0d", result);
        end

        $display("=== Static Func Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
