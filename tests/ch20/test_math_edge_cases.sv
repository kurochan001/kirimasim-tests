/*
:name: test_math_edge_cases
:description: Test: Math functions edge cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.8.1 20.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_math_edge_cases.expected
*/
// Test: Math functions edge cases
// IEEE 1800-2023 Section 20.8 Math Functions
// Tests corner cases: integer conversions, $clog2, $countones, $onehot

`timescale 1ns/1ps

module test_math_edge_cases;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("TEST: Math functions edge cases");

        // Test 1: $clog2 with powers of 2
        begin
            if ($clog2(1) == 0 && $clog2(2) == 1 && $clog2(4) == 2) begin
                $display("  [PASS] $clog2 powers of 2 work");
                passed++;
            end else begin
                $display("  [FAIL] $clog2 powers of 2 incorrect");
                failed++;
            end
        end

        // Test 2: $clog2 with non-powers of 2
        begin
            if ($clog2(3) == 2 && $clog2(5) == 3 && $clog2(7) == 3) begin
                $display("  [PASS] $clog2 non-powers of 2 work");
                passed++;
            end else begin
                $display("  [FAIL] $clog2 non-powers of 2: 3=%0d, 5=%0d, 7=%0d",
                         $clog2(3), $clog2(5), $clog2(7));
                failed++;
            end
        end

        // Test 3: $clog2(0) edge case
        begin
            // IEEE 1800-2023: $clog2(0) returns 0 or implementation-defined
            static int val = $clog2(0);
            if (val == 0) begin
                $display("  [PASS] $clog2(0) = 0");
                passed++;
            end else begin
                $display("  [FAIL] $clog2(0) should be 0, got %0d", val);
                failed++;
            end
        end

        // Test 4: $countones basic
        begin
            if ($countones(8'b00000000) == 0 &&
                $countones(8'b11111111) == 8 &&
                $countones(8'b10101010) == 4) begin
                $display("  [PASS] $countones basic patterns work");
                passed++;
            end else begin
                $display("  [FAIL] $countones basic patterns incorrect");
                failed++;
            end
        end

        // Test 5: $countones with single bit
        begin
            if ($countones(8'b00000001) == 1 &&
                $countones(8'b10000000) == 1) begin
                $display("  [PASS] $countones single bit works");
                passed++;
            end else begin
                $display("  [FAIL] $countones single bit incorrect");
                failed++;
            end
        end

        // Test 6: $onehot basic
        begin
            if ($onehot(8'b00000001) == 1 &&
                $onehot(8'b10000000) == 1 &&
                $onehot(8'b00001000) == 1) begin
                $display("  [PASS] $onehot single-bit patterns work");
                passed++;
            end else begin
                $display("  [FAIL] $onehot single-bit patterns incorrect");
                failed++;
            end
        end

        // Test 7: $onehot non-onehot values
        begin
            if ($onehot(8'b00000000) == 0 &&
                $onehot(8'b11111111) == 0 &&
                $onehot(8'b00000011) == 0) begin
                $display("  [PASS] $onehot non-onehot patterns return 0");
                passed++;
            end else begin
                $display("  [FAIL] $onehot non-onehot should return 0");
                failed++;
            end
        end

        // Test 8: $onehot0 (zero or one-hot)
        begin
            if ($onehot0(8'b00000000) == 1 &&
                $onehot0(8'b00000001) == 1 &&
                $onehot0(8'b00000011) == 0) begin
                $display("  [PASS] $onehot0 patterns work");
                passed++;
            end else begin
                $display("  [FAIL] $onehot0 patterns incorrect");
                failed++;
            end
        end

        // Test 9: $isunknown with X
        begin
            static logic [3:0] val_x = 4'bx01x;
            static logic [3:0] val_ok = 4'b0101;
            if ($isunknown(val_x) == 1 && $isunknown(val_ok) == 0) begin
                $display("  [PASS] $isunknown detects X values");
                passed++;
            end else begin
                $display("  [FAIL] $isunknown detection incorrect");
                failed++;
            end
        end

        // Test 10: $isunknown with Z
        begin
            static logic [3:0] val_z = 4'b01z0;
            if ($isunknown(val_z) == 1) begin
                $display("  [PASS] $isunknown detects Z values");
                passed++;
            end else begin
                $display("  [FAIL] $isunknown should detect Z");
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
