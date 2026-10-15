/*
:name: test_reduction_ops
:description: Reduction Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduction_ops.expected
*/
// IEEE 1800-2023 Section 11.4.9 - Reduction Operators Tests
module test_reduction_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] val;
        logic result;

        $display("=== IEEE 1800-2023 Reduction Operators Tests ===");

        // Test 1: Reduction AND
        $display("Test 1: Reduction AND");
        val = 8'hFF;
        result = &val;
        if (result == 1) begin $display("Test 1 PASS: &0xFF=%b", result); pass_count++; end
        else begin $display("Test 1 FAIL: got %b", result); fail_count++; end

        // Test 2: Reduction AND false
        $display("Test 2: Reduction AND false");
        val = 8'hFE;
        result = &val;
        if (result == 0) begin $display("Test 2 PASS: &0xFE=%b", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %b", result); fail_count++; end

        // Test 3: Reduction OR
        $display("Test 3: Reduction OR");
        val = 8'h01;
        result = |val;
        if (result == 1) begin $display("Test 3 PASS: |0x01=%b", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %b", result); fail_count++; end

        // Test 4: Reduction OR false
        $display("Test 4: Reduction OR false");
        val = 8'h00;
        result = |val;
        if (result == 0) begin $display("Test 4 PASS: |0x00=%b", result); pass_count++; end
        else begin $display("Test 4 FAIL: got %b", result); fail_count++; end

        // Test 5: Reduction XOR (even 1s)
        $display("Test 5: Reduction XOR even");
        val = 8'h0F;  // 4 ones
        result = ^val;
        if (result == 0) begin $display("Test 5 PASS: ^0x0F=%b", result); pass_count++; end
        else begin $display("Test 5 FAIL: got %b", result); fail_count++; end

        // Test 6: Reduction XOR (odd 1s)
        $display("Test 6: Reduction XOR odd");
        val = 8'h07;  // 3 ones
        result = ^val;
        if (result == 1) begin $display("Test 6 PASS: ^0x07=%b", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %b", result); fail_count++; end

        // Test 7: Reduction NAND
        $display("Test 7: Reduction NAND");
        val = 8'hFF;
        result = ~&val;
        if (result == 0) begin $display("Test 7 PASS: ~&0xFF=%b", result); pass_count++; end
        else begin $display("Test 7 FAIL: got %b", result); fail_count++; end

        // Test 8: Reduction NOR
        $display("Test 8: Reduction NOR");
        val = 8'h00;
        result = ~|val;
        if (result == 1) begin $display("Test 8 PASS: ~|0x00=%b", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %b", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
