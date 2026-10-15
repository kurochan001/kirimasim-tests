/*
:name: test_signed_ops_edge_cases
:description: Arithmetic and comparison of signed 8-bit values
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.4.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_ops_edge_cases.expected
*/
// Arithmetic and comparison of signed 8-bit values
// IEEE 1800-2023 Section 11.4 Signed and Unsigned
// Tests corner cases: signed operations

`timescale 1ns/1ps

module test_signed_ops_edge_cases;
    int passed = 0;
    int failed = 0;

    logic signed [7:0] sa, sb, sc;
    int si;

    initial begin
        $display("TEST: Signed operations edge cases");

        // Test 1: Positive signed
        begin
            sa = 8'sd100;
            if (sa == 100) begin
                $display("  [PASS] Positive signed");
                passed++;
            end else begin
                $display("  [FAIL] Pos: %0d", sa);
                failed++;
            end
        end

        // Test 2: Negative signed
        begin
            sa = -8'sd50;
            if (sa == -50) begin
                $display("  [PASS] Negative signed");
                passed++;
            end else begin
                $display("  [FAIL] Neg: %0d", sa);
                failed++;
            end
        end

        // Test 3: Signed addition
        begin
            sa = 8'sd30;
            sb = 8'sd20;
            sc = sa + sb;
            if (sc == 50) begin
                $display("  [PASS] Signed addition");
                passed++;
            end else begin
                $display("  [FAIL] Add: %0d", sc);
                failed++;
            end
        end

        // Test 4: Signed subtraction
        begin
            sa = 8'sd30;
            sb = 8'sd50;
            sc = sa - sb;
            if (sc == -20) begin
                $display("  [PASS] Signed subtraction");
                passed++;
            end else begin
                $display("  [FAIL] Sub: %0d", sc);
                failed++;
            end
        end

        // Test 5: Signed comparison less
        begin
            sa = -8'sd10;
            sb = 8'sd5;
            if (sa < sb) begin
                $display("  [PASS] Signed comparison less");
                passed++;
            end else begin
                $display("  [FAIL] CmpLess");
                failed++;
            end
        end

        // Test 6: Signed comparison greater
        begin
            sa = 8'sd10;
            sb = -8'sd5;
            if (sa > sb) begin
                $display("  [PASS] Signed comparison greater");
                passed++;
            end else begin
                $display("  [FAIL] CmpGreater");
                failed++;
            end
        end

        // Test 7: Signed zero
        begin
            sa = 0;
            if (sa == 0) begin
                $display("  [PASS] Signed zero");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d", sa);
                failed++;
            end
        end

        // Test 8: Signed max positive
        begin
            sa = 8'sd127;
            if (sa == 127) begin
                $display("  [PASS] Signed max positive");
                passed++;
            end else begin
                $display("  [FAIL] MaxPos: %0d", sa);
                failed++;
            end
        end

        // Test 9: Signed min negative
        begin
            sa = -8'sd128;
            if (sa == -128) begin
                $display("  [PASS] Signed min negative");
                passed++;
            end else begin
                $display("  [FAIL] MinNeg: %0d", sa);
                failed++;
            end
        end

        // Test 10: Signed multiply
        begin
            sa = -8'sd5;
            sb = 8'sd4;
            sc = sa * sb;
            if (sc == -20) begin
                $display("  [PASS] Signed multiply");
                passed++;
            end else begin
                $display("  [FAIL] Mult: %0d", sc);
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
