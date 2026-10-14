/*
:name: test_bit_reverse
:description: Bit Reversal Operations Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 11.4.12 13.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_reverse.expected
*/
// IEEE 1800-2023 Section 11.4 - Bit Reversal Operations Tests
module test_bit_reverse;
    int pass_count = 0;
    int fail_count = 0;

    function automatic logic [7:0] reverse8(logic [7:0] val);
        logic [7:0] result;
        int i;
        for (i = 0; i < 8; i++)
            result[i] = val[7-i];
        return result;
    endfunction

    function automatic logic [3:0] reverse4(logic [3:0] val);
        return {val[0], val[1], val[2], val[3]};
    endfunction

    initial begin
        logic [7:0] val8, res8;
        logic [3:0] val4, res4;

        $display("=== IEEE 1800-2023 Bit Reversal Tests ===");

        $display("Test 1: Reverse 8'b10000001");
        val8 = 8'b10000001;
        res8 = reverse8(val8);
        if (res8 == 8'b10000001) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %b", res8); fail_count++; end

        $display("Test 2: Reverse 8'b11110000");
        val8 = 8'b11110000;
        res8 = reverse8(val8);
        if (res8 == 8'b00001111) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %b", res8); fail_count++; end

        $display("Test 3: Reverse 8'b10101010");
        val8 = 8'b10101010;
        res8 = reverse8(val8);
        if (res8 == 8'b01010101) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %b", res8); fail_count++; end

        $display("Test 4: Reverse 4'b1100");
        val4 = 4'b1100;
        res4 = reverse4(val4);
        if (res4 == 4'b0011) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %b", res4); fail_count++; end

        $display("Test 5: Reverse 4'b1001");
        val4 = 4'b1001;
        res4 = reverse4(val4);
        if (res4 == 4'b1001) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %b", res4); fail_count++; end

        $display("Test 6: Double reverse");
        val8 = 8'hAB;
        res8 = reverse8(reverse8(val8));
        if (res8 == 8'hAB) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", res8); fail_count++; end

        $display("Test 7: All zeros");
        val8 = 8'b00000000;
        res8 = reverse8(val8);
        if (res8 == 8'b00000000) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %b", res8); fail_count++; end

        $display("Test 8: All ones");
        val8 = 8'b11111111;
        res8 = reverse8(val8);
        if (res8 == 8'b11111111) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %b", res8); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
