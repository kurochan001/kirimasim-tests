/*
:name: test_arith_basic
:description: Basic Arithmetic Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arith_basic.expected
*/
// IEEE 1800-2023 Section 11.4 - Basic Arithmetic Tests
module test_arith_basic;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, b, result;

        $display("=== IEEE 1800-2023 Basic Arithmetic Tests ===");

        // Test 1-8: Arithmetic
        $display("Test 1: Add");
        a = 10; b = 5;
        result = a + b;
        if (result == 15) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        $display("Test 2: Subtract");
        result = a - b;
        if (result == 5) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        $display("Test 3: Multiply");
        result = a * b;
        if (result == 50) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        $display("Test 4: Divide");
        result = a / b;
        if (result == 2) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        $display("Test 5: Modulo");
        result = 17 % 5;
        if (result == 2) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        $display("Test 6: Power");
        result = 2 ** 4;
        if (result == 16) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        $display("Test 7: Negative");
        result = -a;
        if (result == -10) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        $display("Test 8: Complex");
        result = (a + b) * 2 - 10;
        if (result == 20) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
