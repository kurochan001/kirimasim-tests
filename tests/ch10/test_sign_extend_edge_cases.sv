/*
:name: test_sign_extend_edge_cases
:description: Signed values sign-extended when assigned to wider signed variables
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.7 11.8.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sign_extend_edge_cases.expected
*/
// Signed values sign-extended when assigned to wider signed variables
// IEEE 1800-2023 Sections 10.7 and 11.8.2: extension of signed values
// Tests corner cases: signed extension operations

`timescale 1ns/1ps

module test_sign_extend_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        logic signed [7:0] s8;
        logic signed [15:0] s16;
        logic signed [31:0] s32;
        int i;

        $display("TEST: Sign extension edge cases");

        // Test 1: Positive sign extension
        begin
            s8 = 8'sd42;
            s16 = s8;
            if (s16 == 16'sd42) begin
                $display("  [PASS] Positive sign extension");
                passed++;
            end else begin
                $display("  [FAIL] PosExt: %0d", s16);
                failed++;
            end
        end

        // Test 2: Negative sign extension
        begin
            s8 = -8'sd10;
            s16 = s8;
            if (s16 == -16'sd10) begin
                $display("  [PASS] Negative sign extension");
                passed++;
            end else begin
                $display("  [FAIL] NegExt: %0d", s16);
                failed++;
            end
        end

        // Test 3: Max positive extension
        begin
            s8 = 8'sd127;
            s32 = s8;
            if (s32 == 32'sd127) begin
                $display("  [PASS] Max positive extension");
                passed++;
            end else begin
                $display("  [FAIL] MaxPos: %0d", s32);
                failed++;
            end
        end

        // Test 4: Min negative extension
        begin
            s8 = -8'sd128;
            s32 = s8;
            if (s32 == -32'sd128) begin
                $display("  [PASS] Min negative extension");
                passed++;
            end else begin
                $display("  [FAIL] MinNeg: %0d", s32);
                failed++;
            end
        end

        // Test 5: Zero sign extension
        begin
            s8 = 8'sd0;
            s16 = s8;
            if (s16 == 16'sd0) begin
                $display("  [PASS] Zero sign extension");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", s16);
                failed++;
            end
        end

        // Test 6: -1 sign extension
        begin
            s8 = -8'sd1;
            s32 = s8;
            if (s32 == -32'sd1) begin
                $display("  [PASS] -1 sign extension");
                passed++;
            end else begin
                $display("  [FAIL] MinusOne: %0d", s32);
                failed++;
            end
        end

        // Test 7: Bit pattern preserved
        begin
            s8 = 8'sb10000001;  // -127
            s16 = s8;
            if (s16[7:0] == s8) begin
                $display("  [PASS] Bit pattern preserved");
                passed++;
            end else begin
                $display("  [FAIL] Pattern");
                failed++;
            end
        end

        // Test 8: High bits extended
        begin
            s8 = -8'sd50;
            s16 = s8;
            if (s16[15:8] == 8'hFF) begin
                $display("  [PASS] High bits extended");
                passed++;
            end else begin
                $display("  [FAIL] HighBits: %0h", s16[15:8]);
                failed++;
            end
        end

        // Test 9: Positive high bits clear
        begin
            s8 = 8'sd50;
            s16 = s8;
            if (s16[15:8] == 8'h00) begin
                $display("  [PASS] Positive high bits clear");
                passed++;
            end else begin
                $display("  [FAIL] PosHigh: %0h", s16[15:8]);
                failed++;
            end
        end

        // Test 10: Chain extension
        begin
            s8 = -8'sd5;
            s16 = s8;
            s32 = s16;
            if (s32 == -32'sd5) begin
                $display("  [PASS] Chain extension");
                passed++;
            end else begin
                $display("  [FAIL] Chain: %0d", s32);
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
