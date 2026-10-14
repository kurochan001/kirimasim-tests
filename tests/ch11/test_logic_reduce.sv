/*
:name: test_logic_reduce
:description: Logic Reduction Operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logic_reduce.expected
*/
// IEEE 1800-2023 Section 11.4.9 - Logic Reduction Operators
module test_logic_reduce;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] val;
        logic result;

        $display("=== IEEE 1800-2023 Logic Reduction Tests ===");

        $display("Test 1: AND all 1s");
        val = 8'hFF;
        result = &val;
        if (result == 1'b1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %b", result); fail_count++; end

        $display("Test 2: AND with 0");
        val = 8'hFE;
        result = &val;
        if (result == 1'b0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %b", result); fail_count++; end

        $display("Test 3: OR all 0s");
        val = 8'h00;
        result = |val;
        if (result == 1'b0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %b", result); fail_count++; end

        $display("Test 4: OR with 1");
        val = 8'h01;
        result = |val;
        if (result == 1'b1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %b", result); fail_count++; end

        $display("Test 5: XOR even 1s");
        val = 8'b10101010;
        result = ^val;
        if (result == 1'b0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %b", result); fail_count++; end

        $display("Test 6: XOR odd 1s");
        val = 8'b10101011;
        result = ^val;
        if (result == 1'b1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %b", result); fail_count++; end

        $display("Test 7: NAND");
        val = 8'hFF;
        result = ~&val;
        if (result == 1'b0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %b", result); fail_count++; end

        $display("Test 8: NOR");
        val = 8'h00;
        result = ~|val;
        if (result == 1'b1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %b", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
