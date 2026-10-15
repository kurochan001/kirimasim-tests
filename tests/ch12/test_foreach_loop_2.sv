/*
:name: test_foreach_loop_2
:description: Test: foreach loop over arrays
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_loop_2.expected
*/
// Test: foreach loop over arrays

module test_foreach_loop_2;
    int pass_count = 0;
    int total_tests = 10;

    // Test variables
    int fixed_arr[5];
    int dyn_arr[];
    int assoc_arr[string];
    int queue_arr[$];
    int multi_arr[3][4];
    logic [7:0] packed_arr[4];
    int sum;
    int count;

    initial begin
        fixed_arr = '{1, 2, 3, 4, 5};
        sum = 0;
        foreach (fixed_arr[i]) begin
            sum += fixed_arr[i];
        end
        if (sum == 15) pass_count++;

        // Test 2: foreach with index usage
        count = 0;
        foreach (fixed_arr[i]) begin
            if (fixed_arr[i] == i + 1) count++;
        end
        if (count == 5) pass_count++;

        // Test 3: foreach over dynamic array
        dyn_arr = new[4];
        dyn_arr = '{10, 20, 30, 40};
        sum = 0;
        foreach (dyn_arr[i]) begin
            sum += dyn_arr[i];
        end
        if (sum == 100) pass_count++;

        // Test 4: foreach over queue
        queue_arr = '{100, 200, 300};
        sum = 0;
        foreach (queue_arr[i]) begin
            sum += queue_arr[i];
        end
        if (sum == 600) pass_count++;

        // Test 5: foreach over associative array
        assoc_arr["a"] = 1;
        assoc_arr["b"] = 2;
        assoc_arr["c"] = 3;
        sum = 0;
        foreach (assoc_arr[key]) begin
            sum += assoc_arr[key];
        end
        if (sum == 6) pass_count++;

        // Test 6: foreach over multi-dimensional array
        foreach (multi_arr[i, j]) begin
            multi_arr[i][j] = i * 10 + j;
        end
        if (multi_arr[0][0] == 0 && multi_arr[2][3] == 23) pass_count++;

        // Test 7: foreach with modification
        foreach (fixed_arr[i]) begin
            fixed_arr[i] = fixed_arr[i] * 2;
        end
        sum = 0;
        foreach (fixed_arr[i]) begin
            sum += fixed_arr[i];
        end
        if (sum == 30) pass_count++;  // 2+4+6+8+10 = 30

        // Test 8: foreach over packed array elements
        packed_arr = '{8'hAA, 8'hBB, 8'hCC, 8'hDD};
        sum = 0;
        foreach (packed_arr[i]) begin
            sum += packed_arr[i];
        end
        // 0xAA + 0xBB + 0xCC + 0xDD = 170 + 187 + 204 + 221 = 782
        if (sum == 782) pass_count++;

        // Test 9: foreach with conditional
        fixed_arr = '{1, 2, 3, 4, 5};
        sum = 0;
        foreach (fixed_arr[i]) begin
            if (fixed_arr[i] % 2 == 0) begin
                sum += fixed_arr[i];
            end
        end
        if (sum == 6) pass_count++;  // 2 + 4 = 6

        // Test 10: foreach with early exit (break)
        sum = 0;
        foreach (fixed_arr[i]) begin
            sum += fixed_arr[i];
            if (sum >= 6) break;
        end
        if (sum >= 6) pass_count++;

        if (pass_count == total_tests) $display("PASS: foreach_loop (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: foreach_loop (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
