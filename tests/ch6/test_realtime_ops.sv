/*
:name: test_realtime_ops
:description: Realtime Operations Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.12 6.12.2 11.4.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_realtime_ops.expected
*/
// IEEE 1800-2023 Section 5.7 - Realtime Operations Tests
module test_realtime_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        real r1, r2, result;
        realtime rt1, rt2;
        int i;

        $display("=== IEEE 1800-2023 Realtime Operations Tests ===");

        // Test 1: Real assignment
        $display("Test 1: Real assignment");
        r1 = 3.14159;
        if (r1 > 3.14 && r1 < 3.15) begin $display("Test 1 PASS: r1=%f", r1); pass_count++; end
        else begin $display("Test 1 FAIL: got %f", r1); fail_count++; end

        // Test 2: Real addition
        $display("Test 2: Real addition");
        r1 = 1.5;
        r2 = 2.5;
        result = r1 + r2;
        if (result == 4.0) begin $display("Test 2 PASS: 1.5 + 2.5 = %f", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %f", result); fail_count++; end

        // Test 3: Real multiplication
        $display("Test 3: Real multiplication");
        r1 = 2.5;
        r2 = 4.0;
        result = r1 * r2;
        if (result == 10.0) begin $display("Test 3 PASS: 2.5 * 4.0 = %f", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %f", result); fail_count++; end

        // Test 4: Real division
        $display("Test 4: Real division");
        r1 = 10.0;
        r2 = 4.0;
        result = r1 / r2;
        if (result == 2.5) begin $display("Test 4 PASS: 10.0 / 4.0 = %f", result); pass_count++; end
        else begin $display("Test 4 FAIL: got %f", result); fail_count++; end

        // Test 5: Real to int conversion (rounds to nearest per §6.12.1)
        $display("Test 5: Real to int");
        r1 = 7.9;
        i = r1;
        if (i == 8) begin $display("Test 5 PASS: int(7.9) = %0d", i); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", i); fail_count++; end

        // Test 6: Int to real conversion
        $display("Test 6: Int to real");
        i = 42;
        r1 = i;
        if (r1 == 42.0) begin $display("Test 6 PASS: real(42) = %f", r1); pass_count++; end
        else begin $display("Test 6 FAIL: got %f", r1); fail_count++; end

        // Test 7: Real comparison
        $display("Test 7: Real comparison");
        r1 = 5.5;
        r2 = 5.5;
        if (r1 == r2) begin $display("Test 7 PASS: 5.5 == 5.5"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Real negative
        $display("Test 8: Real negative");
        r1 = -3.5;
        r2 = 1.5;
        result = r1 + r2;
        if (result == -2.0) begin $display("Test 8 PASS: -3.5 + 1.5 = %f", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %f", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
