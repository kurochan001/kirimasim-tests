/*
:name: test_array_locator_methods
:description: Array Locator Methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_locator_methods.expected
*/
// IEEE 1800-2023 §7.12 Array Locator Methods
// Tests find, find_index, find_first, find_last, unique, unique_index

module test_array_locator_methods;
    int arr[] = '{10, 20, 30, 20, 40, 20};
    int queue_result[$];
    int index_result[$];
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: find() - returns all matching elements
        queue_result = arr.find(x) with (x == 20);
        if (queue_result.size() == 3 &&
            queue_result[0] == 20 && queue_result[1] == 20 && queue_result[2] == 20) begin
            $display("PASS: find() with (x == 20) returned 3 elements");
            pass_count++;
        end else begin
            $display("FAIL: find() with (x == 20) - got size=%0d", queue_result.size());
            fail_count++;
        end

        // Test 2: find_index() - returns indices of matching elements
        index_result = arr.find_index(x) with (x == 20);
        if (index_result.size() == 3 &&
            index_result[0] == 1 && index_result[1] == 3 && index_result[2] == 5) begin
            $display("PASS: find_index() returned indices {1, 3, 5}");
            pass_count++;
        end else begin
            $display("FAIL: find_index() - got size=%0d", index_result.size());
            fail_count++;
        end

        // Test 3: find_first() - returns first matching element
        queue_result = arr.find_first(x) with (x > 25);
        if (queue_result.size() == 1 && queue_result[0] == 30) begin
            $display("PASS: find_first() with (x > 25) returned 30");
            pass_count++;
        end else begin
            $display("FAIL: find_first() - got size=%0d", queue_result.size());
            fail_count++;
        end

        // Test 4: find_first_index() - returns index of first match
        index_result = arr.find_first_index(x) with (x > 25);
        if (index_result.size() == 1 && index_result[0] == 2) begin
            $display("PASS: find_first_index() returned index 2");
            pass_count++;
        end else begin
            $display("FAIL: find_first_index() - got size=%0d", index_result.size());
            fail_count++;
        end

        // Test 5: find_last() - returns last matching element
        queue_result = arr.find_last(x) with (x == 20);
        if (queue_result.size() == 1 && queue_result[0] == 20) begin
            $display("PASS: find_last() with (x == 20) returned 20");
            pass_count++;
        end else begin
            $display("FAIL: find_last() - got size=%0d", queue_result.size());
            fail_count++;
        end

        // Test 6: find_last_index() - returns index of last match
        index_result = arr.find_last_index(x) with (x == 20);
        if (index_result.size() == 1 && index_result[0] == 5) begin
            $display("PASS: find_last_index() returned index 5");
            pass_count++;
        end else begin
            $display("FAIL: find_last_index() - got size=%0d", index_result.size());
            fail_count++;
        end

        // Test 7: unique() - returns queue of unique values
        queue_result = arr.unique();
        if (queue_result.size() == 4) begin
            $display("PASS: unique() returned 4 unique values");
            pass_count++;
        end else begin
            $display("FAIL: unique() - got size=%0d, expected 4", queue_result.size());
            fail_count++;
        end

        // Test 8: unique_index() - returns indices of first occurrence
        index_result = arr.unique_index();
        if (index_result.size() == 4) begin
            $display("PASS: unique_index() returned 4 indices");
            pass_count++;
        end else begin
            $display("FAIL: unique_index() - got size=%0d", index_result.size());
            fail_count++;
        end

        // Test 9: find with no matches - should return empty queue
        queue_result = arr.find(x) with (x == 999);
        if (queue_result.size() == 0) begin
            $display("PASS: find() with no matches returned empty queue");
            pass_count++;
        end else begin
            $display("FAIL: find() with no matches - got size=%0d", queue_result.size());
            fail_count++;
        end

        $display("");
        $display("=== Array Locator Methods Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
