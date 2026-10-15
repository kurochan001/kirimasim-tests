/*
:name: test_func_args
:description: Function Arguments Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.5.3 13.5.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_args.expected
*/
// IEEE 1800-2023 Section 13.4 - Function Arguments Tests
module test_func_args;
    int pass_count = 0;
    int fail_count = 0;

    function int add(int a, int b);
        return a + b;
    endfunction

    function int mult2(int a, int b);
        return a * b;
    endfunction

    function int with_default(int a, int b = 10);
        return a + b;
    endfunction

    function int sum_arr(int arr[4]);
        int total;
        total = 0;
        for (int i = 0; i < 4; i++) total = total + arr[i];
        return total;
    endfunction

    initial begin
        int result;
        int arr[4];

        $display("=== IEEE 1800-2023 Function Arguments Tests ===");

        // Test 1: Two args
        $display("Test 1: Two args");
        result = add(3, 4);
        if (result == 7) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Multiply two
        $display("Test 2: Multiply");
        result = mult2(6, 7);
        if (result == 42) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Default arg
        $display("Test 3: Default arg");
        result = with_default(5);
        if (result == 15) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Override default
        $display("Test 4: Override default");
        result = with_default(5, 20);
        if (result == 25) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Array arg
        $display("Test 5: Array arg");
        arr = '{1, 2, 3, 4};
        result = sum_arr(arr);
        if (result == 10) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Expression as arg
        $display("Test 6: Expression arg");
        result = add(2 + 3, 4 + 4);
        if (result == 13) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: Nested calls
        $display("Test 7: Nested calls");
        result = add(add(1, 2), add(3, 4));
        if (result == 10) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Negative args
        $display("Test 8: Negative args");
        result = add(-5, 10);
        if (result == 5) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
