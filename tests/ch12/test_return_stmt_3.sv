/*
:name: test_return_stmt_3
:description: Return Statement Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.8 13.4.1 13.4.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_return_stmt_3.expected
*/
// IEEE 1800-2023 Section 12.8 - Return Statement Tests
module test_return_stmt_3;
    int pass_count = 0;
    int fail_count = 0;

    function int add(int a, int b);
        return a + b;
    endfunction

    function automatic int factorial(int n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    endfunction

    function int max(int a, int b);
        if (a > b) return a;
        return b;
    endfunction

    function int find_first(int arr[5], int val);
        for (int i = 0; i < 5; i++)
            if (arr[i] == val) return i;
        return -1;
    endfunction

    function int early_return(int x);
        if (x < 0) return 0;
        if (x > 100) return 100;
        return x;
    endfunction

    initial begin
        int result;
        int arr[5];

        $display("=== IEEE 1800-2023 Return Statement Tests ===");

        // Test 1: Simple return
        $display("Test 1: Simple return");
        result = add(3, 4);
        if (result == 7) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Factorial
        $display("Test 2: Factorial");
        result = factorial(5);
        if (result == 120) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Max first
        $display("Test 3: Max first");
        result = max(10, 5);
        if (result == 10) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Max second
        $display("Test 4: Max second");
        result = max(5, 10);
        if (result == 10) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Find first
        $display("Test 5: Find first");
        arr = '{1, 2, 3, 4, 5};
        result = find_first(arr, 3);
        if (result == 2) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Not found
        $display("Test 6: Not found");
        result = find_first(arr, 10);
        if (result == -1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: Early return low
        $display("Test 7: Early low");
        result = early_return(-5);
        if (result == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Early return high
        $display("Test 8: Early high");
        result = early_return(200);
        if (result == 100) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
