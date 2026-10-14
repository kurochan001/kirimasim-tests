/*
:name: test_logical_ops
:description: Logical Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logical_ops.expected
*/
// IEEE 1800-2023 Section 11.4.7 - Logical Operators Tests
module test_logical_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, b;
        logic result;

        $display("=== IEEE 1800-2023 Logical Operators Tests ===");

        // Test 1: AND true
        $display("Test 1: && true");
        a = 1; b = 1;
        result = (a && b);
        if (result == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        // Test 2: AND false
        $display("Test 2: && false");
        a = 1; b = 0;
        result = (a && b);
        if (result == 0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        // Test 3: OR true
        $display("Test 3: || true");
        a = 0; b = 1;
        result = (a || b);
        if (result == 1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: OR false
        $display("Test 4: || false");
        a = 0; b = 0;
        result = (a || b);
        if (result == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: NOT true
        $display("Test 5: ! true");
        a = 0;
        result = !a;
        if (result == 1) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        // Test 6: NOT false
        $display("Test 6: ! false");
        a = 5;
        result = !a;
        if (result == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        // Test 7: Complex AND
        $display("Test 7: Complex &&");
        a = 10; b = 20;
        result = (a > 5) && (b < 30);
        if (result == 1) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Complex OR
        $display("Test 8: Complex ||");
        a = 1; b = 0;
        result = (a == 0) || (b == 0);
        if (result == 1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
