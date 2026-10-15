/*
:name: test_real_ops
:description: Real Number Operations Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12 6.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_real_ops.expected
*/
// IEEE 1800-2023 Section 6.12 - Real Number Operations Tests
module test_real_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        real a, b, result;
        int i;

        $display("=== IEEE 1800-2023 Real Number Operations Tests ===");

        // Test 1: Add
        $display("Test 1: Add");
        a = 3.5;
        b = 2.5;
        result = a + b;
        if (result == 6.0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %f", result); fail_count++; end

        // Test 2: Sub
        $display("Test 2: Sub");
        result = a - b;
        if (result == 1.0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %f", result); fail_count++; end

        // Test 3: Mult
        $display("Test 3: Mult");
        a = 2.0;
        b = 3.0;
        result = a * b;
        if (result == 6.0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %f", result); fail_count++; end

        // Test 4: Div
        $display("Test 4: Div");
        a = 10.0;
        b = 4.0;
        result = a / b;
        if (result == 2.5) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %f", result); fail_count++; end

        // Test 5: Negative
        $display("Test 5: Negative");
        a = -5.5;
        if (a < 0.0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %f", a); fail_count++; end

        // Test 6: Compare
        $display("Test 6: Compare");
        a = 3.14;
        b = 2.71;
        if (a > b) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        // Test 7: To int
        $display("Test 7: To int");
        a = 7.9;
        i = int'(a);
        // The conversion rounds (6.12.1)
        if (i == 8) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", i); fail_count++; end

        // Test 8: From int
        $display("Test 8: From int");
        i = 42;
        result = real'(i);
        if (result == 42.0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %f", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
