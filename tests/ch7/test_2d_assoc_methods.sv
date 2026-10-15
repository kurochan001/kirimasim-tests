/*
:name: test_2d_assoc_methods
:description: Test: 2D associative array methods (.exists, .first, .next, .delete)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_2d_assoc_methods.expected
*/
// Test: 2D associative array methods (.exists, .first, .next, .delete)
// on an associative array whose elements are associative arrays (7.8, 7.9)

class my_monitor;
    real m_latency[string][string];

    function new();
    endfunction

    // Pattern A: .exists() on 2D associative array
    function bit check_exists(string src, string dst);
        if (!m_latency.exists(src)) return 0;
        if (!m_latency[src].exists(dst)) return 0;
        return 1;
    endfunction

    // Pattern B: write + read
    function void store(string src, string dst, real val);
        m_latency[src][dst] = val;
    endfunction

    // Pattern C: .first() / .next() nested iteration
    function void report();
        string src, dst;
        if (m_latency.first(src)) begin
            do begin
                if (m_latency[src].first(dst)) begin
                    do begin
                        $display("latency[%s][%s] = %f", src, dst, m_latency[src][dst]);
                    end while (m_latency[src].next(dst));
                end
            end while (m_latency.next(src));
        end
    endfunction

    // Pattern D: .delete() on full 2D array
    function void clear();
        m_latency.delete();
    endfunction

    // Pattern E: .num() / .size()
    function int get_size();
        return m_latency.num();
    endfunction
endclass

module top;
    initial begin
        static my_monitor mon = new();

        // Store values
        mon.store("A", "B", 1.5);
        mon.store("A", "C", 2.0);
        mon.store("B", "C", 3.0);

        // Check exists
        if (mon.check_exists("A", "B") && !mon.check_exists("X", "Y")) begin
            $display("PASS: exists works");
        end else begin
            $display("FAIL: exists broken");
        end

        // Check size
        if (mon.get_size() == 2) begin
            $display("PASS: size works (2 outer keys)");
        end else begin
            $display("FAIL: size returned %0d, expected 2", mon.get_size());
        end

        // Report (iteration)
        mon.report();

        // Delete
        mon.clear();
        if (mon.get_size() == 0) begin
            $display("PASS: delete works");
        end else begin
            $display("FAIL: delete broken, size=%0d", mon.get_size());
        end

        $display("TEST PASSED");
        $finish;
    end
endmodule
