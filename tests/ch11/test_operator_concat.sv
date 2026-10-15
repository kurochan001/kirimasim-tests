/*
:name: test_operator_concat
:description: Concatenation operator test
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_concat.expected
*/
// Concatenation operator test
module test_operator_concat;
    logic [3:0] nibble1, nibble2;
    logic [7:0] byte_val;
    logic [15:0] word_val;
    logic [31:0] dword_val;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic two-element concatenation
        nibble1 = 4'hA;
        nibble2 = 4'hB;
        byte_val = {nibble1, nibble2};
        if (byte_val == 8'hAB) begin
            $display("PASS: {4'hA, 4'hB} = 8'hAB");
            pass_count++;
        end else begin
            $display("FAIL: {4'hA, 4'hB}, expected 0xAB, got 0x%02X", byte_val);
            fail_count++;
        end

        // Test 2: Multi-element concatenation
        word_val = {4'h1, 4'h2, 4'h3, 4'h4};
        if (word_val == 16'h1234) begin
            $display("PASS: {4'h1, 4'h2, 4'h3, 4'h4} = 16'h1234");
            pass_count++;
        end else begin
            $display("FAIL: Multi-element concat, expected 0x1234, got 0x%04X", word_val);
            fail_count++;
        end

        // Test 3: Mixed width concatenation
        dword_val = {16'hCAFE, 8'hBA, 8'hBE};
        if (dword_val == 32'hCAFEBABE) begin
            $display("PASS: {16'hCAFE, 8'hBA, 8'hBE} = 32'hCAFEBABE");
            pass_count++;
        end else begin
            $display("FAIL: Mixed width concat, expected 0xCAFEBABE, got 0x%08X", dword_val);
            fail_count++;
        end

        // Test 4: Concatenation with expressions
        nibble1 = 4'h5;
        byte_val = {nibble1 + 4'h1, nibble1 - 4'h1};
        if (byte_val == 8'h64) begin
            $display("PASS: {5+1, 5-1} = 8'h64");
            pass_count++;
        end else begin
            $display("FAIL: Concat with expressions, expected 0x64, got 0x%02X", byte_val);
            fail_count++;
        end

        // Test 5: Nested concatenation
        word_val = {{2{4'hF}}, {2{4'h0}}};
        if (word_val == 16'hFF00) begin
            $display("PASS: Nested concat = 16'hFF00");
            pass_count++;
        end else begin
            $display("FAIL: Nested concat, expected 0xFF00, got 0x%04X", word_val);
            fail_count++;
        end

        // Summary
        $display("Concatenation operators: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All concatenation operator tests passed");
        else $display("FAIL: Some concatenation operator tests failed");
        $finish;
    end
endmodule
