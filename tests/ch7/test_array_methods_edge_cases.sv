/*
:name: test_array_methods_edge_cases
:description: Array manipulation methods edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12.1 7.12.2 7.12.3
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_methods_edge_cases.expected
*/
// IEEE 1800-2023 §7.12: Array manipulation methods edge cases
// Tests for array methods: find, sort, reverse, sum, etc.

module test_array_methods_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    int arr[10];
    int result_arr[];
    int dyn_arr[];

    initial begin
        // Initialize
        for (int i = 0; i < 10; i++) arr[i] = i * 10;

        // Test 1: Sum
        test_count++;
        begin
            static int s;
            // Assigned here so the result does not depend on the order of static initializers.
            s = arr.sum();
            if (s == 450) begin
                pass_count++;
                $display("Test 1 PASS: sum = %0d", s);
            end else begin
                $display("Test 1 FAIL: sum unexpected = %0d", s);
            end
        end

        // Test 2: Product
        test_count++;
        begin
            static int arr3[3] = '{1, 2, 3};
            static int p;
            // Assigned here so the result does not depend on the order of static initializers.
            p = arr3.product();
            if (p == 6) begin
                pass_count++;
                $display("Test 2 PASS: product = %0d", p);
            end else begin
                $display("Test 2 FAIL: product unexpected = %0d", p);
            end
        end

        // Test 3: Reverse
        test_count++;
        begin
            static int arr4[4] = '{1, 2, 3, 4};
            arr4.reverse();
            if (arr4[0] == 4 && arr4[3] == 1) begin
                pass_count++;
                $display("Test 3 PASS: reverse [0]=%0d [3]=%0d", arr4[0], arr4[3]);
            end else begin
                $display("Test 3 FAIL: reverse unexpected");
            end
        end

        // Test 4: Sort
        test_count++;
        begin
            static int arr5[5] = '{5, 2, 8, 1, 9};
            arr5.sort();
            if (arr5[0] == 1 && arr5[4] == 9) begin
                pass_count++;
                $display("Test 4 PASS: sort [0]=%0d [4]=%0d", arr5[0], arr5[4]);
            end else begin
                $display("Test 4 FAIL: sort unexpected");
            end
        end

        // Test 5: Rsort
        test_count++;
        begin
            static int arr5[5] = '{5, 2, 8, 1, 9};
            arr5.rsort();
            if (arr5[0] == 9 && arr5[4] == 1) begin
                pass_count++;
                $display("Test 5 PASS: rsort [0]=%0d [4]=%0d", arr5[0], arr5[4]);
            end else begin
                $display("Test 5 FAIL: rsort unexpected");
            end
        end

        // Test 6: Shuffle
        test_count++;
        begin
            static int arr4[4] = '{1, 2, 3, 4};
            arr4.shuffle();
            // The order is random, but the elements stay the same (7.12.2).
            arr4.sort();
            if (arr4[0] == 1 && arr4[1] == 2 && arr4[2] == 3 && arr4[3] == 4) begin
                pass_count++;
                $display("Test 6 PASS: shuffle completed");
            end else begin
                $display("Test 6 FAIL: shuffle lost elements");
            end
        end

        // Test 7: Find
        test_count++;
        begin
            static int arr6[6] = '{10, 20, 30, 40, 50, 60};
            result_arr = arr6.find(x) with (x > 35);
            if (result_arr.size() == 3) begin
                pass_count++;
                $display("Test 7 PASS: find > 35 count = %0d", result_arr.size());
            end else begin
                $display("Test 7 FAIL: find unexpected = %0d", result_arr.size());
            end
        end

        // Test 8: Find index
        test_count++;
        begin
            static int arr5[5] = '{5, 10, 15, 20, 25};
            static int indices[];
            // Assigned here so the result does not depend on the order of static initializers.
            indices = arr5.find_index(x) with (x >= 15);
            if (indices.size() == 3) begin
                pass_count++;
                $display("Test 8 PASS: find_index count = %0d", indices.size());
            end else begin
                $display("Test 8 FAIL: find_index unexpected = %0d", indices.size());
            end
        end

        // Test 9: Find first
        test_count++;
        begin
            static int arr5[5] = '{5, 10, 15, 20, 25};
            result_arr = arr5.find_first(x) with (x > 12);
            if (result_arr.size() > 0 && result_arr[0] == 15) begin
                pass_count++;
                $display("Test 9 PASS: find_first = %0d", result_arr[0]);
            end else begin
                $display("Test 9 FAIL: find_first unexpected");
            end
        end

        // Test 10: Min
        test_count++;
        begin
            static int arr5[5] = '{50, 20, 80, 10, 90};
            result_arr = arr5.min();
            if (result_arr.size() > 0 && result_arr[0] == 10) begin
                pass_count++;
                $display("Test 10 PASS: min = %0d", result_arr[0]);
            end else begin
                $display("Test 10 FAIL: min unexpected");
            end
        end

        // Test 11: Max
        test_count++;
        begin
            static int arr5[5] = '{50, 20, 80, 10, 90};
            result_arr = arr5.max();
            if (result_arr.size() > 0 && result_arr[0] == 90) begin
                pass_count++;
                $display("Test 11 PASS: max = %0d", result_arr[0]);
            end else begin
                $display("Test 11 FAIL: max unexpected");
            end
        end

        // Test 12: Unique
        test_count++;
        begin
            static int arr6[6] = '{1, 2, 2, 3, 3, 3};
            result_arr = arr6.unique();
            if (result_arr.size() == 3) begin
                pass_count++;
                $display("Test 12 PASS: unique count = %0d", result_arr.size());
            end else begin
                $display("Test 12 FAIL: unique unexpected = %0d", result_arr.size());
            end
        end

        $display("=== Array Methods Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
