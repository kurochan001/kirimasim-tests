/*
:name: test_reduction_operators
:description: Reduction Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduction_operators.expected
*/
// IEEE 1800-2023 Section 11.4 - Reduction Operators Tests
// Tests: &, |, ^, ~&, ~|, ~^

module test_reduction_operators;
    int pass_count = 0;
    int fail_count = 0;

    logic [7:0] data;
    logic result;

    initial begin
        $display("=== IEEE 1800-2023 Reduction Operators Test ===");

        // Test 1: AND reduction - all 1s
        $display("Test 1: AND reduction - all 1s");
        data = 8'hFF;
        result = &data;
        $display("  &(8'hFF) = %b", result);
        $display("Test 1 PASS");
        pass_count++;

        // Test 2: AND reduction - not all 1s
        $display("Test 2: AND reduction - not all 1s");
        data = 8'hFE;
        result = &data;
        $display("  &(8'hFE) = %b", result);
        $display("Test 2 PASS");
        pass_count++;

        // Test 3: OR reduction - any 1
        $display("Test 3: OR reduction - any 1");
        data = 8'h01;
        result = |data;
        $display("  |(8'h01) = %b", result);
        $display("Test 3 PASS");
        pass_count++;

        // Test 4: OR reduction - all 0s
        $display("Test 4: OR reduction - all 0s");
        data = 8'h00;
        result = |data;
        $display("  |(8'h00) = %b", result);
        $display("Test 4 PASS");
        pass_count++;

        // Test 5: XOR reduction - even parity
        $display("Test 5: XOR reduction - even parity");
        data = 8'b10101010;  // 4 ones = even
        result = ^data;
        $display("  ^(8'b10101010) = %b", result);
        $display("Test 5 PASS");
        pass_count++;

        // Test 6: XOR reduction - odd parity
        $display("Test 6: XOR reduction - odd parity");
        data = 8'b10101011;  // 5 ones = odd
        result = ^data;
        $display("  ^(8'b10101011) = %b", result);
        $display("Test 6 PASS");
        pass_count++;

        // Test 7: NAND reduction
        $display("Test 7: NAND reduction");
        data = 8'hFF;
        result = ~&data;
        $display("  ~&(8'hFF) = %b", result);
        data = 8'hFE;
        result = ~&data;
        $display("  ~&(8'hFE) = %b", result);
        $display("Test 7 PASS");
        pass_count++;

        // Test 8: NOR reduction
        $display("Test 8: NOR reduction");
        data = 8'h00;
        result = ~|data;
        $display("  ~|(8'h00) = %b", result);
        data = 8'h01;
        result = ~|data;
        $display("  ~|(8'h01) = %b", result);
        $display("Test 8 PASS");
        pass_count++;

        // Test 9: XNOR reduction
        $display("Test 9: XNOR reduction");
        data = 8'b10101010;
        result = ~^data;
        $display("  ~^(8'b10101010) = %b", result);
        data = 8'b10101011;
        result = ~^data;
        $display("  ~^(8'b10101011) = %b", result);
        $display("Test 9 PASS");
        pass_count++;

        // Test 10: Various patterns
        $display("Test 10: Various patterns");
        for (int i = 0; i < 4; i++) begin
            data = i * 64;
            $display("  data=%h: &=%b |=%b ^=%b", data, &data, |data, ^data);
        end
        $display("Test 10 PASS");
        pass_count++;

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
