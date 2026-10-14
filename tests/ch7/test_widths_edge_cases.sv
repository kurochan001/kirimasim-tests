/*
:name: test_widths_edge_cases
:description: Test: Bit widths edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 10.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_widths_edge_cases.expected
*/
// Test: Bit widths edge cases
// IEEE 1800-2023 Section 7.4 Packed and Unpacked Arrays
// Tests corner cases: different bit widths

`timescale 1ns/1ps

module test_widths_edge_cases;
    int passed = 0;
    int failed = 0;

    // Different widths
    logic [0:0] w1;
    logic [3:0] w4;
    logic [7:0] w8;
    logic [15:0] w16;
    logic [31:0] w32;
    logic [63:0] w64;

    initial begin
        $display("TEST: Bit widths edge cases");

        // Test 1: 1-bit width
        begin
            w1 = 1;
            if (w1 == 1) begin
                $display("  [PASS] 1-bit width");
                passed++;
            end else begin
                $display("  [FAIL] W1: %b", w1);
                failed++;
            end
        end

        // Test 2: 4-bit width
        begin
            w4 = 4'hF;
            if (w4 == 15) begin
                $display("  [PASS] 4-bit width");
                passed++;
            end else begin
                $display("  [FAIL] W4: %h", w4);
                failed++;
            end
        end

        // Test 3: 8-bit width
        begin
            w8 = 8'hAB;
            if (w8 == 8'hAB) begin
                $display("  [PASS] 8-bit width");
                passed++;
            end else begin
                $display("  [FAIL] W8: %h", w8);
                failed++;
            end
        end

        // Test 4: 16-bit width
        begin
            w16 = 16'hABCD;
            if (w16 == 16'hABCD) begin
                $display("  [PASS] 16-bit width");
                passed++;
            end else begin
                $display("  [FAIL] W16: %h", w16);
                failed++;
            end
        end

        // Test 5: 32-bit width
        begin
            w32 = 32'hDEADBEEF;
            if (w32 == 32'hDEADBEEF) begin
                $display("  [PASS] 32-bit width");
                passed++;
            end else begin
                $display("  [FAIL] W32: %h", w32);
                failed++;
            end
        end

        // Test 6: 64-bit width
        begin
            w64 = 64'h123456789ABCDEF0;
            if (w64 == 64'h123456789ABCDEF0) begin
                $display("  [PASS] 64-bit width");
                passed++;
            end else begin
                $display("  [FAIL] W64: %h", w64);
                failed++;
            end
        end

        // Test 7: $bits check
        begin
            if ($bits(w8) == 8 && $bits(w32) == 32) begin
                $display("  [PASS] $bits check");
                passed++;
            end else begin
                $display("  [FAIL] Bits");
                failed++;
            end
        end

        // Test 8: Width truncation
        begin
            w8 = 16'h1234;
            if (w8 == 8'h34) begin
                $display("  [PASS] Width truncation");
                passed++;
            end else begin
                $display("  [FAIL] Trunc: %h", w8);
                failed++;
            end
        end

        // Test 9: Width extension
        begin
            w8 = 8'hAB;
            w16 = w8;
            if (w16 == 16'h00AB) begin
                $display("  [PASS] Width extension");
                passed++;
            end else begin
                $display("  [FAIL] Ext: %h", w16);
                failed++;
            end
        end

        // Test 10: Max values for widths
        begin
            w4 = 4'hF;
            w8 = 8'hFF;
            if (w4 == 15 && w8 == 255) begin
                $display("  [PASS] Max values");
                passed++;
            end else begin
                $display("  [FAIL] Max");
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
