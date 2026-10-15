/*
:name: test_zero_extend_edge_cases
:description: Unsigned values zero-extended when assigned to wider variables
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_zero_extend_edge_cases.expected
*/
// Unsigned values zero-extended when assigned to wider variables
// IEEE 1800-2023 Section 10.7 Assignment extension and truncation
// Tests corner cases: unsigned extension operations

`timescale 1ns/1ps

module test_zero_extend_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        logic [7:0] u8;
        logic [15:0] u16;
        logic [31:0] u32;

        $display("TEST: Zero extension edge cases");

        // Test 1: Basic zero extension
        begin
            u8 = 8'h42;
            u16 = u8;
            if (u16 == 16'h0042) begin
                $display("  [PASS] Basic zero extension");
                passed++;
            end else begin
                $display("  [FAIL] Basic: %0h", u16);
                failed++;
            end
        end

        // Test 2: High bit set
        begin
            u8 = 8'hFF;
            u16 = u8;
            if (u16 == 16'h00FF) begin
                $display("  [PASS] High bit set");
                passed++;
            end else begin
                $display("  [FAIL] HighBit: %0h", u16);
                failed++;
            end
        end

        // Test 3: Zero value
        begin
            u8 = 8'h00;
            u16 = u8;
            if (u16 == 16'h0000) begin
                $display("  [PASS] Zero value");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0h", u16);
                failed++;
            end
        end

        // Test 4: Max value
        begin
            u8 = 8'hFF;
            u32 = u8;
            if (u32 == 32'h000000FF) begin
                $display("  [PASS] Max value");
                passed++;
            end else begin
                $display("  [FAIL] Max: %0h", u32);
                failed++;
            end
        end

        // Test 5: Alternating pattern
        begin
            u8 = 8'hAA;
            u16 = u8;
            if (u16 == 16'h00AA) begin
                $display("  [PASS] Alternating pattern");
                passed++;
            end else begin
                $display("  [FAIL] Alt: %0h", u16);
                failed++;
            end
        end

        // Test 6: MSB clear
        begin
            u8 = 8'h80;
            u16 = u8;
            if (u16[15:8] == 8'h00) begin
                $display("  [PASS] MSB clear");
                passed++;
            end else begin
                $display("  [FAIL] MSB: %0h", u16[15:8]);
                failed++;
            end
        end

        // Test 7: Chain extension
        begin
            u8 = 8'hAB;
            u16 = u8;
            u32 = u16;
            if (u32 == 32'h000000AB) begin
                $display("  [PASS] Chain extension");
                passed++;
            end else begin
                $display("  [FAIL] Chain: %0h", u32);
                failed++;
            end
        end

        // Test 8: Pattern preserve
        begin
            u8 = 8'h55;
            u16 = u8;
            if (u16[7:0] == 8'h55) begin
                $display("  [PASS] Pattern preserve");
                passed++;
            end else begin
                $display("  [FAIL] Pattern: %0h", u16[7:0]);
                failed++;
            end
        end

        // Test 9: 16 to 32
        begin
            u16 = 16'hABCD;
            u32 = u16;
            if (u32 == 32'h0000ABCD) begin
                $display("  [PASS] 16 to 32");
                passed++;
            end else begin
                $display("  [FAIL] 16to32: %0h", u32);
                failed++;
            end
        end

        // Test 10: Single bit
        begin
            logic b;
            b = 1'b1;
            u8 = b;
            if (u8 == 8'h01) begin
                $display("  [PASS] Single bit");
                passed++;
            end else begin
                $display("  [FAIL] Bit: %0h", u8);
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
