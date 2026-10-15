/*
:name: test_bit_manip
:description: Bit Manipulation Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 11.4.8 11.4.12 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_manip.expected
*/
// IEEE 1800-2023 Section 11 - Bit Manipulation Tests
module test_bit_manip;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] a, b, result;

        $display("=== IEEE 1800-2023 Bit Manipulation Tests ===");

        // Test 1: Set bit
        $display("Test 1: Set bit");
        a = 8'h00;
        a[3] = 1'b1;
        if (a == 8'h08) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", a); fail_count++; end

        // Test 2: Clear bit
        $display("Test 2: Clear bit");
        a = 8'hFF;
        a[4] = 1'b0;
        if (a == 8'hEF) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", a); fail_count++; end

        // Test 3: Toggle bit
        $display("Test 3: Toggle");
        a = 8'hF0;
        a = a ^ 8'h01;
        if (a == 8'hF1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", a); fail_count++; end

        // Test 4: Mask low
        $display("Test 4: Mask low");
        a = 8'hAB;
        result = a & 8'h0F;
        if (result == 8'h0B) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", result); fail_count++; end

        // Test 5: Mask high
        $display("Test 5: Mask high");
        a = 8'hAB;
        result = a & 8'hF0;
        if (result == 8'hA0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", result); fail_count++; end

        // Test 6: Set range
        $display("Test 6: Set range");
        a = 8'h00;
        a[7:4] = 4'hF;
        if (a == 8'hF0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", a); fail_count++; end

        // Test 7: Swap nibbles
        $display("Test 7: Swap nibbles");
        a = 8'hAB;
        result = {a[3:0], a[7:4]};
        if (result == 8'hBA) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", result); fail_count++; end

        // Test 8: Count bits
        $display("Test 8: Count bits");
        a = 8'b10101010;
        if ($countones(a) == 4) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", $countones(a)); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
