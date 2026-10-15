/*
:name: test_signed_arith
:description: Signed Arithmetic Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_arith.expected
*/
// IEEE 1800-2023 Section 11.4 - Signed Arithmetic Tests
module test_signed_arith;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int signed a, b, result;

        $display("=== IEEE 1800-2023 Signed Arithmetic Tests ===");

        // Test 1: Positive add
        $display("Test 1: Pos add");
        a = 10; b = 20;
        result = a + b;
        if (result == 30) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Negative add
        $display("Test 2: Neg add");
        a = -10; b = -20;
        result = a + b;
        if (result == -30) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Mixed add
        $display("Test 3: Mixed add");
        a = 30; b = -10;
        result = a + b;
        if (result == 20) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Neg sub
        $display("Test 4: Neg sub");
        a = -5; b = 10;
        result = a - b;
        if (result == -15) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Neg mult
        $display("Test 5: Neg mult");
        a = -5; b = 6;
        result = a * b;
        if (result == -30) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Neg neg mult
        $display("Test 6: Neg neg mult");
        a = -4; b = -5;
        result = a * b;
        if (result == 20) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: Neg div
        $display("Test 7: Neg div");
        a = -20; b = 5;
        result = a / b;
        if (result == -4) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Neg mod
        $display("Test 8: Neg mod");
        a = -17; b = 5;
        result = a % b;
        if (result == -2) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
