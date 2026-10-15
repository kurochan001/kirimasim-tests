/*
:name: test_auto_task
:description: Automatic Function Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3.1 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_auto_task.expected
*/
// IEEE 1800-2023 Section 13.3.1 - Automatic Function Tests
module test_auto_task;
    int pass_count = 0;
    int fail_count = 0;

    function automatic int compute(int a, int b);
        int temp;
        temp = a + b;
        return temp;
    endfunction

    function automatic int factorial(int n);
        int i, acc;
        acc = 1;
        for (i = 1; i <= n; i++)
            acc = acc * i;
        return acc;
    endfunction

    function automatic int double_val(int val);
        return val * 2;
    endfunction

    initial begin
        int result, r1, r2;

        $display("=== IEEE 1800-2023 Automatic Function Tests ===");

        $display("Test 1: Simple sum");
        result = compute(3, 4);
        if (result == 7) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        $display("Test 2: Zero sum");
        result = compute(0, 0);
        if (result == 0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        $display("Test 3: Factorial 5");
        result = factorial(5);
        if (result == 120) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        $display("Test 4: Factorial 1");
        result = factorial(1);
        if (result == 1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        $display("Test 5: Double val");
        r1 = double_val(10);
        if (r1 == 20) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", r1); fail_count++; end

        $display("Test 6: Double again");
        r1 = double_val(r1);
        if (r1 == 40) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", r1); fail_count++; end

        $display("Test 7: Multiple calls");
        r1 = compute(10, 20);
        r2 = compute(30, 40);
        if (r1 == 30 && r2 == 70) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: r1=%0d, r2=%0d", r1, r2); fail_count++; end

        $display("Test 8: Factorial 0");
        result = factorial(0);
        if (result == 1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
