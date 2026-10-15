/*
:name: test_concat_expr
:description: Concatenation Expression Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_expr.expected
*/
// IEEE 1800-2023 Section 11.4.12 - Concatenation Expression Tests
module test_concat_expr;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] a, b;
        logic [15:0] result16;
        logic [31:0] result32;
        logic [3:0] n;

        $display("=== IEEE 1800-2023 Concatenation Expression Tests ===");

        // Test 1: Two bytes
        $display("Test 1: Two bytes");
        a = 8'hAB;
        b = 8'hCD;
        result16 = {a, b};
        if (result16 == 16'hABCD) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %h", result16); fail_count++; end

        // Test 2: Four bytes
        $display("Test 2: Four bytes");
        result32 = {a, b, a, b};
        if (result32 == 32'hABCDABCD) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %h", result32); fail_count++; end

        // Test 3: Mixed sizes
        $display("Test 3: Mixed sizes");
        n = 4'hF;
        result16 = {n, a, n};
        if (result16 == 16'hFABF) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %h", result16); fail_count++; end

        // Test 4: Zeros
        $display("Test 4: Zeros");
        a = 8'h00;
        b = 8'h00;
        result16 = {a, b};
        if (result16 == 16'h0000) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %h", result16); fail_count++; end

        // Test 5: All ones
        $display("Test 5: All ones");
        a = 8'hFF;
        b = 8'hFF;
        result16 = {a, b};
        if (result16 == 16'hFFFF) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %h", result16); fail_count++; end

        // Test 6: High byte
        $display("Test 6: High byte");
        a = 8'hA0;
        b = 8'h00;
        result16 = {a, b};
        if (result16 == 16'hA000) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %h", result16); fail_count++; end

        // Test 7: Extract and concat
        $display("Test 7: Extract concat");
        a = 8'h12;
        b = 8'h34;
        result16 = {a[3:0], b[7:4], a[7:4], b[3:0]};
        if (result16 == 16'h2314) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %h", result16); fail_count++; end

        // Test 8: Nested
        $display("Test 8: Nested");
        a = 8'hAA;
        b = 8'h55;
        result32 = {{a, b}, {b, a}};
        if (result32 == 32'hAA5555AA) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %h", result32); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
