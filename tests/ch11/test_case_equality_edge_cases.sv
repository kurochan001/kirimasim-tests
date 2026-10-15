/*
:name: test_case_equality_edge_cases
:description: Case equality === and !== with x and z bits
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_case_equality_edge_cases.expected
*/
// Case equality === and !== with x and z bits
// IEEE 1800-2023 Section 11.4.5 Equality operators
// Tests corner cases: case equality with X/Z values

`timescale 1ns/1ps

module test_case_equality_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] a, b;
    logic result;

    initial begin
        $display("TEST: Case equality edge cases");

        // Test 1: Exact match ===
        begin
            a = 8'hAB;
            b = 8'hAB;
            result = (a === b);
            if (result == 1'b1) begin
                $display("  [PASS] Exact match ===");
                passed++;
            end else begin
                $display("  [FAIL] Exact: %b", result);
                failed++;
            end
        end

        // Test 2: X equals X
        begin
            a = 8'bxxxxxxxx;
            b = 8'bxxxxxxxx;
            result = (a === b);
            if (result == 1'b1) begin
                $display("  [PASS] X equals X");
                passed++;
            end else begin
                $display("  [FAIL] XeqX: %b", result);
                failed++;
            end
        end

        // Test 3: Z equals Z
        begin
            a = 8'bzzzzzzzz;
            b = 8'bzzzzzzzz;
            result = (a === b);
            if (result == 1'b1) begin
                $display("  [PASS] Z equals Z");
                passed++;
            end else begin
                $display("  [FAIL] ZeqZ: %b", result);
                failed++;
            end
        end

        // Test 4: X not equals Z
        begin
            a = 8'bxxxxxxxx;
            b = 8'bzzzzzzzz;
            result = (a !== b);
            if (result == 1'b1) begin
                $display("  [PASS] X not equals Z");
                passed++;
            end else begin
                $display("  [FAIL] XneZ: %b", result);
                failed++;
            end
        end

        // Test 5: Mixed X pattern
        begin
            a = 8'b1010xxxx;
            b = 8'b1010xxxx;
            result = (a === b);
            if (result == 1'b1) begin
                $display("  [PASS] Mixed X pattern");
                passed++;
            end else begin
                $display("  [FAIL] MixedX: %b", result);
                failed++;
            end
        end

        // Test 6: Mixed Z pattern
        begin
            a = 8'b1111zzzz;
            b = 8'b1111zzzz;
            result = (a === b);
            if (result == 1'b1) begin
                $display("  [PASS] Mixed Z pattern");
                passed++;
            end else begin
                $display("  [FAIL] MixedZ: %b", result);
                failed++;
            end
        end

        // Test 7: Not equal values
        begin
            a = 8'hAB;
            b = 8'hCD;
            result = (a !== b);
            if (result == 1'b1) begin
                $display("  [PASS] Not equal values");
                passed++;
            end else begin
                $display("  [FAIL] NotEq: %b", result);
                failed++;
            end
        end

        // Test 8: All zeros match
        begin
            a = 8'h00;
            b = 8'h00;
            result = (a === b);
            if (result == 1'b1) begin
                $display("  [PASS] All zeros match");
                passed++;
            end else begin
                $display("  [FAIL] Zeros: %b", result);
                failed++;
            end
        end

        // Test 9: All ones match
        begin
            a = 8'hFF;
            b = 8'hFF;
            result = (a === b);
            if (result == 1'b1) begin
                $display("  [PASS] All ones match");
                passed++;
            end else begin
                $display("  [FAIL] Ones: %b", result);
                failed++;
            end
        end

        // Test 10: Alternating pattern
        begin
            a = 8'b10101010;
            b = 8'b10101010;
            result = (a === b);
            if (result == 1'b1) begin
                $display("  [PASS] Alternating pattern");
                passed++;
            end else begin
                $display("  [FAIL] Alt: %b", result);
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
