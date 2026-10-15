/*
:name: test_integer_ops
:description: Integer Operations Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_integer_ops.expected
*/
// IEEE 1800-2023 Section 6.11 - Integer Operations Tests
module test_integer_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, b, result;
        shortint si;
        longint li;
        byte by;

        $display("=== IEEE 1800-2023 Integer Operations Tests ===");

        // Test 1: Int add
        $display("Test 1: Int add");
        a = 100;
        b = 200;
        result = a + b;
        if (result == 300) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Int sub
        $display("Test 2: Int sub");
        a = 500;
        b = 150;
        result = a - b;
        if (result == 350) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Shortint
        $display("Test 3: Shortint");
        si = 1000;
        if (si == 1000) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", si); fail_count++; end

        // Test 4: Longint
        $display("Test 4: Longint");
        li = 1000000000;
        if (li == 1000000000) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", li); fail_count++; end

        // Test 5: Byte
        $display("Test 5: Byte");
        by = 127;
        if (by == 127) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", by); fail_count++; end

        // Test 6: Negative byte
        $display("Test 6: Neg byte");
        by = -1;
        if (by == -1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", by); fail_count++; end

        // Test 7: Int mult
        $display("Test 7: Mult");
        a = 25;
        b = 4;
        result = a * b;
        if (result == 100) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: Int div
        $display("Test 8: Div");
        a = 100;
        b = 5;
        result = a / b;
        if (result == 20) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
