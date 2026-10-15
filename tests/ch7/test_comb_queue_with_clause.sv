/*
:name: test_comb_queue_with_clause
:description: Test: Queue methods with 'with' clause
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.12.1 7.12.2 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_queue_with_clause.expected
*/
// Test: Queue methods with 'with' clause
// The with clause gives the key that each method uses (7.12).
module test_comb_queue_with_clause;
    int pass_count = 0;

    initial begin
        // Test 1: sum() with 'with' clause
        begin
            static int q[$] = '{1, 2, 3, 4, 5};
            static int s;
            // Assigned here so the result does not depend on the order of static initializers.
            s = q.sum() with (item * 2);
            // Expected: (1*2)+(2*2)+(3*2)+(4*2)+(5*2) = 30
            if (s == 30) begin
                $display("T1: PASS - q.sum() with (item*2) = %0d", s);
                pass_count++;
            end else begin
                $display("T1: FAIL - q.sum() with (item*2) = %0d (expected 30)", s);
            end
        end

        // Test 2: product() with 'with' clause
        begin
            static int q[$] = '{1, 2, 3};
            static int p;
            // Assigned here so the result does not depend on the order of static initializers.
            p = q.product() with (item + 1);
            // Expected: (1+1)*(2+1)*(3+1) = 2*3*4 = 24
            if (p == 24) begin
                $display("T2: PASS - q.product() with (item+1) = %0d", p);
                pass_count++;
            end else begin
                $display("T2: FAIL - q.product() with (item+1) = %0d (expected 24)", p);
            end
        end

        // Test 3: sort() with 'with' clause (sort by absolute value)
        begin
            static int q[$] = '{-3, 1, -5, 2, -1};
            static int q_copy[$];
            // Assigned here so the result does not depend on the order of static initializers.
            q_copy = q;
            // sort by item*item (effectively absolute value sort for distinct abs)
            q_copy.sort() with (item * item);
            // Expected order: -1, 1, 2, -3, -5 (sorted by 1,1,4,9,25)
            // Note: -1 and 1 both have item*item=1, order between them is stable
            if (q_copy[0] * q_copy[0] <= q_copy[1] * q_copy[1] &&
                q_copy[1] * q_copy[1] <= q_copy[2] * q_copy[2]) begin
                $display("T3: PASS - q.sort() with clause works");
                pass_count++;
            end else begin
                $display("T3: FAIL - q.sort() with clause: [%0d,%0d,%0d,%0d,%0d]",
                    q_copy[0], q_copy[1], q_copy[2], q_copy[3], q_copy[4]);
            end
        end

        // Test 4: rsort() with 'with' clause
        begin
            static int q[$] = '{3, 1, 4, 1, 5};
            q.rsort() with (item);
            // Expected: 5, 4, 3, 1, 1
            if (q[0] == 5 && q[1] == 4 && q[2] == 3) begin
                $display("T4: PASS - q.rsort() with clause: [%0d,%0d,%0d,%0d,%0d]",
                    q[0], q[1], q[2], q[3], q[4]);
                pass_count++;
            end else begin
                $display("T4: FAIL - q.rsort() with clause: [%0d,%0d,%0d,%0d,%0d]",
                    q[0], q[1], q[2], q[3], q[4]);
            end
        end

        // Test 5: min() with 'with' clause
        begin
            static int q[$] = '{-10, 3, -5, 7};
            static int m[$];
            // Assigned here so the result does not depend on the order of static initializers.
            m = q.min() with (item * item);
            // min by item*item: 3 has smallest square (9)
            if (m.size() > 0 && m[0] == 3) begin
                $display("T5: PASS - q.min() with (item*item) = %0d", m[0]);
                pass_count++;
            end else begin
                $display("T5: FAIL - q.min() with (item*item) = %0d (expected 3)",
                    m.size() > 0 ? m[0] : -999);
            end
        end

        // Test 6: max() with 'with' clause
        begin
            static int q[$] = '{-10, 3, -5, 7};
            static int m[$];
            // Assigned here so the result does not depend on the order of static initializers.
            m = q.max() with (item * item);
            // max by item*item: -10 has largest square (100)
            if (m.size() > 0 && m[0] == -10) begin
                $display("T6: PASS - q.max() with (item*item) = %0d", m[0]);
                pass_count++;
            end else begin
                $display("T6: FAIL - q.max() with (item*item) = %0d (expected -10)",
                    m.size() > 0 ? m[0] : -999);
            end
        end

        // Test 7: unique() on queue
        begin
            static int q[$] = '{1, 2, 2, 3, 3, 3, 4};
            static int u[$];
            // Assigned here so the result does not depend on the order of static initializers.
            u = q.unique();
            if (u.size() == 4) begin
                $display("T7: PASS - q.unique() size=%0d", u.size());
                pass_count++;
            end else begin
                $display("T7: FAIL - q.unique() size=%0d (expected 4)", u.size());
            end
        end

        // Test 8: unique_index() on queue
        begin
            static int q[$] = '{10, 20, 10, 30, 20};
            static int idx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            idx = q.unique_index();
            // unique_index returns indices of first occurrences: 0,1,3
            if (idx.size() == 3) begin
                $display("T8: PASS - q.unique_index() size=%0d", idx.size());
                pass_count++;
            end else begin
                $display("T8: FAIL - q.unique_index() size=%0d (expected 3)", idx.size());
            end
        end

        // Test 9: find_first() with clause
        begin
            static int q[$] = '{5, 12, 3, 18, 7};
            static int found[$];
            // Assigned here so the result does not depend on the order of static initializers.
            found = q.find_first() with (item > 10);
            if (found.size() == 1 && found[0] == 12) begin
                $display("T9: PASS - find_first() with = %0d", found[0]);
                pass_count++;
            end else begin
                $display("T9: FAIL - find_first() size=%0d", found.size());
            end
        end

        // Test 10: find_last() with clause
        begin
            static int q[$] = '{5, 12, 3, 18, 7};
            static int found[$];
            // Assigned here so the result does not depend on the order of static initializers.
            found = q.find_last() with (item > 10);
            if (found.size() == 1 && found[0] == 18) begin
                $display("T10: PASS - find_last() with = %0d", found[0]);
                pass_count++;
            end else begin
                $display("T10: FAIL - find_last() size=%0d val=%0d",
                    found.size(), found.size() > 0 ? found[0] : -1);
            end
        end

        // Test 11: find_first_index() with clause
        begin
            static int q[$] = '{5, 12, 3, 18, 7};
            static int idx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            idx = q.find_first_index() with (item > 10);
            if (idx.size() == 1 && idx[0] == 1) begin
                $display("T11: PASS - find_first_index() = %0d", idx[0]);
                pass_count++;
            end else begin
                $display("T11: FAIL - find_first_index() size=%0d", idx.size());
            end
        end

        // Test 12: find_last_index() with clause
        begin
            static int q[$] = '{5, 12, 3, 18, 7};
            static int idx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            idx = q.find_last_index() with (item > 10);
            if (idx.size() == 1 && idx[0] == 3) begin
                $display("T12: PASS - find_last_index() = %0d", idx[0]);
                pass_count++;
            end else begin
                $display("T12: FAIL - find_last_index() size=%0d", idx.size());
            end
        end

        $display("pass_count = %0d", pass_count);
        if (pass_count == 12)
            $display("PASS: test_comb_queue_with_clause");
        else
            $display("FAIL: test_comb_queue_with_clause (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
