/*
:name: test_format_hex
:description: Format Hex Tests
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_hex.expected
*/
// IEEE 1800-2023 Section 21.2 - Format Hex Tests
module test_format_hex;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] val8;
        logic [15:0] val16;
        int result;

        $display("=== IEEE 1800-2023 Format Hex Tests ===");

        // Test 1-8: Hex conversion tests
        $display("Test 1: 8-bit hex");
        val8 = 8'hAB;
        if (val8 == 8'hAB) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", val8); fail_count++; end

        $display("Test 2: 16-bit hex");
        val16 = 16'h1234;
        if (val16 == 16'h1234) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", val16); fail_count++; end

        $display("Test 3: Zero");
        val8 = 8'h00;
        if (val8 == 0) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: All ones");
        val8 = 8'hFF;
        if (val8 == 8'hFF) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: Hex arithmetic");
        val8 = 8'h10 + 8'h05;
        if (val8 == 8'h15) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", val8); fail_count++; end

        $display("Test 6: Hex compare");
        val16 = 16'hCAFE;
        if (val16 > 16'h1000) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: Nibble");
        val8 = 8'h5A;
        if (val8[7:4] == 4'h5 && val8[3:0] == 4'hA) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Hex assign");
        result = 32'hDEAD;
        if (result == 57005) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
