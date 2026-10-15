/*
:name: test_operator_repl
:description: Replication operator test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_repl.expected
*/
// Replication operator test
module test_operator_repl;
    logic [3:0] nibble;
    logic [7:0] byte_val;
    logic [15:0] word_val;
    logic [31:0] dword_val;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic replication
        nibble = 4'hA;
        byte_val = {2{nibble}};
        if (byte_val == 8'hAA) begin
            $display("PASS: {2{4'hA}} = 8'hAA");
            pass_count++;
        end else begin
            $display("FAIL: {2{4'hA}}, expected 0xAA, got 0x%02X", byte_val);
            fail_count++;
        end

        // Test 2: Higher replication count
        word_val = {4{4'hF}};
        if (word_val == 16'hFFFF) begin
            $display("PASS: {4{4'hF}} = 16'hFFFF");
            pass_count++;
        end else begin
            $display("FAIL: {4{4'hF}}, expected 0xFFFF, got 0x%04X", word_val);
            fail_count++;
        end

        // Test 3: Single bit replication
        dword_val = {32{1'b1}};
        if (dword_val == 32'hFFFFFFFF) begin
            $display("PASS: {32{1'b1}} = 32'hFFFFFFFF");
            pass_count++;
        end else begin
            $display("FAIL: {32{1'b1}}, expected 0xFFFFFFFF, got 0x%08X", dword_val);
            fail_count++;
        end

        // Test 4: Replication with concatenation
        word_val = {2{{4'hC, 4'hD}}};
        if (word_val == 16'hCDCD) begin
            $display("PASS: {2{{4'hC, 4'hD}}} = 16'hCDCD");
            pass_count++;
        end else begin
            $display("FAIL: Replication with concat, expected 0xCDCD, got 0x%04X", word_val);
            fail_count++;
        end

        // Test 5: Sign extension using replication
        nibble = 4'b1010;  // Negative in 4-bit signed
        byte_val = {{4{nibble[3]}}, nibble};
        if (byte_val == 8'hFA) begin
            $display("PASS: Sign extension of 4'b1010 = 8'hFA");
            pass_count++;
        end else begin
            $display("FAIL: Sign extension, expected 0xFA, got 0x%02X", byte_val);
            fail_count++;
        end

        // Summary
        $display("Replication operators: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All replication operator tests passed");
        else $display("FAIL: Some replication operator tests failed");
        $finish;
    end
endmodule
