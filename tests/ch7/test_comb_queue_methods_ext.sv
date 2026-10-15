/*
:name: test_comb_queue_methods_ext
:description: Test: Extended queue and array method edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.10.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_queue_methods_ext.expected
*/
// Test: Extended queue and array method edge cases
module test_comb_queue_methods_ext;
    int pass_count = 0;

    initial begin
        // Test 1: Queue sum
        begin
            static int q[$] = '{1, 2, 3, 4, 5};
            static int s;
            // Assigned here so the result does not depend on the order of static initializers.
            s = q.sum();
            if (s == 15) begin
                $display("T1: PASS - queue sum = %0d", s);
                pass_count++;
            end else begin
                $display("T1: FAIL - queue sum = %0d (expected 15)", s);
            end
        end

        // Test 2: Queue product
        begin
            static int q[$] = '{1, 2, 3, 4, 5};
            static int p;
            // Assigned here so the result does not depend on the order of static initializers.
            p = q.product();
            if (p == 120) begin
                $display("T2: PASS - queue product = %0d", p);
                pass_count++;
            end else begin
                $display("T2: FAIL - queue product = %0d (expected 120)", p);
            end
        end

        // Test 3: Queue min
        begin
            static int q[$] = '{5, 3, 8, 1, 4};
            static int m[$];
            // Assigned here so the result does not depend on the order of static initializers.
            m = q.min();
            if (m.size() == 1 && m[0] == 1) begin
                $display("T3: PASS - queue min = %0d", m[0]);
                pass_count++;
            end else begin
                $display("T3: FAIL - queue min: size=%0d", m.size());
            end
        end

        // Test 4: Queue max
        begin
            static int q[$] = '{5, 3, 8, 1, 4};
            static int m[$];
            // Assigned here so the result does not depend on the order of static initializers.
            m = q.max();
            if (m.size() == 1 && m[0] == 8) begin
                $display("T4: PASS - queue max = %0d", m[0]);
                pass_count++;
            end else begin
                $display("T4: FAIL - queue max: size=%0d", m.size());
            end
        end

        // Test 5: Queue unique
        begin
            static int q[$] = '{1, 2, 3, 2, 1, 4};
            static int u[$];
            // Assigned here so the result does not depend on the order of static initializers.
            u = q.unique();
            if (u.size() == 4) begin
                $display("T5: PASS - queue unique size = %0d", u.size());
                pass_count++;
            end else begin
                $display("T5: FAIL - queue unique size = %0d (expected 4)", u.size());
            end
        end

        // Test 6: Queue sort
        begin
            static int q[$] = '{5, 3, 8, 1, 4};
            q.sort();
            if (q[0] == 1 && q[1] == 3 && q[2] == 4 && q[3] == 5 && q[4] == 8) begin
                $display("T6: PASS - queue sort: %0d,%0d,%0d,%0d,%0d", q[0], q[1], q[2], q[3], q[4]);
                pass_count++;
            end else begin
                $display("T6: FAIL - queue sort: %0d,%0d,%0d,%0d,%0d", q[0], q[1], q[2], q[3], q[4]);
            end
        end

        // Test 7: Queue rsort
        begin
            static int q[$] = '{5, 3, 8, 1, 4};
            q.rsort();
            if (q[0] == 8 && q[1] == 5 && q[2] == 4 && q[3] == 3 && q[4] == 1) begin
                $display("T7: PASS - queue rsort: %0d,%0d,%0d,%0d,%0d", q[0], q[1], q[2], q[3], q[4]);
                pass_count++;
            end else begin
                $display("T7: FAIL - queue rsort: %0d,%0d,%0d,%0d,%0d", q[0], q[1], q[2], q[3], q[4]);
            end
        end

        // Test 8: Queue reverse
        begin
            static int q[$] = '{1, 2, 3, 4, 5};
            q.reverse();
            if (q[0] == 5 && q[1] == 4 && q[2] == 3 && q[3] == 2 && q[4] == 1) begin
                $display("T8: PASS - queue reverse");
                pass_count++;
            end else begin
                $display("T8: FAIL - queue reverse: %0d,%0d,%0d,%0d,%0d", q[0], q[1], q[2], q[3], q[4]);
            end
        end

        // Test 9: Queue find
        begin
            static int q[$] = '{10, 20, 30, 40, 50};
            static int found[$];
            // Assigned here so the result does not depend on the order of static initializers.
            found = q.find() with (item > 25);
            // Locator methods traverse the array in an unspecified order (7.12.1)
            found.sort();
            if (found.size() == 3 && found[0] == 30 && found[1] == 40 && found[2] == 50) begin
                $display("T9: PASS - queue find with clause: %0d items", found.size());
                pass_count++;
            end else begin
                $display("T9: FAIL - queue find: size=%0d", found.size());
            end
        end

        // Test 10: Queue find_index
        begin
            static int q[$] = '{10, 20, 30, 40, 50};
            static int idx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            idx = q.find_index() with (item == 30);
            if (idx.size() == 1 && idx[0] == 2) begin
                $display("T10: PASS - find_index(30) = %0d", idx[0]);
                pass_count++;
            end else begin
                $display("T10: FAIL - find_index: size=%0d", idx.size());
            end
        end

        // Test 11: Dynamic array sort
        begin
            int darr[];
            darr = new[5];
            darr[0] = 9; darr[1] = 2; darr[2] = 7; darr[3] = 1; darr[4] = 5;
            darr.sort();
            if (darr[0] == 1 && darr[1] == 2 && darr[2] == 5 && darr[3] == 7 && darr[4] == 9) begin
                $display("T11: PASS - dynarray sort");
                pass_count++;
            end else begin
                $display("T11: FAIL - dynarray sort: %0d,%0d,%0d,%0d,%0d",
                    darr[0], darr[1], darr[2], darr[3], darr[4]);
            end
        end

        // Test 12: Empty queue operations
        begin
            int q[$];
            static int s;
            static int p;
            // Assigned here so the result does not depend on the order of static initializers.
            s = q.sum();
            p = q.product();
            if (s == 0) begin
                $display("T12: PASS - empty queue sum = %0d", s);
                pass_count++;
            end else begin
                $display("T12: FAIL - empty queue sum = %0d (expected 0)", s);
            end
        end

        $display("pass_count = %0d", pass_count);
        if (pass_count == 12)
            $display("PASS: test_comb_queue_methods_ext");
        else
            $display("FAIL: test_comb_queue_methods_ext (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
