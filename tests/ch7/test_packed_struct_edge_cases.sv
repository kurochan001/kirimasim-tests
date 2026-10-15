/*
:name: test_packed_struct_edge_cases
:description: Test: Packed struct edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1 10.9.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_struct_edge_cases.expected
*/
// Test: Packed struct edge cases
// IEEE 1800-2023 Section 7.2 Structures
// Tests corner cases: packed struct operations

`timescale 1ns/1ps

module test_packed_struct_edge_cases;
    int passed = 0;
    int failed = 0;

    // Define packed structs
    typedef struct packed {
        logic [7:0] byte3;
        logic [7:0] byte2;
        logic [7:0] byte1;
        logic [7:0] byte0;
    } quad_byte_t;

    typedef struct packed {
        logic [15:0] high;
        logic [15:0] low;
    } dual_word_t;

    initial begin
        quad_byte_t qb;
        dual_word_t dw;
        logic [31:0] raw;

        $display("TEST: Packed struct edge cases");

        // Test 1: Packed struct assignment
        begin
            qb.byte3 = 8'hAA;
            qb.byte2 = 8'hBB;
            qb.byte1 = 8'hCC;
            qb.byte0 = 8'hDD;
            if (qb.byte3 == 8'hAA && qb.byte0 == 8'hDD) begin
                $display("  [PASS] Packed struct assignment");
                passed++;
            end else begin
                $display("  [FAIL] Assignment");
                failed++;
            end
        end

        // Test 2: Packed struct to raw
        begin
            qb = '{8'h11, 8'h22, 8'h33, 8'h44};
            raw = qb;
            if (raw != 0) begin
                $display("  [PASS] Packed struct to raw");
                passed++;
            end else begin
                $display("  [FAIL] ToRaw");
                failed++;
            end
        end

        // Test 3: Raw to packed struct
        begin
            raw = 32'hDEADBEEF;
            qb = raw;
            if (qb.byte3 != 0 || qb.byte0 != 0) begin
                $display("  [PASS] Raw to packed struct");
                passed++;
            end else begin
                $display("  [FAIL] FromRaw");
                failed++;
            end
        end

        // Test 4: Packed struct zero
        begin
            qb = '0;
            if (qb.byte3 == 0 && qb.byte2 == 0 && qb.byte1 == 0 && qb.byte0 == 0) begin
                $display("  [PASS] Packed struct zero");
                passed++;
            end else begin
                $display("  [FAIL] Zero");
                failed++;
            end
        end

        // Test 5: Packed struct ones
        begin
            qb.byte3 = 8'hFF;
            qb.byte2 = 8'hFF;
            qb.byte1 = 8'hFF;
            qb.byte0 = 8'hFF;
            if (qb.byte3 == 8'hFF && qb.byte0 == 8'hFF) begin
                $display("  [PASS] Packed struct ones");
                passed++;
            end else begin
                $display("  [FAIL] Ones");
                failed++;
            end
        end

        // Test 6: Dual word struct
        begin
            dw.high = 16'h1234;
            dw.low = 16'h5678;
            if (dw.high == 16'h1234 && dw.low == 16'h5678) begin
                $display("  [PASS] Dual word struct");
                passed++;
            end else begin
                $display("  [FAIL] DualWord");
                failed++;
            end
        end

        // Test 7: Struct comparison
        begin
            quad_byte_t a, b;
            a = '{8'h12, 8'h34, 8'h56, 8'h78};
            b = '{8'h12, 8'h34, 8'h56, 8'h78};
            if (a == b) begin
                $display("  [PASS] Struct comparison");
                passed++;
            end else begin
                $display("  [FAIL] Compare");
                failed++;
            end
        end

        // Test 8: Struct inequality
        begin
            quad_byte_t a, b;
            a = '{8'h12, 8'h34, 8'h56, 8'h78};
            b = '{8'hFF, 8'h34, 8'h56, 8'h78};
            if (a != b) begin
                $display("  [PASS] Struct inequality");
                passed++;
            end else begin
                $display("  [FAIL] Inequal");
                failed++;
            end
        end

        // Test 9: Packed struct bit select
        begin
            dw = '{16'hFFFF, 16'h0000};
            if (dw[31:16] == 16'hFFFF && dw[15:0] == 16'h0000) begin
                $display("  [PASS] Packed struct bit select");
                passed++;
            end else begin
                $display("  [FAIL] BitSelect");
                failed++;
            end
        end

        // Test 10: Packed struct copy
        begin
            quad_byte_t src, dst;
            src = '{8'hAB, 8'hCD, 8'hEF, 8'h01};
            dst = src;
            if (dst.byte3 == src.byte3 && dst.byte0 == src.byte0) begin
                $display("  [PASS] Packed struct copy");
                passed++;
            end else begin
                $display("  [FAIL] Copy");
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
