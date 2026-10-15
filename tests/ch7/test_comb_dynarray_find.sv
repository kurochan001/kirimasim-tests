/*
:name: test_comb_dynarray_find
:description: Test: DynamicArray find_first/find_last and locator methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_dynarray_find.expected
*/
// Test: Dynamic array find_first/find_last and locator methods
// Verifies IEEE 1800-2023 §7.12.1 array locator methods
module test_comb_dynarray_find;
    int pass_count = 0;

    initial begin
        // T1: find_first with clause
        begin
            static int arr[] = '{5, 12, 3, 18, 7, 25, 1};
            int result[$];
            result = arr.find_first with (item > 10);
            if (result.size() == 1 && result[0] == 12) begin
                $display("T1: PASS - find_first(>10) = %0d", result[0]);
                pass_count++;
            end else
                $display("T1: FAIL - size=%0d", result.size());
        end

        // T2: find_last with clause
        begin
            static int arr[] = '{5, 12, 3, 18, 7, 25, 1};
            int result[$];
            result = arr.find_last with (item > 10);
            if (result.size() == 1 && result[0] == 25) begin
                $display("T2: PASS - find_last(>10) = %0d", result[0]);
                pass_count++;
            end else
                $display("T2: FAIL - size=%0d val=%0d", result.size(), result.size() > 0 ? result[0] : -1);
        end

        // T3: find_first_index
        begin
            static int arr[] = '{10, 20, 30, 40, 50};
            int idx[$];
            idx = arr.find_first_index with (item >= 30);
            if (idx.size() == 1 && idx[0] == 2) begin
                $display("T3: PASS - find_first_index(>=30) = %0d", idx[0]);
                pass_count++;
            end else
                $display("T3: FAIL - size=%0d", idx.size());
        end

        // T4: find_last_index
        begin
            static int arr[] = '{10, 20, 30, 40, 50};
            int idx[$];
            idx = arr.find_last_index with (item <= 30);
            if (idx.size() == 1 && idx[0] == 2) begin
                $display("T4: PASS - find_last_index(<=30) = %0d", idx[0]);
                pass_count++;
            end else
                $display("T4: FAIL - size=%0d", idx.size());
        end

        // T5: find returns all matches
        begin
            static int arr[] = '{1, 5, 2, 8, 3, 9, 4};
            int result[$];
            result = arr.find with (item > 4);
            if (result.size() == 3) begin
                $display("T5: PASS - find(>4) found %0d items", result.size());
                pass_count++;
            end else
                $display("T5: FAIL - size=%0d (expected 3)", result.size());
        end

        // T6: find with no matches returns empty queue
        begin
            static int arr[] = '{1, 2, 3};
            int result[$];
            result = arr.find with (item > 100);
            if (result.size() == 0) begin
                $display("T6: PASS - find(>100) returns empty");
                pass_count++;
            end else
                $display("T6: FAIL - size=%0d", result.size());
        end

        // T7: min and max on dynamic array
        begin
            static int arr[] = '{42, 7, 99, 3, 56};
            static int mn[$];
            static int mx[$];
            // Assigned here so the result does not depend on the order of static initializers.
            mn = arr.min();
            mx = arr.max();
            if (mn[0] == 3 && mx[0] == 99) begin
                $display("T7: PASS - min=%0d max=%0d", mn[0], mx[0]);
                pass_count++;
            end else
                $display("T7: FAIL - min=%0d max=%0d", mn[0], mx[0]);
        end

        // T8: unique on dynamic array
        begin
            static int arr[] = '{1, 3, 2, 3, 1, 4, 2};
            static int u[$];
            // Assigned here so the result does not depend on the order of static initializers.
            u = arr.unique();
            if (u.size() == 4) begin
                $display("T8: PASS - unique size = %0d", u.size());
                pass_count++;
            end else
                $display("T8: FAIL - unique size = %0d", u.size());
        end

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 8)
            $display("PASS: test_comb_dynarray_find");
        else
            $display("FAIL: test_comb_dynarray_find (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
