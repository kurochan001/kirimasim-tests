/*
:name: test_static_var_edge_cases_2
:description: Static variables edge cases
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 13.4.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_var_edge_cases_2.expected
*/
// IEEE 1800-2023 §6.21: Static variables edge cases
// Tests for static function/task variables

module test_static_var_edge_cases_2;
    int pass_count = 0;
    int test_count = 0;

    function automatic int counter_func();
        static int count = 0;
        count++;
        return count;
    endfunction

    function automatic int accumulator(int val);
        static int total = 0;
        total += val;
        return total;
    endfunction

    function automatic int get_id();
        static int next_id = 100;
        int id = next_id;
        next_id++;
        return id;
    endfunction

    initial begin
        // Test 1: First call to counter
        test_count++;
        begin
            static int c;
            // Assigned here: static initializers run in an unspecified order (6.21).
            c = counter_func();
            if (c == 1) begin
                pass_count++;
                $display("Test 1 PASS: counter = %0d", c);
            end else begin
                $display("Test 1 FAIL: counter unexpected = %0d", c);
            end
        end

        // Test 2: Second call persists
        test_count++;
        begin
            static int c;
            // Assigned here: static initializers run in an unspecified order (6.21).
            c = counter_func();
            if (c == 2) begin
                pass_count++;
                $display("Test 2 PASS: counter = %0d", c);
            end else begin
                $display("Test 2 FAIL: persist unexpected = %0d", c);
            end
        end

        // Test 3: Third call
        test_count++;
        begin
            static int c;
            // Assigned here: static initializers run in an unspecified order (6.21).
            c = counter_func();
            if (c == 3) begin
                pass_count++;
                $display("Test 3 PASS: counter = %0d", c);
            end else begin
                $display("Test 3 FAIL: third unexpected = %0d", c);
            end
        end

        // Test 4: Accumulator
        test_count++;
        begin
            static int t;
            // Assigned here: static initializers run in an unspecified order (6.21).
            t = accumulator(10);
            if (t == 10) begin
                pass_count++;
                $display("Test 4 PASS: accum = %0d", t);
            end else begin
                $display("Test 4 FAIL: accum unexpected = %0d", t);
            end
        end

        // Test 5: Accumulator adds
        test_count++;
        begin
            static int t;
            // Assigned here: static initializers run in an unspecified order (6.21).
            t = accumulator(20);
            if (t == 30) begin
                pass_count++;
                $display("Test 5 PASS: accum = %0d", t);
            end else begin
                $display("Test 5 FAIL: accum2 unexpected = %0d", t);
            end
        end

        // Test 6: More accumulation
        test_count++;
        begin
            static int t;
            // Assigned here: static initializers run in an unspecified order (6.21).
            t = accumulator(5);
            if (t == 35) begin
                pass_count++;
                $display("Test 6 PASS: accum = %0d", t);
            end else begin
                $display("Test 6 FAIL: accum3 unexpected = %0d", t);
            end
        end

        // Test 7: ID generator
        test_count++;
        begin
            static int id;
            // Assigned here: static initializers run in an unspecified order (6.21).
            id = get_id();
            if (id == 100) begin
                pass_count++;
                $display("Test 7 PASS: id = %0d", id);
            end else begin
                $display("Test 7 FAIL: id unexpected = %0d", id);
            end
        end

        // Test 8: Second ID
        test_count++;
        begin
            static int id;
            // Assigned here: static initializers run in an unspecified order (6.21).
            id = get_id();
            if (id == 101) begin
                pass_count++;
                $display("Test 8 PASS: id = %0d", id);
            end else begin
                $display("Test 8 FAIL: id2 unexpected = %0d", id);
            end
        end

        // Test 9: Multiple counter calls
        test_count++;
        begin
            static int c1;
            static int c2;
            static int c3;
            // Assigned here: static initializers run in an unspecified order (6.21).
            c1 = counter_func();
            c2 = counter_func();
            c3 = counter_func();
            if (c3 == c1 + 2) begin
                pass_count++;
                $display("Test 9 PASS: sequential c1=%0d c3=%0d", c1, c3);
            end else begin
                $display("Test 9 FAIL: seq unexpected");
            end
        end

        // Test 10: Loop with static
        test_count++;
        begin
            static int last = 0;
            for (int i = 0; i < 5; i++) begin
                last = counter_func();
            end
            pass_count++;
            $display("Test 10 PASS: loop static last = %0d", last);
        end

        // Test 11: Accumulator with negatives
        test_count++;
        begin
            static int t;
            // Assigned here: static initializers run in an unspecified order (6.21).
            t = accumulator(-10);
            pass_count++;
            $display("Test 11 PASS: accum neg = %0d", t);
        end

        // Test 12: ID sequence
        test_count++;
        begin
            int ids[3];
            ids[0] = get_id();
            ids[1] = get_id();
            ids[2] = get_id();
            if (ids[1] == ids[0] + 1 && ids[2] == ids[1] + 1) begin
                pass_count++;
                $display("Test 12 PASS: ID sequence");
            end else begin
                $display("Test 12 FAIL: ID seq unexpected");
            end
        end

        $display("=== Static Var Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
