/*
:name: test_reduce_ops
:description: Reduction Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduce_ops.expected
*/
// IEEE 1800-2023 Section 11.4.9 - Reduction Operators Tests
module test_reduce_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] val;
        logic result;

        $display("=== IEEE 1800-2023 Reduction Operators Tests ===");

        // Test 1: AND all 1s
        $display("Test 1: AND all 1s");
        val = 8'hFF;
        result = &val;
        if (result == 1'b1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: got %b", result); fail_count++; end

        // Test 2: AND with zero
        $display("Test 2: AND zero");
        val = 8'hF0;
        result = &val;
        if (result == 1'b0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: got %b", result); fail_count++; end

        // Test 3: OR all zeros
        $display("Test 3: OR zeros");
        val = 8'h00;
        result = |val;
        if (result == 1'b0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: got %b", result); fail_count++; end

        // Test 4: OR with one
        $display("Test 4: OR one");
        val = 8'h01;
        result = |val;
        if (result == 1'b1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: got %b", result); fail_count++; end

        // Test 5: XOR even 1s
        $display("Test 5: XOR even");
        val = 8'hAA;
        result = ^val;
        if (result == 1'b0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: got %b", result); fail_count++; end

        // Test 6: XOR odd 1s
        $display("Test 6: XOR odd");
        val = 8'h07;
        result = ^val;
        if (result == 1'b1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: got %b", result); fail_count++; end

        // Test 7: NAND all 1s
        $display("Test 7: NAND all 1s");
        val = 8'hFF;
        result = ~&val;
        if (result == 1'b0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: got %b", result); fail_count++; end

        // Test 8: NOR all zeros
        $display("Test 8: NOR zeros");
        val = 8'h00;
        result = ~|val;
        if (result == 1'b1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: got %b", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
