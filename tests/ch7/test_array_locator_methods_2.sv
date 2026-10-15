/*
:name: test_array_locator_methods_2
:description: Test for array locator methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_locator_methods_2.expected
*/
// Test for array locator methods
// IEEE 1800-2023 §7.12

module test_array_locator_methods_2;
    int arr[$] = '{3, 1, 4, 1, 5, 9, 2, 6};
    int found[$];
    int idx[$];
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: find
        test_count++;
        found = arr.find with (item > 5);
        // Locator methods traverse the array in an unspecified order (7.12.1)
        found.sort();
        if (found.size() == 2 && found[0] == 6 && found[1] == 9) begin
            $display("Test 1: find > 5 found %0d elements PASS", found.size());
            pass_count++;
        end else begin
            $display("Test 1: find > 5 found %0d elements FAIL", found.size());
        end

        // Test 2: find_first
        test_count++;
        found = arr.find_first with (item > 5);
        if (found.size() == 1 && found[0] == 9) begin
            $display("Test 2: find_first > 5 = %0d PASS", found[0]);
            pass_count++;
        end else begin
            $display("Test 2: find_first > 5 FAIL");
        end

        // Test 3: find_last
        test_count++;
        found = arr.find_last with (item > 5);
        if (found.size() == 1 && found[0] == 6) begin
            $display("Test 3: find_last > 5 = %0d PASS", found[0]);
            pass_count++;
        end else begin
            $display("Test 3: find_last > 5 FAIL");
        end

        // Test 4: find_index
        test_count++;
        idx = arr.find_index with (item == 4);
        if (idx.size() == 1 && idx[0] == 2) begin
            $display("Test 4: find_index(4) = %0d PASS", idx[0]);
            pass_count++;
        end else begin
            $display("Test 4: find_index(4) FAIL");
        end

        // Test 5: find_first_index
        test_count++;
        idx = arr.find_first_index with (item == 1);
        if (idx.size() == 1 && idx[0] == 1) begin
            $display("Test 5: find_first_index(1) = %0d PASS", idx[0]);
            pass_count++;
        end else begin
            $display("Test 5: find_first_index(1) FAIL");
        end

        // Test 6: find_last_index
        test_count++;
        idx = arr.find_last_index with (item == 1);
        if (idx.size() == 1 && idx[0] == 3) begin
            $display("Test 6: find_last_index(1) = %0d PASS", idx[0]);
            pass_count++;
        end else begin
            $display("Test 6: find_last_index(1) FAIL");
        end

        // Test 7: unique
        test_count++;
        found = arr.unique;
        // 7 distinct values: 3, 1, 4, 5, 9, 2, 6
        if (found.size() == 7) begin
            $display("Test 7: unique() size = %0d PASS", found.size());
            pass_count++;
        end else begin
            $display("Test 7: unique() size = %0d FAIL", found.size());
        end

        // Test 8: unique_index
        test_count++;
        idx = arr.unique_index;
        // 7 distinct values: 3, 1, 4, 5, 9, 2, 6
        if (idx.size() == 7) begin
            $display("Test 8: unique_index() size = %0d PASS", idx.size());
            pass_count++;
        end else begin
            $display("Test 8: unique_index() size = %0d FAIL", idx.size());
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
