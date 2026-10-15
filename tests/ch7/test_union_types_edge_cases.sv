/*
:name: test_union_types_edge_cases
:description: Test: Union types edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_union_types_edge_cases.expected
*/
// Test: Union types edge cases
// IEEE 1800-2023 Section 7.3 Unions
// Tests corner cases: packed unions

`timescale 1ns/1ps

module test_union_types_edge_cases;
    int passed = 0;
    int failed = 0;

    typedef union packed {
        logic [31:0] word;
        struct packed {
            logic [15:0] hi;
            logic [15:0] lo;
        } halves;
        struct packed {
            logic [7:0] b3;
            logic [7:0] b2;
            logic [7:0] b1;
            logic [7:0] b0;
        } bytes;
    } word_union_t;

    typedef union packed {
        logic [15:0] full;
        struct packed {
            logic [7:0] hi;
            logic [7:0] lo;
        } parts;
    } half_union_t;

    word_union_t wu;
    half_union_t hu;

    initial begin
        $display("TEST: Union types edge cases");

        // Test 1: Union word write
        begin
            wu.word = 32'hDEADBEEF;
            if (wu.word == 32'hDEADBEEF) begin
                $display("  [PASS] Union word write");
                passed++;
            end else begin
                $display("  [FAIL] Word: %h", wu.word);
                failed++;
            end
        end

        // Test 2: Union halves access
        begin
            wu.word = 32'h12345678;
            if (wu.halves.lo == 16'h5678 && wu.halves.hi == 16'h1234) begin
                $display("  [PASS] Union halves access");
                passed++;
            end else begin
                $display("  [FAIL] Halves: %h %h", wu.halves.hi, wu.halves.lo);
                failed++;
            end
        end

        // Test 3: Union bytes access
        begin
            wu.word = 32'hAABBCCDD;
            if (wu.bytes.b0 == 8'hDD && wu.bytes.b3 == 8'hAA) begin
                $display("  [PASS] Union bytes access");
                passed++;
            end else begin
                $display("  [FAIL] Bytes: %h %h", wu.bytes.b3, wu.bytes.b0);
                failed++;
            end
        end

        // Test 4: Union write through halves
        begin
            wu.word = 0;
            wu.halves.lo = 16'hFFFF;
            if (wu.word[15:0] == 16'hFFFF && wu.word[31:16] == 16'h0000) begin
                $display("  [PASS] Union halves write");
                passed++;
            end else begin
                $display("  [FAIL] HalfW: %h", wu.word);
                failed++;
            end
        end

        // Test 5: Union write through bytes
        begin
            wu.word = 0;
            wu.bytes.b1 = 8'hAB;
            if (wu.word[15:8] == 8'hAB) begin
                $display("  [PASS] Union bytes write");
                passed++;
            end else begin
                $display("  [FAIL] ByteW: %h", wu.word);
                failed++;
            end
        end

        // Test 6: Nested struct in union
        begin
            hu.full = 16'hABCD;
            if (hu.parts.hi == 8'hAB && hu.parts.lo == 8'hCD) begin
                $display("  [PASS] Nested struct read");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %h %h", hu.parts.hi, hu.parts.lo);
                failed++;
            end
        end

        // Test 7: Nested struct write
        begin
            hu.parts.hi = 8'h12;
            hu.parts.lo = 8'h34;
            if (hu.full == 16'h1234) begin
                $display("  [PASS] Nested struct write");
                passed++;
            end else begin
                $display("  [FAIL] NestedW: %h", hu.full);
                failed++;
            end
        end

        // Test 8: Union bits
        begin
            if ($bits(wu) == 32) begin
                $display("  [PASS] Union bits");
                passed++;
            end else begin
                $display("  [FAIL] Bits: %0d", $bits(wu));
                failed++;
            end
        end

        // Test 9: Union as vector
        begin
            logic [31:0] vec;
            wu.word = 32'h11223344;
            vec = wu;
            if (vec == 32'h11223344) begin
                $display("  [PASS] Union as vector");
                passed++;
            end else begin
                $display("  [FAIL] Vec: %h", vec);
                failed++;
            end
        end

        // Test 10: Vector to union
        begin
            static logic [31:0] src = 32'h55667788;
            wu = src;
            if (wu.word == 32'h55667788) begin
                $display("  [PASS] Vector to union");
                passed++;
            end else begin
                $display("  [FAIL] VecU: %h", wu.word);
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
