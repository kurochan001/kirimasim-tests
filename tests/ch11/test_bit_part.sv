/*
:name: test_bit_part
:description: Bit Part Select Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bit_part.expected
*/
// IEEE 1800-2023 Section 11.5 - Bit Part Select Tests
module test_bit_part;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [15:0] wide;
        logic [7:0] byte_val;
        logic [3:0] nibble;
        int idx;

        $display("=== IEEE 1800-2023 Bit Part Select Tests ===");

        $display("Test 1: Upper byte");
        wide = 16'hABCD;
        byte_val = wide[15:8];
        if (byte_val == 8'hAB) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", byte_val); fail_count++; end

        $display("Test 2: Lower byte");
        byte_val = wide[7:0];
        if (byte_val == 8'hCD) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", byte_val); fail_count++; end

        $display("Test 3: Single bit");
        if (wide[0] == 1'b1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %b", wide[0]); fail_count++; end

        $display("Test 4: MSB");
        if (wide[15] == 1'b1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %b", wide[15]); fail_count++; end

        $display("Test 5: Nibble select");
        nibble = wide[7:4];
        if (nibble == 4'hC) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", nibble); fail_count++; end

        $display("Test 6: Variable index");
        idx = 8;
        byte_val = wide[idx +: 8];
        if (byte_val == 8'hAB) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", byte_val); fail_count++; end

        $display("Test 7: Modify part");
        wide = 16'h0000;
        wide[7:0] = 8'hFF;
        if (wide == 16'h00FF) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", wide); fail_count++; end

        $display("Test 8: Modify bit");
        wide = 16'h0000;
        wide[15] = 1'b1;
        if (wide == 16'h8000) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", wide); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
