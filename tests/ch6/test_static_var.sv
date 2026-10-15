/*
:name: test_static_var
:description: Static and Automatic Variable Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 13.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_var.expected
*/
// IEEE 1800-2023 Section 6.21 - Static and Automatic Variable Tests
module test_static_var;
    int pass_count = 0;
    int fail_count = 0;
    int module_var = 0;

    function automatic int add_auto(int x);
        int local_sum = 0;
        local_sum = local_sum + x;
        return local_sum;
    endfunction

    function int multiply(int x, int y);
        return x * y;
    endfunction

    // IEEE 1800-2023 §13.5.1: Use automatic to ensure fresh local variables on each call
    function automatic int compute_sum(int n);
        int total = 0;
        for (int i = 1; i <= n; i++) total += i;
        return total;
    endfunction

    initial begin
        int result;

        $display("=== IEEE 1800-2023 Static/Auto Variable Tests ===");

        // Test 1: Module variable access
        $display("Test 1: Module variable");
        module_var = 10;
        if (module_var == 10) begin $display("Test 1 PASS: var=%0d", module_var); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        // Test 2: Module variable persistence
        $display("Test 2: Module var persistence");
        module_var = module_var + 5;
        if (module_var == 15) begin $display("Test 2 PASS: var=%0d", module_var); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        // Test 3: Automatic function
        $display("Test 3: Auto function call");
        result = add_auto(10);
        if (result == 10) begin $display("Test 3 PASS: result=%0d", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", result); fail_count++; end

        // Test 4: Auto function resets
        $display("Test 4: Auto function resets");
        result = add_auto(20);
        if (result == 20) begin $display("Test 4 PASS: result=%0d", result); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", result); fail_count++; end

        // Test 5: Multiply function
        $display("Test 5: Multiply function");
        result = multiply(6, 7);
        if (result == 42) begin $display("Test 5 PASS: result=%0d", result); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", result); fail_count++; end

        // Test 6: Compute sum
        $display("Test 6: Compute sum 1-5");
        result = compute_sum(5);
        if (result == 15) begin $display("Test 6 PASS: sum=%0d", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", result); fail_count++; end

        // Test 7: Compute larger sum
        $display("Test 7: Compute sum 1-10");
        result = compute_sum(10);
        if (result == 55) begin $display("Test 7 PASS: sum=%0d", result); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", result); fail_count++; end

        // Test 8: Multiple operations
        $display("Test 8: Combined operations");
        module_var = multiply(3, 4);
        result = module_var + add_auto(5);
        if (result == 17) begin $display("Test 8 PASS: result=%0d", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
