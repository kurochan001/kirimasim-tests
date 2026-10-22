/*
:name: test_enum_method_edge
:description: Enum methods first, last, num, next, prev and name on contiguous, non-contiguous, single-member and sparse enums
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5 6.19.5.3 6.19.5.4 6.19.5.5 6.19.5.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_method_edge.expected
*/
// Non-contiguous enum values, next()/prev() wrap, first()/last()/num()/name()

module test_enum_method_edge;
    int pass_count = 0;
    int fail_count = 0;
    int total_tests = 0;

    task automatic check(string name, int got, int expected);
        total_tests++;
        if (got === expected) begin
            $display("PASS: %s = %0d", name, got);
            pass_count++;
        end else begin
            $display("FAIL: %s = %0d (expected %0d)", name, got, expected);
            fail_count++;
        end
    endtask

    task automatic check_str(string name, string got, string expected);
        total_tests++;
        if (got == expected) begin
            $display("PASS: %s = %s", name, got);
            pass_count++;
        end else begin
            $display("FAIL: %s = %s (expected %s)", name, got, expected);
            fail_count++;
        end
    endtask

    // --- Enum 1: Contiguous ---
    typedef enum logic [1:0] {A=0, B=1, C=2, D=3} abcd_e;

    // --- Enum 2: Non-contiguous ---
    typedef enum int {RED=0, GREEN=5, BLUE=10, YELLOW=15} color_e;

    // --- Enum 3: Single member ---
    typedef enum {ONLY=42} single_e;

    // --- Enum 4: Large gaps ---
    typedef enum int {LO=0, MID=1000, HI=2000} gap_e;

    initial begin
        // --- Contiguous enum tests ---
        begin
            abcd_e e;

            // first/last
            e = A;
            check("contiguous_first", e.first(), 0);
            check("contiguous_last", e.last(), 3);
            check("contiguous_num", e.num(), 4);

            // next from each position
            e = A;
            check("contiguous_next_A", e.next(), 1);  // B
            e = B;
            check("contiguous_next_B", e.next(), 2);  // C
            e = C;
            check("contiguous_next_C", e.next(), 3);  // D
            e = D;
            check("contiguous_next_D_wrap", e.next(), 0);  // A (wrap)

            // prev from each position
            e = A;
            check("contiguous_prev_A_wrap", e.prev(), 3);  // D (wrap)
            e = B;
            check("contiguous_prev_B", e.prev(), 0);  // A
            e = D;
            check("contiguous_prev_D", e.prev(), 2);  // C

            // next(N)
            e = A;
            check("contiguous_next2", e.next(2), 2);  // C
            e = C;
            check("contiguous_next2_wrap", e.next(2), 0);  // A (wraps past D)
        end

        // --- Non-contiguous enum tests ---
        begin
            color_e c;

            // first/last
            c = RED;
            check("noncontig_first", c.first(), 0);    // RED
            check("noncontig_last", c.last(), 15);      // YELLOW
            check("noncontig_num", c.num(), 4);

            // next
            c = RED;
            check("noncontig_next_RED", c.next(), 5);    // GREEN
            c = GREEN;
            check("noncontig_next_GREEN", c.next(), 10); // BLUE
            c = BLUE;
            check("noncontig_next_BLUE", c.next(), 15);  // YELLOW
            c = YELLOW;
            check("noncontig_next_YELLOW_wrap", c.next(), 0);  // RED (wrap)

            // prev
            c = RED;
            check("noncontig_prev_RED_wrap", c.prev(), 15);  // YELLOW (wrap)
            c = GREEN;
            check("noncontig_prev_GREEN", c.prev(), 0);       // RED
            c = BLUE;
            check("noncontig_prev_BLUE", c.prev(), 5);        // GREEN
            c = YELLOW;
            check("noncontig_prev_YELLOW", c.prev(), 10);     // BLUE

            // next(2) on non-contiguous
            c = RED;
            check("noncontig_next2", c.next(2), 10);           // BLUE
            c = BLUE;
            check("noncontig_next2_wrap", c.next(2), 0);       // RED (wraps)

            // prev(2) on non-contiguous
            c = BLUE;
            check("noncontig_prev2", c.prev(2), 0);            // RED
            c = GREEN;
            check("noncontig_prev2_wrap", c.prev(2), 15);      // YELLOW (wraps)

            // name()
            c = RED;
            check_str("noncontig_name_RED", c.name(), "RED");
            c = BLUE;
            check_str("noncontig_name_BLUE", c.name(), "BLUE");
        end

        // --- Single member enum ---
        begin
            single_e s;
            s = ONLY;
            check("single_first", s.first(), 42);
            check("single_last", s.last(), 42);
            check("single_num", s.num(), 1);
            check("single_next_wrap", s.next(), 42);  // wraps to self
            check("single_prev_wrap", s.prev(), 42);  // wraps to self
            check_str("single_name", s.name(), "ONLY");
        end

        // --- Large gap enum ---
        begin
            gap_e g;

            g = LO;
            check("gap_next_LO", g.next(), 1000);      // MID
            g = MID;
            check("gap_next_MID", g.next(), 2000);      // HI
            g = HI;
            check("gap_next_HI_wrap", g.next(), 0);     // LO (wrap)

            g = LO;
            check("gap_prev_LO_wrap", g.prev(), 2000);  // HI (wrap)
            g = MID;
            check("gap_prev_MID", g.prev(), 0);         // LO
            g = HI;
            check("gap_prev_HI", g.prev(), 1000);       // MID

            check_str("gap_name_MID", g.name(), "HI");
            g = MID;
            check_str("gap_name_MID2", g.name(), "MID");
        end

        $display("\n=== Summary: %0d passed, %0d failed (total %0d) ===", pass_count, fail_count, total_tests);
        if (fail_count == 0) $display("TEST PASSED");
        else $display("TEST FAILED");
        $finish;
    end
endmodule
