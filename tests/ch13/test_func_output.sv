/*
:name: test_func_output
:description: Function Output Args Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 13.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_output.expected
*/
// IEEE 1800-2023 Section 13.4.2 - Function Output Args Tests
module test_func_output;
    int pass_count = 0;
    int fail_count = 0;

    function automatic void get_vals(output int a, output int b);
        a = 10;
        b = 20;
    endfunction

    function automatic int add_get(input int x, output int doubled);
        doubled = x * 2;
        return x + 1;
    endfunction

    initial begin
        int v1, v2, result;

        $display("=== IEEE 1800-2023 Function Output Args Tests ===");

        // Test 1: Basic output
        $display("Test 1: Basic");
        get_vals(v1, v2);
        if (v1 == 10 && v2 == 20) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d %0d", v1, v2); fail_count++; end

        // Test 2: Return with output
        $display("Test 2: Return+Out");
        result = add_get(5, v1);
        if (result == 6 && v1 == 10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d %0d", result, v1); fail_count++; end

        // Test 3: Zero input
        $display("Test 3: Zero");
        result = add_get(0, v1);
        if (result == 1 && v1 == 0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d %0d", result, v1); fail_count++; end

        // Test 4: Negative
        $display("Test 4: Negative");
        result = add_get(-5, v1);
        if (result == -4 && v1 == -10) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d %0d", result, v1); fail_count++; end

        // Test 5: Large
        $display("Test 5: Large");
        result = add_get(100, v1);
        if (result == 101 && v1 == 200) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d %0d", result, v1); fail_count++; end

        // Test 6: Call twice
        $display("Test 6: Twice");
        get_vals(v1, v2);
        get_vals(v1, v2);
        if (v1 == 10 && v2 == 20) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        // Test 7: One
        $display("Test 7: One");
        result = add_get(1, v1);
        if (result == 2 && v1 == 2) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d %0d", result, v1); fail_count++; end

        // Test 8: Chain
        $display("Test 8: Chain");
        result = add_get(10, v1);
        result = add_get(result, v2);
        if (v1 == 20 && v2 == 22) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d %0d", v1, v2); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
