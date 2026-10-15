/*
:name: test_concat_simple
:description: Simple concatenation
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_simple.expected
*/
// Simple concatenation
module test_concat_simple;
    logic [7:0] a, b;
    logic [15:0] ab;
    logic [31:0] result;
    logic [3:0] nibbles [4];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Two byte concatenation
        a = 8'hCA;
        b = 8'hFE;
        ab = {a, b};
        if (ab == 16'hCAFE) begin
            $display("PASS: Test 1 - Two byte concat");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0xCAFE, got 0x%h", ab);
            fail_count++;
        end

        // Test 2: Four byte concatenation
        result = {8'hDE, 8'hAD, 8'hBE, 8'hEF};
        if (result == 32'hDEADBEEF) begin
            $display("PASS: Test 2 - Four byte concat");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 0xDEADBEEF, got 0x%h", result);
            fail_count++;
        end

        // Test 3: Concatenation with literals
        ab = {4'hA, 4'hB, 4'hC, 4'hD};
        if (ab == 16'hABCD) begin
            $display("PASS: Test 3 - Nibble concat");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 0xABCD, got 0x%h", ab);
            fail_count++;
        end

        // Test 4: Mixed size concatenation
        result = {16'hFACE, a, b};
        if (result == 32'hFACECAFE) begin
            $display("PASS: Test 4 - Mixed size concat");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected 0xFACECAFE, got 0x%h", result);
            fail_count++;
        end

        // Test 5: Single bit concatenation
        ab = {1'b1, 15'h7FFF};
        if (ab == 16'hFFFF) begin
            $display("PASS: Test 5 - Single bit concat");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 0xFFFF, got 0x%h", ab);
            fail_count++;
        end

        // Summary
        $display("Concat Simple: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
