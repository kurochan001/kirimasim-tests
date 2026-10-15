/*
:name: test_reduce_ops_edge_cases
:description: Reduction AND, OR, XOR, NAND, NOR and XNOR on 8-bit and 4-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.9
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reduce_ops_edge_cases.expected
*/
// Reduction AND, OR, XOR, NAND, NOR and XNOR on 8-bit and 4-bit values
// IEEE 1800-2023 Section 11.4.9 Reduction operators
// Tests corner cases: unary reduction operations

`timescale 1ns/1ps

module test_reduce_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        logic [7:0] byte_val;
        logic [3:0] nibble;
        logic result;

        $display("TEST: Reduction operators edge cases");

        // Test 1: Reduce AND all ones
        begin
            byte_val = 8'hFF;
            result = &byte_val;
            if (result == 1) begin
                $display("  [PASS] Reduce AND all ones");
                passed++;
            end else begin
                $display("  [FAIL] AndOnes: %0b", result);
                failed++;
            end
        end

        // Test 2: Reduce AND with zero
        begin
            byte_val = 8'hFE;
            result = &byte_val;
            if (result == 0) begin
                $display("  [PASS] Reduce AND with zero");
                passed++;
            end else begin
                $display("  [FAIL] AndZero: %0b", result);
                failed++;
            end
        end

        // Test 3: Reduce OR all zeros
        begin
            byte_val = 8'h00;
            result = |byte_val;
            if (result == 0) begin
                $display("  [PASS] Reduce OR all zeros");
                passed++;
            end else begin
                $display("  [FAIL] OrZeros: %0b", result);
                failed++;
            end
        end

        // Test 4: Reduce OR with one
        begin
            byte_val = 8'h01;
            result = |byte_val;
            if (result == 1) begin
                $display("  [PASS] Reduce OR with one");
                passed++;
            end else begin
                $display("  [FAIL] OrOne: %0b", result);
                failed++;
            end
        end

        // Test 5: Reduce XOR even ones
        begin
            byte_val = 8'h55;  // 01010101 - 4 ones
            result = ^byte_val;
            if (result == 0) begin
                $display("  [PASS] Reduce XOR even ones");
                passed++;
            end else begin
                $display("  [FAIL] XorEven: %0b", result);
                failed++;
            end
        end

        // Test 6: Reduce XOR odd ones
        begin
            byte_val = 8'h57;  // 01010111 - 5 ones
            result = ^byte_val;
            if (result == 1) begin
                $display("  [PASS] Reduce XOR odd ones");
                passed++;
            end else begin
                $display("  [FAIL] XorOdd: %0b", result);
                failed++;
            end
        end

        // Test 7: Reduce NAND all ones
        begin
            byte_val = 8'hFF;
            result = ~&byte_val;
            if (result == 0) begin
                $display("  [PASS] Reduce NAND all ones");
                passed++;
            end else begin
                $display("  [FAIL] NandOnes: %0b", result);
                failed++;
            end
        end

        // Test 8: Reduce NOR all zeros
        begin
            byte_val = 8'h00;
            result = ~|byte_val;
            if (result == 1) begin
                $display("  [PASS] Reduce NOR all zeros");
                passed++;
            end else begin
                $display("  [FAIL] NorZeros: %0b", result);
                failed++;
            end
        end

        // Test 9: Reduce XNOR even ones
        begin
            nibble = 4'b1100;  // 2 ones (even)
            result = ~^nibble;
            if (result == 1) begin
                $display("  [PASS] Reduce XNOR even ones");
                passed++;
            end else begin
                $display("  [FAIL] XnorEven: %0b", result);
                failed++;
            end
        end

        // Test 10: Reduce on nibble
        begin
            nibble = 4'hF;
            result = &nibble;
            if (result == 1) begin
                $display("  [PASS] Reduce on nibble");
                passed++;
            end else begin
                $display("  [FAIL] Nibble: %0b", result);
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
