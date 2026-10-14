/*
:name: test_concat_ops_edge_cases
:description: Test: Concatenation operations edge cases
:tags: concat_ops
:type: simulation
:lrm: 1800-2023 11.4.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_concat_ops_edge_cases.expected
*/
// Test: Concatenation operations edge cases
// IEEE 1800-2023 Section 11.4.12 Concatenation operators
// Tests corner cases: concatenation operations

`timescale 1ns/1ps

module test_concat_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [3:0] a, b;
    logic [7:0] result8;
    logic [15:0] result16;

    initial begin
        $display("TEST: Concatenation operations edge cases");

        // Test 1: Basic two-variable concat
        begin
            a = 4'hA;
            b = 4'hB;
            result8 = {a, b};
            if (result8 == 8'hAB) begin
                $display("  [PASS] Basic two-variable concat");
                passed++;
            end else begin
                $display("  [FAIL] Basic: %h", result8);
                failed++;
            end
        end

        // Test 2: Concat with zeros leading (literal + variable)
        begin
            a = 4'hF;
            result8 = {4'b0000, a};
            if (result8 == 8'h0F) begin
                $display("  [PASS] Concat with zeros leading");
                passed++;
            end else begin
                $display("  [FAIL] Zeros: %h", result8);
                failed++;
            end
        end

        // Test 3: Concat bytes to word
        begin
            static logic [7:0] hi = 8'hAB;
            static logic [7:0] lo = 8'hCD;
            result16 = {hi, lo};
            if (result16 == 16'hABCD) begin
                $display("  [PASS] Concat bytes to word");
                passed++;
            end else begin
                $display("  [FAIL] Word: %h", result16);
                failed++;
            end
        end

        // Test 4: Byte swap via concat
        begin
            result16 = 16'hABCD;
            result16 = {result16[7:0], result16[15:8]};
            if (result16 == 16'hCDAB) begin
                $display("  [PASS] Byte swap via concat");
                passed++;
            end else begin
                $display("  [FAIL] Swap: %h", result16);
                failed++;
            end
        end

        // Test 5: Concat all zeros (variables)
        begin
            a = 4'h0;
            b = 4'h0;
            result8 = {a, b};
            if (result8 == 8'h00) begin
                $display("  [PASS] Concat all zeros");
                passed++;
            end else begin
                $display("  [FAIL] Zeros: %h", result8);
                failed++;
            end
        end

        // Test 6: Concat all ones (variables)
        begin
            a = 4'hF;
            b = 4'hF;
            result8 = {a, b};
            if (result8 == 8'hFF) begin
                $display("  [PASS] Concat all ones");
                passed++;
            end else begin
                $display("  [FAIL] Ones: %h", result8);
                failed++;
            end
        end

        // Test 7: Concat alternating pattern
        begin
            a = 4'hA;
            b = 4'h5;
            result8 = {a, b};
            if (result8 == 8'hA5) begin
                $display("  [PASS] Concat alternating pattern");
                passed++;
            end else begin
                $display("  [FAIL] Alt: %h", result8);
                failed++;
            end
        end

        // Test 8: Concat with part select
        begin
            result16 = 16'h1234;
            result8 = {result16[15:12], result16[3:0]};
            if (result8 == 8'h14) begin
                $display("  [PASS] Concat with part select");
                passed++;
            end else begin
                $display("  [FAIL] PartSel: %h", result8);
                failed++;
            end
        end

        // Test 9: Concat nibble reverse
        begin
            result16 = 16'hABCD;
            result16 = {result16[3:0], result16[7:4], result16[11:8], result16[15:12]};
            if (result16 == 16'hDCBA) begin
                $display("  [PASS] Concat nibble reverse");
                passed++;
            end else begin
                $display("  [FAIL] NibRev: %h", result16);
                failed++;
            end
        end

        // Test 10: Concat variable + variable different values
        begin
            a = 4'h5;
            b = 4'hA;
            result8 = {a, b};
            if (result8 == 8'h5A) begin
                $display("  [PASS] Concat different values");
                passed++;
            end else begin
                $display("  [FAIL] Diff: %h", result8);
                failed++;
            end
        end

        // Summary
        $display("");
        $display("Results: %0d passed, %0d failed", passed, failed);
        if (failed == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
    end
endmodule
