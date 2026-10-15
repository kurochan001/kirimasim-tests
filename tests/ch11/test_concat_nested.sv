/*
:name: test_concat_nested
:description: Nested concatenation
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_nested.expected
*/
// Nested concatenation
module test_concat_nested;
    logic [3:0] a, b, c, d;
    logic [7:0] ab, cd;
    logic [15:0] abcd;
    logic [31:0] result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        a = 4'h1;
        b = 4'h2;
        c = 4'h3;
        d = 4'h4;

        // Test 1: Two-level nesting
        ab = {a, b};
        cd = {c, d};
        abcd = {ab, cd};
        if (abcd == 16'h1234) begin
            $display("PASS: Test 1 - Two-level nested concat");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Expected 0x1234, got 0x%h", abcd);
            fail_count++;
        end

        // Test 2: Direct nested concat expression
        abcd = {{a, b}, {c, d}};
        if (abcd == 16'h1234) begin
            $display("PASS: Test 2 - Direct nested concat");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 0x1234, got 0x%h", abcd);
            fail_count++;
        end

        // Test 3: Three-level nesting
        result = {{{a, b}, {c, d}}, {{4'h5, 4'h6}, {4'h7, 4'h8}}};
        if (result == 32'h12345678) begin
            $display("PASS: Test 3 - Three-level nested concat");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 0x12345678, got 0x%h", result);
            fail_count++;
        end

        // Test 4: Mixed nesting with replication
        abcd = {{2{a}}, {2{b}}};
        if (abcd == 16'h1122) begin
            $display("PASS: Test 4 - Nested with replication");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Expected 0x1122, got 0x%h", abcd);
            fail_count++;
        end

        // Test 5: Complex nested expression
        result = {{4{4'hF}}, {{a, b}, {c, d}}};
        if (result == 32'hFFFF1234) begin
            $display("PASS: Test 5 - Complex nested expression");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 0xFFFF1234, got 0x%h", result);
            fail_count++;
        end

        // Summary
        $display("Concat Nested: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
