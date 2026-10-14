/*
:name: test_logic_literal_edge_cases
:description: Test: Logic literal edge cases
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.7.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logic_literal_edge_cases.expected
*/
// Test: Logic literal edge cases
// IEEE 1800-2023 Section 5.7 Numbers
// Tests corner cases: logic literals with X and Z

`timescale 1ns/1ps

module test_logic_literal_edge_cases;
    int passed = 0;
    int failed = 0;

    logic [7:0] lval;
    logic [3:0] sval;

    initial begin
        $display("TEST: Logic literal edge cases");

        // Test 1: All zeros
        begin
            lval = 8'b00000000;
            if (lval == 0) begin
                $display("  [PASS] All zeros");
                passed++;
            end else begin
                $display("  [FAIL] Zeros: %b", lval);
                failed++;
            end
        end

        // Test 2: All ones
        begin
            lval = 8'b11111111;
            if (lval == 8'hFF) begin
                $display("  [PASS] All ones");
                passed++;
            end else begin
                $display("  [FAIL] Ones: %b", lval);
                failed++;
            end
        end

        // Test 3: Alternating bits
        begin
            lval = 8'b10101010;
            if (lval == 8'hAA) begin
                $display("  [PASS] Alternating bits");
                passed++;
            end else begin
                $display("  [FAIL] Alt: %b", lval);
                failed++;
            end
        end

        // Test 4: Single bit set
        begin
            lval = 8'b00010000;
            if (lval == 8'h10) begin
                $display("  [PASS] Single bit set");
                passed++;
            end else begin
                $display("  [FAIL] SingleBit: %b", lval);
                failed++;
            end
        end

        // Test 5: MSB set
        begin
            lval = 8'b10000000;
            if (lval == 8'h80) begin
                $display("  [PASS] MSB set");
                passed++;
            end else begin
                $display("  [FAIL] MSB: %b", lval);
                failed++;
            end
        end

        // Test 6: LSB set
        begin
            lval = 8'b00000001;
            if (lval == 8'h01) begin
                $display("  [PASS] LSB set");
                passed++;
            end else begin
                $display("  [FAIL] LSB: %b", lval);
                failed++;
            end
        end

        // Test 7: Hex format
        begin
            lval = 8'hAB;
            if (lval == 8'b10101011) begin
                $display("  [PASS] Hex format");
                passed++;
            end else begin
                $display("  [FAIL] Hex: %h", lval);
                failed++;
            end
        end

        // Test 8: Decimal format
        begin
            lval = 8'd200;
            if (lval == 8'hC8) begin
                $display("  [PASS] Decimal format");
                passed++;
            end else begin
                $display("  [FAIL] Dec: %0d", lval);
                failed++;
            end
        end

        // Test 9: Small width
        begin
            sval = 4'b1100;
            if (sval == 4'hC) begin
                $display("  [PASS] Small width");
                passed++;
            end else begin
                $display("  [FAIL] Small: %b", sval);
                failed++;
            end
        end

        // Test 10: Width truncation
        begin
            sval = 8'hAB;  // Truncates to lower 4 bits
            if (sval == 4'hB) begin
                $display("  [PASS] Width truncation");
                passed++;
            end else begin
                $display("  [FAIL] Trunc: %h", sval);
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
