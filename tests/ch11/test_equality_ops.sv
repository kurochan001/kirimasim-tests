/*
:name: test_equality_ops
:description: Equality Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_equality_ops.expected
*/
// IEEE 1800-2023 Section 11.4.5 - Equality Operators Tests
module test_equality_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, b;
        logic result;

        $display("=== IEEE 1800-2023 Equality Operators Tests ===");

        // Test 1: Equal true
        $display("Test 1: == true");
        a = 42; b = 42;
        result = (a == b);
        if (result == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        // Test 2: Equal false
        $display("Test 2: == false");
        a = 42; b = 43;
        result = (a == b);
        if (result == 0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        // Test 3: Not equal true
        $display("Test 3: != true");
        a = 10; b = 20;
        result = (a != b);
        if (result == 1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: Not equal false
        $display("Test 4: != false");
        a = 100; b = 100;
        result = (a != b);
        if (result == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: Case equal
        $display("Test 5: === equal");
        a = 55; b = 55;
        result = (a === b);
        if (result == 1) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        // Test 6: Case not equal
        $display("Test 6: !== not equal");
        a = 1; b = 2;
        result = (a !== b);
        if (result == 1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        // Test 7: Zero equality
        $display("Test 7: Zero ==");
        a = 0; b = 0;
        result = (a == b);
        if (result == 1) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Negative equality
        $display("Test 8: Neg ==");
        a = -5; b = -5;
        result = (a == b);
        if (result == 1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
