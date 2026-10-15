/*
:name: test_bitwise_ops_edge_cases
:description: Test: Bitwise operations edge cases
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitwise_ops_edge_cases.expected
*/
// Test: Bitwise operations edge cases
// IEEE 1800-2023 Section 11.4.8 Bitwise operators
// Tests corner cases: bitwise operations

`timescale 1ns/1ps

module test_bitwise_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] a, b, result;

    initial begin
        $display("TEST: Bitwise operations edge cases");

        // Test 1: Bitwise AND
        begin
            a = 8'hF0;
            b = 8'hFF;
            result = a & b;
            if (result == 8'hF0) begin
                $display("  [PASS] Bitwise AND");
                passed++;
            end else begin
                $display("  [FAIL] AND: %h", result);
                failed++;
            end
        end

        // Test 2: Bitwise OR
        begin
            a = 8'hF0;
            b = 8'h0F;
            result = a | b;
            if (result == 8'hFF) begin
                $display("  [PASS] Bitwise OR");
                passed++;
            end else begin
                $display("  [FAIL] OR: %h", result);
                failed++;
            end
        end

        // Test 3: Bitwise XOR
        begin
            a = 8'hFF;
            b = 8'hAA;
            result = a ^ b;
            if (result == 8'h55) begin
                $display("  [PASS] Bitwise XOR");
                passed++;
            end else begin
                $display("  [FAIL] XOR: %h", result);
                failed++;
            end
        end

        // Test 4: Bitwise NOT
        begin
            a = 8'h55;
            result = ~a;
            if (result == 8'hAA) begin
                $display("  [PASS] Bitwise NOT");
                passed++;
            end else begin
                $display("  [FAIL] NOT: %h", result);
                failed++;
            end
        end

        // Test 5: Bitwise NAND
        begin
            a = 8'hFF;
            b = 8'hF0;
            result = ~(a & b);
            if (result == 8'h0F) begin
                $display("  [PASS] Bitwise NAND");
                passed++;
            end else begin
                $display("  [FAIL] NAND: %h", result);
                failed++;
            end
        end

        // Test 6: Bitwise NOR
        begin
            a = 8'hF0;
            b = 8'h0F;
            result = ~(a | b);
            if (result == 8'h00) begin
                $display("  [PASS] Bitwise NOR");
                passed++;
            end else begin
                $display("  [FAIL] NOR: %h", result);
                failed++;
            end
        end

        // Test 7: Bitwise XNOR
        begin
            a = 8'hAA;
            b = 8'hAA;
            result = ~(a ^ b);
            if (result == 8'hFF) begin
                $display("  [PASS] Bitwise XNOR");
                passed++;
            end else begin
                $display("  [FAIL] XNOR: %h", result);
                failed++;
            end
        end

        // Test 8: AND with zero
        begin
            a = 8'hFF;
            b = 8'h00;
            result = a & b;
            if (result == 8'h00) begin
                $display("  [PASS] AND with zero");
                passed++;
            end else begin
                $display("  [FAIL] AND0: %h", result);
                failed++;
            end
        end

        // Test 9: OR with zero
        begin
            a = 8'h55;
            b = 8'h00;
            result = a | b;
            if (result == 8'h55) begin
                $display("  [PASS] OR with zero");
                passed++;
            end else begin
                $display("  [FAIL] OR0: %h", result);
                failed++;
            end
        end

        // Test 10: XOR self cancellation
        begin
            a = 8'hAB;
            result = a ^ a;
            if (result == 8'h00) begin
                $display("  [PASS] XOR self cancellation");
                passed++;
            end else begin
                $display("  [FAIL] XOR self: %h", result);
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
