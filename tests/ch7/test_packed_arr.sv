/*
:name: test_packed_arr
:description: Packed Array Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_arr.expected
*/
// IEEE 1800-2023 Section 7.4.1 - Packed Array Tests
module test_packed_arr;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [15:0] packed16;
        logic [7:0] byte0, byte1;

        $display("=== IEEE 1800-2023 Packed Array Tests ===");

        $display("Test 1: Full assign");
        packed16 = 16'hABCD;
        if (packed16 == 16'hABCD) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", packed16); fail_count++; end

        $display("Test 2: High byte");
        byte1 = packed16[15:8];
        if (byte1 == 8'hAB) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", byte1); fail_count++; end

        $display("Test 3: Low byte");
        byte0 = packed16[7:0];
        if (byte0 == 8'hCD) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", byte0); fail_count++; end

        $display("Test 4: Set high");
        packed16[15:8] = 8'h12;
        if (packed16 == 16'h12CD) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", packed16); fail_count++; end

        $display("Test 5: Set low");
        packed16[7:0] = 8'h34;
        if (packed16 == 16'h1234) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", packed16); fail_count++; end

        $display("Test 6: Single bit");
        packed16 = 16'h0000;
        packed16[0] = 1;
        if (packed16 == 16'h0001) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", packed16); fail_count++; end

        $display("Test 7: Clear all");
        packed16 = 16'hFFFF;
        packed16 = 0;
        if (packed16 == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", packed16); fail_count++; end

        $display("Test 8: Nibble");
        packed16 = 16'h0000;
        packed16[3:0] = 4'hF;
        if (packed16 == 16'h000F) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", packed16); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
