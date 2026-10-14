/*
:name: test_concat_advanced
:description: Advanced Concatenation Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_advanced.expected
*/
// IEEE 1800-2023 Section 11.4.12 - Advanced Concatenation Tests
// Tests: Nested concat, replication, mixed widths

module test_concat_advanced;
    int pass_count = 0;
    int fail_count = 0;

    logic [3:0] a;
    logic [3:0] b;
    logic [3:0] c;
    logic [3:0] d;
    logic [7:0] byte_val;
    logic [15:0] word_val;
    logic [31:0] dword_val;
    logic [23:0] result24;

    initial begin
        $display("=== IEEE 1800-2023 Advanced Concatenation Tests ===");

        // Test 1: Simple concatenation
        $display("Test 1: Simple concatenation");
        a = 4'hA;
        b = 4'hB;
        byte_val = {a, b};
        if (byte_val == 8'hAB) begin
            $display("Test 1 PASS: {A,B}=%h", byte_val);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %h", byte_val);
            fail_count++;
        end

        // Test 2: Multiple concatenation
        $display("Test 2: Multiple concatenation");
        a = 4'h1;
        b = 4'h2;
        c = 4'h3;
        d = 4'h4;
        word_val = {a, b, c, d};
        if (word_val == 16'h1234) begin
            $display("Test 2 PASS: {1,2,3,4}=%h", word_val);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %h", word_val);
            fail_count++;
        end

        // Test 3: Replication
        $display("Test 3: Replication");
        a = 4'hF;
        word_val = {4{a}};
        if (word_val == 16'hFFFF) begin
            $display("Test 3 PASS: {4{F}}=%h", word_val);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %h", word_val);
            fail_count++;
        end

        // Test 4: Nested replication
        $display("Test 4: Nested replication");
        a = 4'hA;
        b = 4'hB;
        dword_val = {2{{a, b}}};
        if (dword_val == 32'h0000ABAB) begin
            $display("Test 4 PASS: {2{{A,B}}}=%h", dword_val);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %h", dword_val);
            fail_count++;
        end

        // Test 5: Concatenation in expression
        $display("Test 5: Concatenation in expression");
        a = 4'h5;
        b = 4'h3;
        if ({a, b} == 8'h53) begin
            $display("Test 5 PASS: {5,3}==0x53 is true");
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: Another concatenation test
        $display("Test 6: Larger concatenation");
        dword_val = {byte_val, 8'h12, 8'h34, 8'h56};
        if (dword_val[7:0] == 8'h56) begin
            $display("Test 6 PASS: lower byte=%h", dword_val[7:0]);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %h", dword_val[7:0]);
            fail_count++;
        end

        // Test 7: Bit concatenation
        $display("Test 7: Bit concatenation");
        a = 4'b1010;
        b = 4'b0101;
        byte_val = {a, b};
        if (byte_val == 8'b10100101) begin
            $display("Test 7 PASS: {1010,0101}=%b", byte_val);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %b", byte_val);
            fail_count++;
        end

        // Test 8: Concatenation with zeros
        $display("Test 8: Concatenation with zeros");
        byte_val = {4'b0000, 4'b1111};
        if (byte_val == 8'h0F) begin
            $display("Test 8 PASS: {0,F}=%h", byte_val);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %h", byte_val);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
