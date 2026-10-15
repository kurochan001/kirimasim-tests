/*
:name: test_array_methods_2
:description: Test for IEEE 1800-2023 §7.12: Array manipulation methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.12.1 7.12.2 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_methods_2.expected
*/
// Test for IEEE 1800-2023 §7.12: Array manipulation methods

module test_array_methods_2;
    int dyn_arr[];
    int queue_arr[$];
    int result;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        $display("=== Array Methods Test ===");

        // Initialize dynamic array
        dyn_arr = new[5];
        dyn_arr = '{5, 3, 1, 4, 2};

        // Initialize queue
        queue_arr = '{100, 200, 300, 400, 500};

        // Test size()
        result = dyn_arr.size();
        if (result == 5) begin
            $display("PASS: dyn_arr.size() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: dyn_arr.size() expected 5, got %0d", result);
            fail_count++;
        end

        // Test sum()
        dyn_arr = '{10, 30, 20, 50, 40};
        result = dyn_arr.sum();
        if (result == 150) begin
            $display("PASS: dyn_arr.sum() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: dyn_arr.sum() expected 150, got %0d", result);
            fail_count++;
        end

        // Test product()
        dyn_arr = '{1, 2, 3, 4};
        result = dyn_arr.product();
        if (result == 24) begin
            $display("PASS: dyn_arr.product() = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: dyn_arr.product() expected 24, got %0d", result);
            fail_count++;
        end

        // Test min()
        dyn_arr = '{50, 10, 30, 20, 40};
        begin
            int min_q[$];
            min_q = dyn_arr.min();
            if (min_q.size() > 0 && min_q[0] == 10) begin
                $display("PASS: dyn_arr.min() = %0d", min_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn_arr.min() expected 10");
                fail_count++;
            end
        end

        // Test max()
        begin
            int max_q[$];
            max_q = dyn_arr.max();
            if (max_q.size() > 0 && max_q[0] == 50) begin
                $display("PASS: dyn_arr.max() = %0d", max_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn_arr.max() expected 50");
                fail_count++;
            end
        end

        // Test reverse()
        dyn_arr = '{1, 2, 3, 4, 5};
        dyn_arr.reverse();
        if (dyn_arr[0] == 5 && dyn_arr[4] == 1) begin
            $display("PASS: dyn_arr.reverse() = {%0d, %0d, %0d, %0d, %0d}",
                     dyn_arr[0], dyn_arr[1], dyn_arr[2], dyn_arr[3], dyn_arr[4]);
            pass_count++;
        end else begin
            $display("FAIL: dyn_arr.reverse() incorrect");
            fail_count++;
        end

        // Test sort()
        dyn_arr = '{50, 10, 30, 20, 40};
        dyn_arr.sort();
        if (dyn_arr[0] == 10 && dyn_arr[4] == 50) begin
            $display("PASS: dyn_arr.sort() = {%0d, %0d, %0d, %0d, %0d}",
                     dyn_arr[0], dyn_arr[1], dyn_arr[2], dyn_arr[3], dyn_arr[4]);
            pass_count++;
        end else begin
            $display("FAIL: dyn_arr.sort() incorrect");
            fail_count++;
        end

        // Test rsort()
        dyn_arr = '{10, 50, 30, 20, 40};
        dyn_arr.rsort();
        if (dyn_arr[0] == 50 && dyn_arr[4] == 10) begin
            $display("PASS: dyn_arr.rsort() = {%0d, %0d, %0d, %0d, %0d}",
                     dyn_arr[0], dyn_arr[1], dyn_arr[2], dyn_arr[3], dyn_arr[4]);
            pass_count++;
        end else begin
            $display("FAIL: dyn_arr.rsort() incorrect");
            fail_count++;
        end

        // Test shuffle(): the order is random, so sort and check the elements
        dyn_arr = '{1, 2, 3, 4, 5};
        dyn_arr.shuffle();
        dyn_arr.sort();
        if (dyn_arr.size() == 5 && dyn_arr[0] == 1 && dyn_arr[1] == 2 && dyn_arr[2] == 3 &&
            dyn_arr[3] == 4 && dyn_arr[4] == 5) begin
            $display("PASS: dyn_arr.shuffle() kept the elements");
            pass_count++;
        end else begin
            $display("FAIL: dyn_arr.shuffle() changed the elements");
            fail_count++;
        end

        // Test find() with with-clause
        dyn_arr = '{1, 5, 2, 5, 3};
        begin
            int found_q[$];
            found_q = dyn_arr.find() with (item == 5);
            if (found_q.size() == 2) begin
                $display("PASS: dyn_arr.find() with item==5 found %0d elements", found_q.size());
                pass_count++;
            end else begin
                $display("FAIL: dyn_arr.find() with item==5 expected 2, got %0d", found_q.size());
                fail_count++;
            end
        end

        // Test find_index() with with-clause
        begin
            int idx_q[$];
            idx_q = dyn_arr.find_index() with (item > 2);
            // Locator methods traverse the array in an unspecified order (7.12.1)
            idx_q.sort();
            if (idx_q.size() == 3 && idx_q[0] == 1 && idx_q[1] == 3 && idx_q[2] == 4) begin
                $display("PASS: dyn_arr.find_index() with item>2 found %0d indices", idx_q.size());
                pass_count++;
            end else begin
                $display("FAIL: dyn_arr.find_index() with item>2 found %0d indices", idx_q.size());
                fail_count++;
            end
        end

        // Test find_first()
        begin
            int first_q[$];
            first_q = dyn_arr.find_first() with (item > 3);
            if (first_q.size() > 0 && first_q[0] == 5) begin
                $display("PASS: dyn_arr.find_first() with item>3 = %0d", first_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn_arr.find_first() with item>3");
                fail_count++;
            end
        end

        // Test find_first_index()
        begin
            int idx_q[$];
            idx_q = dyn_arr.find_first_index() with (item == 5);
            if (idx_q.size() > 0 && idx_q[0] == 1) begin
                $display("PASS: dyn_arr.find_first_index() with item==5 = %0d", idx_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn_arr.find_first_index()");
                fail_count++;
            end
        end

        // Test find_last()
        begin
            int last_q[$];
            last_q = dyn_arr.find_last() with (item == 5);
            if (last_q.size() > 0 && last_q[0] == 5) begin
                $display("PASS: dyn_arr.find_last() with item==5 = %0d", last_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn_arr.find_last()");
                fail_count++;
            end
        end

        // Test find_last_index()
        begin
            int idx_q[$];
            idx_q = dyn_arr.find_last_index() with (item == 5);
            if (idx_q.size() > 0 && idx_q[0] == 3) begin
                $display("PASS: dyn_arr.find_last_index() with item==5 = %0d", idx_q[0]);
                pass_count++;
            end else begin
                $display("FAIL: dyn_arr.find_last_index()");
                fail_count++;
            end
        end

        // Test unique()
        dyn_arr = '{1, 2, 1, 3, 2, 4, 1};
        begin
            int uniq_q[$];
            uniq_q = dyn_arr.unique();
            if (uniq_q.size() == 4) begin
                $display("PASS: dyn_arr.unique() = %0d unique elements", uniq_q.size());
                pass_count++;
            end else begin
                $display("FAIL: dyn_arr.unique() expected 4, got %0d", uniq_q.size());
                fail_count++;
            end
        end

        // Test unique_index()
        begin
            int idx_q[$];
            idx_q = dyn_arr.unique_index();
            if (idx_q.size() == 4) begin
                $display("PASS: dyn_arr.unique_index() = %0d unique indices", idx_q.size());
                pass_count++;
            end else begin
                $display("FAIL: dyn_arr.unique_index() expected 4, got %0d", idx_q.size());
                fail_count++;
            end
        end

        // Summary
        $display("\n=== Array Methods Test Summary ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
