/*
:name: test_repl_expr
:description: Replication Expression Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_repl_expr.expected
*/
// IEEE 1800-2023 Section 11.4.12 - Replication Expression Tests
module test_repl_expr;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] byte_val;
        logic [15:0] word_val;
        logic [31:0] dword_val;
        logic bit_val;

        $display("=== IEEE 1800-2023 Replication Expression Tests ===");

        // Test 1: Replicate byte
        $display("Test 1: Replicate byte");
        byte_val = 8'hAB;
        word_val = {2{byte_val}};
        if (word_val == 16'hABAB) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", word_val); fail_count++; end

        // Test 2: Replicate 4x
        $display("Test 2: Replicate 4x");
        byte_val = 8'h12;
        dword_val = {4{byte_val}};
        if (dword_val == 32'h12121212) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", dword_val); fail_count++; end

        // Test 3: Replicate bit
        $display("Test 3: Replicate bit");
        bit_val = 1'b1;
        byte_val = {8{bit_val}};
        if (byte_val == 8'hFF) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", byte_val); fail_count++; end

        // Test 4: Replicate zero
        $display("Test 4: Replicate zero");
        bit_val = 1'b0;
        byte_val = {8{bit_val}};
        if (byte_val == 8'h00) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", byte_val); fail_count++; end

        // Test 5: Replicate word 2x
        $display("Test 5: Word 2x");
        word_val = 16'hABCD;
        dword_val = {2{word_val}};
        if (dword_val == 32'hABCDABCD) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", dword_val); fail_count++; end

        // Test 6: Replicate 8x
        $display("Test 6: 8x repl");
        bit_val = 1'b1;
        word_val = {16{bit_val}};
        if (word_val == 16'hFFFF) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", word_val); fail_count++; end

        // Test 7: Concat two vars
        $display("Test 7: Two vars");
        byte_val = 8'hFF;
        word_val = {byte_val, byte_val};
        if (word_val == 16'hFFFF) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", word_val); fail_count++; end

        // Test 8: Quad repl
        $display("Test 8: Quad repl");
        byte_val = 8'hAA;
        dword_val = {4{byte_val}};
        if (dword_val == 32'hAAAAAAAA) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", dword_val); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
