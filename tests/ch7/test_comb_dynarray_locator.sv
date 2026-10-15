/*
:name: test_comb_dynarray_locator
:description: Test: Dynamic array locator methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_dynarray_locator.expected
*/
// Test: Dynamic array locator methods
// The find_first, find_last, find_first_index and find_last_index methods
// return queues, empty when nothing matches (7.12.1).
module test_comb_dynarray_locator;
    int pass_count = 0;

    initial begin
        // Test 1: Dynamic array find()
        begin
            static int arr[] = '{10, 25, 5, 30, 15};
            static int found[$];
            // Assigned here so the result does not depend on the order of static initializers.
            found = arr.find() with (item > 20);
            if (found.size() == 2) begin
                $display("T1: PASS - arr.find() size=%0d", found.size());
                pass_count++;
            end else begin
                $display("T1: FAIL - arr.find() size=%0d (expected 2)", found.size());
            end
        end

        // Test 2: Dynamic array find_index()
        begin
            static int arr[] = '{10, 25, 5, 30, 15};
            static int idx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            idx = arr.find_index() with (item > 20);
            if (idx.size() == 2 && idx[0] == 1 && idx[1] == 3) begin
                $display("T2: PASS - arr.find_index() = {%0d, %0d}", idx[0], idx[1]);
                pass_count++;
            end else begin
                $display("T2: FAIL - arr.find_index() size=%0d", idx.size());
            end
        end

        // Test 3: Dynamic array find_first()
        begin
            static int arr[] = '{10, 25, 5, 30, 15};
            static int found[$];
            // Assigned here so the result does not depend on the order of static initializers.
            found = arr.find_first() with (item > 20);
            if (found.size() == 1 && found[0] == 25) begin
                $display("T3: PASS - arr.find_first() = %0d", found[0]);
                pass_count++;
            end else begin
                $display("T3: FAIL - arr.find_first() size=%0d", found.size());
            end
        end

        // Test 4: Dynamic array find_last()
        begin
            static int arr[] = '{10, 25, 5, 30, 15};
            static int found[$];
            // Assigned here so the result does not depend on the order of static initializers.
            found = arr.find_last() with (item > 20);
            if (found.size() == 1 && found[0] == 30) begin
                $display("T4: PASS - arr.find_last() = %0d", found[0]);
                pass_count++;
            end else begin
                $display("T4: FAIL - arr.find_last() size=%0d val=%0d",
                    found.size(), found.size() > 0 ? found[0] : -1);
            end
        end

        // Test 5: Dynamic array find_first_index()
        begin
            static int arr[] = '{10, 25, 5, 30, 15};
            static int idx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            idx = arr.find_first_index() with (item > 20);
            if (idx.size() == 1 && idx[0] == 1) begin
                $display("T5: PASS - arr.find_first_index() = %0d", idx[0]);
                pass_count++;
            end else begin
                $display("T5: FAIL - arr.find_first_index() size=%0d", idx.size());
            end
        end

        // Test 6: Dynamic array find_last_index()
        begin
            static int arr[] = '{10, 25, 5, 30, 15};
            static int idx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            idx = arr.find_last_index() with (item > 20);
            if (idx.size() == 1 && idx[0] == 3) begin
                $display("T6: PASS - arr.find_last_index() = %0d", idx[0]);
                pass_count++;
            end else begin
                $display("T6: FAIL - arr.find_last_index() size=%0d", idx.size());
            end
        end

        // Test 7: No match - find returns empty queue
        begin
            static int arr[] = '{1, 2, 3};
            static int found[$];
            // Assigned here so the result does not depend on the order of static initializers.
            found = arr.find() with (item > 100);
            if (found.size() == 0) begin
                $display("T7: PASS - no match find() returns empty");
                pass_count++;
            end else begin
                $display("T7: FAIL - no match find() size=%0d", found.size());
            end
        end

        // Test 8: No match - find_first_index returns empty queue
        begin
            static int arr[] = '{1, 2, 3};
            static int idx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            idx = arr.find_first_index() with (item > 100);
            if (idx.size() == 0) begin
                $display("T8: PASS - no match find_first_index() returns empty");
                pass_count++;
            end else begin
                $display("T8: FAIL - no match find_first_index() size=%0d", idx.size());
            end
        end

        // Test 9: Dynamic array sum with 'with' clause
        begin
            static int arr[] = '{1, 2, 3, 4};
            static int s;
            // Assigned here so the result does not depend on the order of static initializers.
            s = arr.sum() with (item * item);
            // 1+4+9+16 = 30
            if (s == 30) begin
                $display("T9: PASS - arr.sum() with (item*item) = %0d", s);
                pass_count++;
            end else begin
                $display("T9: FAIL - arr.sum() with (item*item) = %0d (expected 30)", s);
            end
        end

        // Test 10: Dynamic array min/max
        begin
            static int arr[] = '{15, 3, 42, 7};
            static int mn[$];
            static int mx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            mn = arr.min();
            mx = arr.max();
            if (mn.size() > 0 && mn[0] == 3 && mx.size() > 0 && mx[0] == 42) begin
                $display("T10: PASS - arr.min()=%0d, arr.max()=%0d", mn[0], mx[0]);
                pass_count++;
            end else begin
                $display("T10: FAIL - min/max incorrect");
            end
        end

        // Test 11: Dynamic array sort and reverse
        begin
            static int arr[] = '{5, 3, 8, 1, 4};
            arr.sort();
            if (arr[0] == 1 && arr[4] == 8) begin
                $display("T11: PASS - arr.sort(): [%0d,%0d,%0d,%0d,%0d]",
                    arr[0], arr[1], arr[2], arr[3], arr[4]);
                pass_count++;
            end else begin
                $display("T11: FAIL - arr.sort() incorrect");
            end
        end

        // Test 12: Dynamic array unique
        begin
            static int arr[] = '{1, 2, 2, 3, 3, 3};
            static int u[$];
            // Assigned here so the result does not depend on the order of static initializers.
            u = arr.unique();
            if (u.size() == 3) begin
                $display("T12: PASS - arr.unique() size=%0d", u.size());
                pass_count++;
            end else begin
                $display("T12: FAIL - arr.unique() size=%0d (expected 3)", u.size());
            end
        end

        $display("pass_count = %0d", pass_count);
        if (pass_count == 12)
            $display("PASS: test_comb_dynarray_locator");
        else
            $display("FAIL: test_comb_dynarray_locator (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
