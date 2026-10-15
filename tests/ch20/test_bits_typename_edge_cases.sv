/*
:name: test_bits_typename_edge_cases
:description: Test: $bits and $typename edge cases
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.1 20.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits_typename_edge_cases.expected
*/
// Test: $bits and $typename edge cases
// IEEE 1800-2023 Section 20.6.2 $bits, Section 20.6.1 $typename
// Tests corner cases: type query system functions

`timescale 1ns/1ps

module test_bits_typename_edge_cases;
    int passed = 0;
    int failed = 0;

    // Type definitions for testing
    typedef logic [7:0] byte_t;
    typedef logic [31:0] word_t;
    typedef struct packed {
        logic [15:0] a;
        logic [15:0] b;
    } pair_t;

    initial begin
        byte_t b;
        word_t w;
        pair_t p;
        logic [63:0] quad;
        int i;
        shortint si;
        longint li;
        bit [15:0] bv;

        $display("TEST: $bits and $typename edge cases");

        // Test 1: $bits of byte
        begin
            if ($bits(b) == 8) begin
                $display("  [PASS] $bits of byte");
                passed++;
            end else begin
                $display("  [FAIL] BitsByte: %0d", $bits(b));
                failed++;
            end
        end

        // Test 2: $bits of word
        begin
            if ($bits(w) == 32) begin
                $display("  [PASS] $bits of word");
                passed++;
            end else begin
                $display("  [FAIL] BitsWord: %0d", $bits(w));
                failed++;
            end
        end

        // Test 3: $bits of struct
        begin
            if ($bits(p) == 32) begin
                $display("  [PASS] $bits of struct");
                passed++;
            end else begin
                $display("  [FAIL] BitsStruct: %0d", $bits(p));
                failed++;
            end
        end

        // Test 4: $bits of quad
        begin
            if ($bits(quad) == 64) begin
                $display("  [PASS] $bits of quad");
                passed++;
            end else begin
                $display("  [FAIL] BitsQuad: %0d", $bits(quad));
                failed++;
            end
        end

        // Test 5: $bits of int
        begin
            if ($bits(i) == 32) begin
                $display("  [PASS] $bits of int");
                passed++;
            end else begin
                $display("  [FAIL] BitsInt: %0d", $bits(i));
                failed++;
            end
        end

        // Test 6: $bits of shortint
        begin
            if ($bits(si) == 16) begin
                $display("  [PASS] $bits of shortint");
                passed++;
            end else begin
                $display("  [FAIL] BitsShort: %0d", $bits(si));
                failed++;
            end
        end

        // Test 7: $bits of longint
        begin
            if ($bits(li) == 64) begin
                $display("  [PASS] $bits of longint");
                passed++;
            end else begin
                $display("  [FAIL] BitsLong: %0d", $bits(li));
                failed++;
            end
        end

        // Test 8: $bits of bit vector
        begin
            if ($bits(bv) == 16) begin
                $display("  [PASS] $bits of bit vector");
                passed++;
            end else begin
                $display("  [FAIL] BitsBitVec: %0d", $bits(bv));
                failed++;
            end
        end

        // Test 9: $bits type vs variable
        begin
            if ($bits(byte_t) == $bits(b)) begin
                $display("  [PASS] $bits type vs variable");
                passed++;
            end else begin
                $display("  [FAIL] TypeVsVar");
                failed++;
            end
        end

        // Test 10: $bits consistency
        begin
            logic [99:0] wide;
            if ($bits(wide) == 100) begin
                $display("  [PASS] $bits consistency");
                passed++;
            end else begin
                $display("  [FAIL] Consistency: %0d", $bits(wide));
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
