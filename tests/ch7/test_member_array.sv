/*
:name: test_member_array
:description: Test array method member access (.size, .find, etc.)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1 7.12.3 7.5 7.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_array.expected
*/
// Test array method member access (.size, .find, etc.)
module test_member_array;
    int pass_count = 0;
    int total_tests = 8;

    int dyn_arr[];
    int fixed_arr[5];
    int assoc_arr[string];
    int queue_arr[$];

    int found_indices[$];
    int found_values[$];
    int sum_result;
    int product_result;

    initial begin
        // Initialize arrays
        dyn_arr = new[5];
        for (int i = 0; i < 5; i++) begin
            dyn_arr[i] = (i + 1) * 10;  // 10, 20, 30, 40, 50
            fixed_arr[i] = i * 2;       // 0, 2, 4, 6, 8
        end

        assoc_arr["one"] = 1;
        assoc_arr["two"] = 2;
        assoc_arr["three"] = 3;

        queue_arr.push_back(100);
        queue_arr.push_back(200);
        queue_arr.push_back(300);

        // Test 1: Dynamic array .size()
        if (dyn_arr.size() == 5) begin
            $display("Test 1 PASS: dyn_arr.size() = %0d", dyn_arr.size());
            pass_count++;
        end else begin
            $display("Test 1 FAIL: dyn_arr.size() = %0d, expected 5", dyn_arr.size());
        end

        // Test 2: Queue .size()
        if (queue_arr.size() == 3) begin
            $display("Test 2 PASS: queue_arr.size() = %0d", queue_arr.size());
            pass_count++;
        end else begin
            $display("Test 2 FAIL: queue_arr.size() = %0d, expected 3", queue_arr.size());
        end

        // Test 3: Associative array .size()
        if (assoc_arr.size() == 3) begin
            $display("Test 3 PASS: assoc_arr.size() = %0d", assoc_arr.size());
            pass_count++;
        end else begin
            $display("Test 3 FAIL: assoc_arr.size() = %0d, expected 3", assoc_arr.size());
        end

        // Test 4: .find() method
        found_values = dyn_arr.find(x) with (x > 25);
        if (found_values.size() == 3) begin  // 30, 40, 50
            $display("Test 4 PASS: find(x > 25) found %0d elements", found_values.size());
            pass_count++;
        end else begin
            $display("Test 4 FAIL: find() found %0d elements, expected 3", found_values.size());
        end

        // Test 5: .find_index() method
        found_indices = dyn_arr.find_index(x) with (x == 30);
        if (found_indices.size() == 1 && found_indices[0] == 2) begin
            $display("Test 5 PASS: find_index(x == 30) = %0d", found_indices[0]);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: find_index() result incorrect");
        end

        // Test 6: .sum() method
        sum_result = dyn_arr.sum();  // 10+20+30+40+50 = 150
        if (sum_result == 150) begin
            $display("Test 6 PASS: dyn_arr.sum() = %0d", sum_result);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: sum() = %0d, expected 150", sum_result);
        end

        // Test 7: .min() and .max() methods
        begin
            int min_val[$], max_val[$];
            min_val = dyn_arr.min();
            max_val = dyn_arr.max();
            if (min_val[0] == 10 && max_val[0] == 50) begin
                $display("Test 7 PASS: min=%0d, max=%0d", min_val[0], max_val[0]);
                pass_count++;
            end else begin
                $display("Test 7 FAIL: min=%0d, max=%0d", min_val[0], max_val[0]);
            end
        end

        // Test 8: .unique() method
        begin
            static int dup_arr[] = '{1, 2, 2, 3, 3, 3, 4};
            int unique_vals[$];
            unique_vals = dup_arr.unique();
            if (unique_vals.size() == 4) begin  // 1, 2, 3, 4
                $display("Test 8 PASS: unique() returned %0d elements", unique_vals.size());
                pass_count++;
            end else begin
                $display("Test 8 FAIL: unique() returned %0d elements, expected 4", unique_vals.size());
            end
        end

        if (pass_count == total_tests) $display("PASS: member_array (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: member_array (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
