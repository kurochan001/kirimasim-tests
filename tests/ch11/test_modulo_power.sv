/*
:name: test_modulo_power
:description: Modulo and Power Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modulo_power.expected
*/
// IEEE 1800-2023 Section 11.4 - Modulo and Power Operators Tests
module test_modulo_power;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, b, result;

        $display("=== IEEE 1800-2023 Modulo/Power Tests ===");

        // Test 1: Basic modulo
        $display("Test 1: Basic modulo");
        a = 17;
        b = 5;
        result = a % b;
        if (result == 2) begin $display("Test 1 PASS: 17 %% 5 = %0d", result); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", result); fail_count++; end

        // Test 2: Modulo zero remainder
        $display("Test 2: Modulo zero remainder");
        a = 20;
        b = 4;
        result = a % b;
        if (result == 0) begin $display("Test 2 PASS: 20 %% 4 = %0d", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", result); fail_count++; end

        // Test 3: Modulo with negative
        $display("Test 3: Modulo negative dividend");
        a = -17;
        b = 5;
        result = a % b;
        if (result == -2) begin $display("Test 3 PASS: -17 %% 5 = %0d", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", result); fail_count++; end

        // Test 4: Power of 2
        $display("Test 4: Power operator");
        a = 2;
        b = 10;
        result = a ** b;
        if (result == 1024) begin $display("Test 4 PASS: 2 ** 10 = %0d", result); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", result); fail_count++; end

        // Test 5: Power with base 3
        $display("Test 5: Power base 3");
        a = 3;
        b = 4;
        result = a ** b;
        if (result == 81) begin $display("Test 5 PASS: 3 ** 4 = %0d", result); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", result); fail_count++; end

        // Test 6: Power of 0
        $display("Test 6: Power of 0");
        a = 5;
        b = 0;
        result = a ** b;
        if (result == 1) begin $display("Test 6 PASS: 5 ** 0 = %0d", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", result); fail_count++; end

        // Test 7: Modulo small numbers
        $display("Test 7: Modulo small");
        a = 7;
        b = 3;
        result = a % b;
        if (result == 1) begin $display("Test 7 PASS: 7 %% 3 = %0d", result); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", result); fail_count++; end

        // Test 8: Power of 1
        $display("Test 8: Power exponent 1");
        a = 42;
        b = 1;
        result = a ** b;
        if (result == 42) begin $display("Test 8 PASS: 42 ** 1 = %0d", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
