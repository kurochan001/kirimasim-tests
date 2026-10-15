/*
:name: test_concat_repl_3
:description: Replication concatenation
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_concat_repl_3.expected
*/
// Replication concatenation
module test_concat_repl;
    logic [7:0] byte_val;
    logic [15:0] half;
    logic [31:0] word;
    logic [63:0] dword;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Simple 2x replication
        byte_val = 8'hAB;
        half = {2{byte_val}};
        if (half == 16'hABAB) begin
            $display("PASS: Test 1 - 2x replication");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0xABAB, got 0x%h", half);
            fail_count++;
        end

        // Test 2: 4x replication
        byte_val = 8'hFF;
        word = {4{byte_val}};
        if (word == 32'hFFFFFFFF) begin
            $display("PASS: Test 2 - 4x replication");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 0xFFFFFFFF, got 0x%h", word);
            fail_count++;
        end

        // Test 3: Single bit replication
        word = {32{1'b1}};
        if (word == 32'hFFFFFFFF) begin
            $display("PASS: Test 3 - 32x single bit replication");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 0xFFFFFFFF, got 0x%h", word);
            fail_count++;
        end

        // Test 4: Nibble replication
        half = {4{4'hA}};
        if (half == 16'hAAAA) begin
            $display("PASS: Test 4 - 4x nibble replication");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected 0xAAAA, got 0x%h", half);
            fail_count++;
        end

        // Test 5: Nested replication with concat
        word = {2{{2{8'hCD}}}};
        if (word == 32'hCDCDCDCD) begin
            $display("PASS: Test 5 - Nested replication");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 0xCDCDCDCD, got 0x%h", word);
            fail_count++;
        end

        // Summary
        $display("Concat Repl: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
