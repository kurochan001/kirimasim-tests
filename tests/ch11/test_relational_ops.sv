/*
:name: test_relational_ops
:description: Relational Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_relational_ops.expected
*/
// IEEE 1800-2023 Section 11.4.4 - Relational Operators Tests
module test_relational_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, b;
        logic result;

        $display("=== IEEE 1800-2023 Relational Operators Tests ===");

        // Test 1: Less than true
        $display("Test 1: < true");
        a = 5; b = 10;
        result = (a < b);
        if (result == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        // Test 2: Less than false
        $display("Test 2: < false");
        a = 10; b = 5;
        result = (a < b);
        if (result == 0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        // Test 3: Greater than true
        $display("Test 3: > true");
        a = 20; b = 10;
        result = (a > b);
        if (result == 1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: Greater than false
        $display("Test 4: > false");
        a = 5; b = 15;
        result = (a > b);
        if (result == 0) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: Less equal true
        $display("Test 5: <= true");
        a = 10; b = 10;
        result = (a <= b);
        if (result == 1) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        // Test 6: Greater equal true
        $display("Test 6: >= true");
        a = 15; b = 15;
        result = (a >= b);
        if (result == 1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        // Test 7: Negative compare
        $display("Test 7: Neg compare");
        a = -10; b = -5;
        result = (a < b);
        if (result == 1) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Zero compare
        $display("Test 8: Zero compare");
        a = 0; b = 1;
        result = (a < b);
        if (result == 1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
