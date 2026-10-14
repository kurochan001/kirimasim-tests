/*
:name: test_bit_access
:description: Bit Access Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_access.expected
*/
// IEEE 1800-2023 Section 11.5 - Bit Access Tests
module test_bit_access;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] val;

        $display("=== IEEE 1800-2023 Bit Access Tests ===");

        val = 8'b10101010;

        // Test 1-8: Bit access
        $display("Test 1: Bit 0");
        if (val[0] == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: Bit 1");
        if (val[1] == 1) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Bit 7");
        if (val[7] == 1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Part select");
        if (val[3:0] == 4'hA) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", val[3:0]); fail_count++; end

        $display("Test 5: High nibble");
        if (val[7:4] == 4'hA) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", val[7:4]); fail_count++; end

        $display("Test 6: Set bit");
        val[0] = 1;
        if (val[0] == 1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: Clear bit");
        val[1] = 0;
        if (val[1] == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Middle bits");
        val = 8'b00111100;
        if (val[5:2] == 4'hF) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", val[5:2]); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
