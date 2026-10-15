/*
:name: test_array_find
:description: Array Locator Methods (§7.12.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_find.expected
*/
// IEEE 1800-2023 Array Locator Methods (§7.12.1)
// Tests find, find_index, find_first, find_last

module test_array_find;
    initial begin
        static int arr[8] = '{10, 25, 5, 30, 15, 25, 40, 20};
        int result[$];
        int idx[$];
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: find - returns all elements matching condition
        result = arr.find(x) with (x > 20);
        // Locator methods traverse the array in an unspecified order (7.12.1)
        result.sort();
        if (result.size() == 4 && result[0] == 25 && result[1] == 25 && result[2] == 30 && result[3] == 40) begin
            $display("PASS: find(x > 20) returned correct elements");
            pass_count++;
        end else begin
            $display("FAIL: find(x > 20) size=%0d, expected 4", result.size());
            fail_count++;
        end

        // Test 2: find_index - returns indices of matching elements
        idx = arr.find_index(x) with (x == 25);
        // Locator methods traverse the array in an unspecified order (7.12.1)
        idx.sort();
        if (idx.size() == 2 && idx[0] == 1 && idx[1] == 5) begin
            $display("PASS: find_index(x == 25) returned correct indices");
            pass_count++;
        end else begin
            $display("FAIL: find_index(x == 25) size=%0d, expected 2", idx.size());
            fail_count++;
        end

        // Test 3: find_first - returns first matching element
        result = arr.find_first(x) with (x > 20);
        if (result.size() == 1 && result[0] == 25) begin
            $display("PASS: find_first(x > 20) returned 25");
            pass_count++;
        end else begin
            $display("FAIL: find_first(x > 20) returned wrong value");
            fail_count++;
        end

        // Test 4: find_last - returns last matching element
        result = arr.find_last(x) with (x > 20);
        if (result.size() == 1 && result[0] == 40) begin
            $display("PASS: find_last(x > 20) returned 40");
            pass_count++;
        end else begin
            $display("FAIL: find_last(x > 20) returned wrong value");
            fail_count++;
        end

        // Test 5: find_first_index
        idx = arr.find_first_index(x) with (x == 5);
        if (idx.size() == 1 && idx[0] == 2) begin
            $display("PASS: find_first_index(x == 5) returned 2");
            pass_count++;
        end else begin
            $display("FAIL: find_first_index(x == 5) returned wrong index");
            fail_count++;
        end

        // Test 6: find_last_index
        idx = arr.find_last_index(x) with (x == 25);
        if (idx.size() == 1 && idx[0] == 5) begin
            $display("PASS: find_last_index(x == 25) returned 5");
            pass_count++;
        end else begin
            $display("FAIL: find_last_index(x == 25) returned wrong index");
            fail_count++;
        end

        // Test 7: No matches
        result = arr.find(x) with (x > 100);
        if (result.size() == 0) begin
            $display("PASS: find(x > 100) returned empty queue");
            pass_count++;
        end else begin
            $display("FAIL: find(x > 100) should be empty");
            fail_count++;
        end

        $display("");
        $display("=== Array Find Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
