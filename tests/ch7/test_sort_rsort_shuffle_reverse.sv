/*
:name: test_sort_rsort_shuffle_reverse
:description: , §7.10: Array manipulation methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sort_rsort_shuffle_reverse.expected
*/
// IEEE 1800-2023 §7.5, §7.10: Array manipulation methods
// Tests sort, rsort, shuffle, reverse for queues and dynamic arrays

module test_sort_rsort_shuffle_reverse;
    // Test queues
    int queue_a[$];

    // Test dynamic arrays
    int dyn_arr[];

    int pass_count = 0;
    int fail_count = 0;

    // Helper function to check if queue is sorted ascending
    function bit is_sorted_asc(int q[$]);
        for (int i = 1; i < q.size(); i++) begin
            if (q[i] < q[i-1]) return 0;
        end
        return 1;
    endfunction

    // Helper function to check if queue is sorted descending
    function bit is_sorted_desc(int q[$]);
        for (int i = 1; i < q.size(); i++) begin
            if (q[i] > q[i-1]) return 0;
        end
        return 1;
    endfunction

    initial begin
        // Initialize
        queue_a = '{3, 1, 4, 1, 5, 9, 2, 6};
        dyn_arr = new[8];
        dyn_arr = '{3, 1, 4, 1, 5, 9, 2, 6};

        // Test 1: Queue sort (ascending)
        queue_a = '{3, 1, 4, 1, 5, 9, 2, 6};
        queue_a.sort();
        if (is_sorted_asc(queue_a) && queue_a[0] == 1 && queue_a[7] == 9) begin
            $display("PASS: Test 1 - Queue sort");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Queue sort");
            $display("  First: %0d, Last: %0d", queue_a[0], queue_a[7]);
            fail_count++;
        end

        // Test 2: Queue rsort (descending)
        queue_a = '{3, 1, 4, 1, 5, 9, 2, 6};
        queue_a.rsort();
        if (is_sorted_desc(queue_a) && queue_a[0] == 9 && queue_a[7] == 1) begin
            $display("PASS: Test 2 - Queue rsort");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Queue rsort");
            $display("  First: %0d, Last: %0d", queue_a[0], queue_a[7]);
            fail_count++;
        end

        // Test 3: Queue reverse
        queue_a = '{1, 2, 3, 4, 5};
        queue_a.reverse();
        if (queue_a[0] == 5 && queue_a[1] == 4 && queue_a[2] == 3 &&
            queue_a[3] == 2 && queue_a[4] == 1) begin
            $display("PASS: Test 3 - Queue reverse");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Queue reverse");
            $display("  Got: %0d, %0d, %0d, %0d, %0d",
                     queue_a[0], queue_a[1], queue_a[2], queue_a[3], queue_a[4]);
            fail_count++;
        end

        // Test 4: Queue shuffle (just verify it runs and has same elements)
        queue_a = '{1, 2, 3, 4, 5, 6, 7, 8};
        queue_a.shuffle();
        begin
            static int sum = 0;
            foreach (queue_a[i]) sum += queue_a[i];
            if (sum == 36 && queue_a.size() == 8) begin
                $display("PASS: Test 4 - Queue shuffle (elements preserved)");
                pass_count++;
            end else begin
                $display("FAIL: Test 4 - Queue shuffle");
                $display("  Sum: %0d (expected 36), Size: %0d", sum, queue_a.size());
                fail_count++;
            end
        end

        // Test 5: Dynamic array sort
        dyn_arr = '{3, 1, 4, 1, 5, 9, 2, 6};
        dyn_arr.sort();
        if (dyn_arr[0] == 1 && dyn_arr[7] == 9) begin
            $display("PASS: Test 5 - Dynamic array sort");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Dynamic array sort");
            $display("  First: %0d, Last: %0d", dyn_arr[0], dyn_arr[7]);
            fail_count++;
        end

        // Test 6: Dynamic array rsort
        dyn_arr = '{3, 1, 4, 1, 5, 9, 2, 6};
        dyn_arr.rsort();
        if (dyn_arr[0] == 9 && dyn_arr[7] == 1) begin
            $display("PASS: Test 6 - Dynamic array rsort");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - Dynamic array rsort");
            $display("  First: %0d, Last: %0d", dyn_arr[0], dyn_arr[7]);
            fail_count++;
        end

        // Test 7: Dynamic array reverse
        dyn_arr = '{1, 2, 3, 4, 5};
        dyn_arr.reverse();
        if (dyn_arr[0] == 5 && dyn_arr[1] == 4 && dyn_arr[2] == 3 &&
            dyn_arr[3] == 2 && dyn_arr[4] == 1) begin
            $display("PASS: Test 7 - Dynamic array reverse");
            pass_count++;
        end else begin
            $display("FAIL: Test 7 - Dynamic array reverse");
            fail_count++;
        end

        // Test 8: Dynamic array shuffle
        dyn_arr = '{1, 2, 3, 4, 5, 6, 7, 8};
        dyn_arr.shuffle();
        begin
            static int sum = 0;
            foreach (dyn_arr[i]) sum += dyn_arr[i];
            if (sum == 36 && dyn_arr.size() == 8) begin
                $display("PASS: Test 8 - Dynamic array shuffle");
                pass_count++;
            end else begin
                $display("FAIL: Test 8 - Dynamic array shuffle");
                fail_count++;
            end
        end

        // Summary
        $display("\n=== Test Summary ===");
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);

        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end
endmodule
