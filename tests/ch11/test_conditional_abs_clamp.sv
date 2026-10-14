/*
:name: test_conditional_abs_clamp
:description: Absolute value, min, max and clamp with the conditional operator, and $sqrt (IEEE 1800-2023 Sections 11.4.11 and 20.8.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11 20.8.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_abs_clamp.expected
*/
// IEEE 1800-2023 Sections 11.4.11 and 20.8.2 - Absolute value, min, max and clamp with the conditional operator, and $sqrt
module test_conditional_abs_clamp;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, result;
        real r;

        $display("=== IEEE 1800-2023 Math Functions Tests ===");

        // Test 1-8
        $display("Test 1: Abs neg");
        a = -5;
        result = (a < 0) ? -a : a;
        if (result == 5) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        $display("Test 2: Abs pos");
        a = 10;
        result = (a < 0) ? -a : a;
        if (result == 10) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        $display("Test 3: Abs zero");
        a = 0;
        result = (a < 0) ? -a : a;
        if (result == 0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        $display("Test 4: Min");
        a = 5;
        result = (a < 10) ? a : 10;
        if (result == 5) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        $display("Test 5: Max");
        a = 15;
        result = (a > 10) ? a : 10;
        if (result == 15) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        $display("Test 6: Clamp low");
        a = -10;
        result = (a < 0) ? 0 : a;
        if (result == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        $display("Test 7: Clamp high");
        a = 200;
        result = (a > 100) ? 100 : a;
        if (result == 100) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        $display("Test 8: Real sqrt");
        r = 4.0;
        r = $sqrt(r);
        if (r == 2.0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %f", r); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
