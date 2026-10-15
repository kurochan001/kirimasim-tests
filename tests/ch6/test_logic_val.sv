/*
:name: test_logic_val
:description: Logic Value Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logic_val.expected
*/
// IEEE 1800-2023 Section 6.8 - Logic Value Tests
module test_logic_val;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [3:0] val;
        logic bit0, bit1;

        $display("=== IEEE 1800-2023 Logic Value Tests ===");

        // Test 1-8: Logic value tests
        $display("Test 1: All zeros");
        val = 4'b0000;
        if (val == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: All ones");
        val = 4'b1111;
        if (val == 4'hF) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Single bit");
        bit0 = 1'b0;
        bit1 = 1'b1;
        if (bit0 == 0 && bit1 == 1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Toggle");
        bit0 = ~bit0;
        if (bit0 == 1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: AND");
        val = 4'b1010 & 4'b1100;
        if (val == 4'b1000) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %b", val); fail_count++; end

        $display("Test 6: OR");
        val = 4'b1010 | 4'b0101;
        if (val == 4'b1111) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %b", val); fail_count++; end

        $display("Test 7: XOR");
        val = 4'b1100 ^ 4'b1010;
        if (val == 4'b0110) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %b", val); fail_count++; end

        $display("Test 8: NOT");
        val = ~4'b1010;
        if (val == 4'b0101) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %b", val); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
