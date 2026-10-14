/*
:name: test_ternary_op
:description: Ternary Operator Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ternary_op.expected
*/
// IEEE 1800-2023 Section 11.4.11 - Ternary Operator Tests
module test_ternary_op;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, b, result;

        $display("=== IEEE 1800-2023 Ternary Operator Tests ===");

        // Test 1: True condition
        $display("Test 1: True cond");
        a = 5;
        result = (a > 0) ? 1 : 0;
        if (result == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: False condition
        $display("Test 2: False cond");
        a = -1;
        result = (a > 0) ? 1 : 0;
        if (result == 0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Expression result
        $display("Test 3: Expr result");
        a = 5; b = 3;
        result = (a > b) ? a + b : a - b;
        if (result == 8) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Nested ternary
        $display("Test 4: Nested");
        a = 0;
        result = (a > 0) ? 1 : (a < 0) ? -1 : 0;
        if (result == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Variable as condition
        $display("Test 5: Var cond");
        a = 1;
        result = a ? 100 : 200;
        if (result == 100) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Zero as false
        $display("Test 6: Zero false");
        a = 0;
        result = a ? 100 : 200;
        if (result == 200) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: Complex condition
        $display("Test 7: Complex");
        a = 5; b = 10;
        result = (a > 0 && b > 0) ? a * b : 0;
        if (result == 50) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Assign with ternary
        $display("Test 8: Assign");
        a = 7;
        b = (a > 5) ? a : 5;
        if (b == 7) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", b); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
