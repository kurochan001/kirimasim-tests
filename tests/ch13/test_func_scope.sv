/*
:name: test_func_scope
:description: Function Scope Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2 13.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_scope.expected
*/
// IEEE 1800-2023 Section 13.4 - Function Scope Tests
module test_func_scope;
    int pass_count = 0;
    int fail_count = 0;

    int module_var = 10;

    function automatic int add_local(int a, int b);
        int sum;
        sum = a + b;
        return sum;
    endfunction

    function automatic int use_global();
        return module_var;
    endfunction

    function automatic int modify_arg(int val);
        val = val * 2;
        return val;
    endfunction

    function automatic int nested_call(int x);
        return add_local(x, 5);
    endfunction

    initial begin
        int result;

        $display("=== IEEE 1800-2023 Function Scope Tests ===");

        $display("Test 1: Local sum");
        result = add_local(3, 4);
        if (result == 7) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        $display("Test 2: Use global");
        result = use_global();
        if (result == 10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        $display("Test 3: Arg modify");
        result = modify_arg(5);
        if (result == 10) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        $display("Test 4: Nested call");
        result = nested_call(10);
        if (result == 15) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        $display("Test 5: Multiple calls");
        result = add_local(1, 2) + add_local(3, 4);
        if (result == 10) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        $display("Test 6: Global unchanged");
        if (module_var == 10) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", module_var); fail_count++; end

        $display("Test 7: Zero args");
        result = add_local(0, 0);
        if (result == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        $display("Test 8: Negative args");
        result = add_local(-3, 8);
        if (result == 5) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
