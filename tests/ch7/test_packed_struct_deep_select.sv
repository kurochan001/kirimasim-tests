/*
:name: test_packed_struct_deep_select
:description: Test: 4-level deep packed struct member + bit-range/bit-select write-back
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1 11.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_struct_deep_select.expected
*/
// Test: 4-level deep packed struct member + bit-range/bit-select write-back
// IEEE 1800-2023 section 7.2: packed struct member bit/part-select assignment

module test_packed_struct_deep_select;

    // 4-level deep packed struct hierarchy
    typedef struct packed {
        logic [7:0] val;
    } level_d_t;

    typedef struct packed {
        level_d_t d;
    } level_c_t;

    typedef struct packed {
        level_c_t c;
    } level_b_t;

    typedef struct packed {
        level_b_t b;
    } level_a_t;

    // 2-level deep packed struct for comparison
    typedef struct packed {
        logic [7:0] lo;
        logic [7:0] hi;
    } pair_t;

    typedef struct packed {
        pair_t inner;
    } outer_t;

    // 3-level deep packed struct
    typedef struct packed {
        logic [7:0] data;
    } leaf_t;

    typedef struct packed {
        leaf_t x;
        leaf_t y;
    } mid_t;

    typedef struct packed {
        mid_t m;
    } top_t;

    int pass_count = 0;
    int fail_count = 0;
    int test_num = 0;

    task check(input string name, input logic [63:0] actual, input logic [63:0] expected);
        test_num++;
        if (actual === expected) begin
            $display("PASS [%0d] %s: 0x%0h", test_num, name, actual);
            pass_count++;
        end else begin
            $display("FAIL [%0d] %s: got 0x%0h, expected 0x%0h", test_num, name, actual, expected);
            fail_count++;
        end
    endtask

    initial begin
        level_a_t a;
        outer_t o;
        top_t t;

        // ---- Test 1: 4-level deep full member assignment (should already work) ----
        a = '0;
        a.b.c.d.val = 8'hCC;
        check("4-level full member assign", a.b.c.d.val, 8'hCC);

        // ---- Test 2: 4-level deep part-select [3:0] ----
        a = '0;
        a.b.c.d.val[3:0] = 4'hF;
        check("4-level part-select [3:0]", a.b.c.d.val, 8'h0F);

        // ---- Test 3: 4-level deep part-select [7:4] ----
        a = '0;
        a.b.c.d.val[7:4] = 4'hA;
        check("4-level part-select [7:4]", a.b.c.d.val, 8'hA0);

        // ---- Test 4: 4-level deep bit-select ----
        a = '0;
        a.b.c.d.val[0] = 1'b1;
        check("4-level bit-select [0]", a.b.c.d.val, 8'h01);

        // ---- Test 5: 4-level deep bit-select [7] ----
        a = '0;
        a.b.c.d.val[7] = 1'b1;
        check("4-level bit-select [7]", a.b.c.d.val, 8'h80);

        // ---- Test 6: 4-level deep part-select preserves other bits ----
        a = '0;
        a.b.c.d.val = 8'hFF;
        a.b.c.d.val[3:0] = 4'h0;
        check("4-level part-select preserves upper", a.b.c.d.val, 8'hF0);

        // ---- Test 7: 4-level deep part-select preserves other bits (reverse) ----
        a = '0;
        a.b.c.d.val = 8'hFF;
        a.b.c.d.val[7:4] = 4'h0;
        check("4-level part-select preserves lower", a.b.c.d.val, 8'h0F);

        // ---- Test 8: 2-level deep part-select (should already work) ----
        o = '0;
        o.inner.lo[3:0] = 4'hB;
        check("2-level part-select [3:0]", o.inner.lo, 8'h0B);

        // ---- Test 9: 2-level deep bit-select ----
        o = '0;
        o.inner.hi[5] = 1'b1;
        check("2-level bit-select [5]", o.inner.hi, 8'h20);

        // ---- Test 10: 3-level deep part-select ----
        t = '0;
        t.m.x.data[3:0] = 4'hC;
        check("3-level part-select x.data[3:0]", t.m.x.data, 8'h0C);

        // ---- Test 11: 3-level deep part-select second member ----
        t = '0;
        t.m.y.data[7:4] = 4'hD;
        check("3-level part-select y.data[7:4]", t.m.y.data, 8'hD0);

        // ---- Test 12: 3-level deep bit-select ----
        t = '0;
        t.m.x.data[3] = 1'b1;
        check("3-level bit-select x.data[3]", t.m.x.data, 8'h08);

        // ---- Test 13: Multiple sequential part-selects on 4-level ----
        a = '0;
        a.b.c.d.val[3:0] = 4'h5;
        a.b.c.d.val[7:4] = 4'hA;
        check("4-level sequential part-selects", a.b.c.d.val, 8'hA5);

        // ---- Test 14: Verify whole struct value after deep part-select ----
        a = '0;
        a.b.c.d.val[3:0] = 4'hF;
        check("4-level struct overall after part-select", a, 8'h0F);

        // ---- Test 15: Multiple bit-selects on 4-level ----
        a = '0;
        a.b.c.d.val[0] = 1'b1;
        a.b.c.d.val[2] = 1'b1;
        a.b.c.d.val[4] = 1'b1;
        a.b.c.d.val[6] = 1'b1;
        check("4-level multiple bit-selects", a.b.c.d.val, 8'h55);

        $display("\n=== Results: %0d/%0d passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        else $display("SOME TESTS FAILED");
    end
endmodule
