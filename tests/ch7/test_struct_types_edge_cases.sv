/*
:name: test_struct_types_edge_cases
:description: Test: Struct types edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1 10.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_types_edge_cases.expected
*/
// Test: Struct types edge cases
// IEEE 1800-2023 Section 7.2 Structures
// Tests corner cases: struct declarations and operations

`timescale 1ns/1ps

module test_struct_types_edge_cases;
    int passed = 0;
    int failed = 0;

    typedef struct {
        int x;
        int y;
    } point_t;

    typedef struct packed {
        logic [7:0] r;
        logic [7:0] g;
        logic [7:0] b;
    } rgb_t;

    typedef struct {
        logic [7:0] data;
        logic valid;
        logic [3:0] tag;
    } packet_t;

    point_t pt;
    rgb_t color;
    packet_t pkt;

    initial begin
        $display("TEST: Struct types edge cases");

        // Test 1: Struct member write
        begin
            pt.x = 10;
            pt.y = 20;
            if (pt.x == 10 && pt.y == 20) begin
                $display("  [PASS] Struct member write");
                passed++;
            end else begin
                $display("  [FAIL] Write: %0d %0d", pt.x, pt.y);
                failed++;
            end
        end

        // Test 2: Struct literal assignment
        begin
            pt = '{100, 200};
            if (pt.x == 100 && pt.y == 200) begin
                $display("  [PASS] Struct literal");
                passed++;
            end else begin
                $display("  [FAIL] Literal: %0d %0d", pt.x, pt.y);
                failed++;
            end
        end

        // Test 3: Packed struct
        begin
            color.r = 8'hFF;
            color.g = 8'h00;
            color.b = 8'hAA;
            if (color.r == 8'hFF && color.g == 8'h00 && color.b == 8'hAA) begin
                $display("  [PASS] Packed struct");
                passed++;
            end else begin
                $display("  [FAIL] Packed: %h %h %h", color.r, color.g, color.b);
                failed++;
            end
        end

        // Test 4: Packed struct as vector
        begin
            color = '{8'hAB, 8'hCD, 8'hEF};
            if (color == 24'hABCDEF) begin
                $display("  [PASS] Packed as vector");
                passed++;
            end else begin
                $display("  [FAIL] Vector: %h", color);
                failed++;
            end
        end

        // Test 5: Mixed struct types
        begin
            pkt.data = 8'h55;
            pkt.valid = 1;
            pkt.tag = 4'hA;
            if (pkt.data == 8'h55 && pkt.valid == 1 && pkt.tag == 4'hA) begin
                $display("  [PASS] Mixed types");
                passed++;
            end else begin
                $display("  [FAIL] Mixed: %h %b %h", pkt.data, pkt.valid, pkt.tag);
                failed++;
            end
        end

        // Test 6: Struct copy
        begin
            point_t pt2;
            pt = '{5, 15};
            pt2 = pt;
            if (pt2.x == 5 && pt2.y == 15) begin
                $display("  [PASS] Struct copy");
                passed++;
            end else begin
                $display("  [FAIL] Copy: %0d %0d", pt2.x, pt2.y);
                failed++;
            end
        end

        // Test 7: Struct member compare
        begin
            point_t a, b;
            a = '{10, 20};
            b = '{10, 20};
            if (a.x == b.x && a.y == b.y) begin
                $display("  [PASS] Struct member compare");
                passed++;
            end else begin
                $display("  [FAIL] Compare: %0d %0d vs %0d %0d", a.x, a.y, b.x, b.y);
                failed++;
            end
        end

        // Test 8: Struct zero init
        begin
            point_t def;
            def.x = 0;
            def.y = 0;
            if (def.x == 0 && def.y == 0) begin
                $display("  [PASS] Struct zero init");
                passed++;
            end else begin
                $display("  [FAIL] Zero: %0d %0d", def.x, def.y);
                failed++;
            end
        end

        // Test 9: Nested access
        begin
            pkt.data = 8'hFF;
            pkt.valid = 0;
            if (pkt.data[7:4] == 4'hF) begin
                $display("  [PASS] Nested access");
                passed++;
            end else begin
                $display("  [FAIL] Nested: %h", pkt.data[7:4]);
                failed++;
            end
        end

        // Test 10: Struct initialization
        begin
            static packet_t p2 = '{8'hAB, 1'b1, 4'h5};
            if (p2.data == 8'hAB && p2.valid == 1 && p2.tag == 4'h5) begin
                $display("  [PASS] Struct init");
                passed++;
            end else begin
                $display("  [FAIL] Init: %h %b %h", p2.data, p2.valid, p2.tag);
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
