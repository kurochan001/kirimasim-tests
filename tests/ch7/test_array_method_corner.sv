/*
:name: test_array_method_corner
:description: Tests find, sort, sum, min, max, unique methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.12.1 7.12.2 7.12.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_method_corner.expected
*/
// Tests find, sort, sum, min, max, unique methods
`timescale 1ns/1ps

module test_array_method_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Array sum
    task test_array_sum();
        static int arr[] = '{1, 2, 3, 4, 5};
        int total;

        total = arr.sum();

        if (total == 15) begin
            $display("PASS: Array sum works");
            pass_count++;
        end else begin
            $display("FAIL: Array sum failed (total=%0d)", total);
            fail_count++;
        end
    endtask

    // Test 2: Array product
    task test_array_product();
        static int arr[] = '{1, 2, 3, 4};
        int prod;

        prod = arr.product();

        if (prod == 24) begin
            $display("PASS: Array product works");
            pass_count++;
        end else begin
            $display("FAIL: Array product failed (prod=%0d)", prod);
            fail_count++;
        end
    endtask

    // Test 3: Array min/max
    task test_array_min_max();
        static int arr[] = '{5, 2, 8, 1, 9, 3};
        int min_arr[], max_arr[];

        min_arr = arr.min();
        max_arr = arr.max();

        if (min_arr[0] == 1 && max_arr[0] == 9) begin
            $display("PASS: Array min/max works");
            pass_count++;
        end else begin
            $display("FAIL: Min=%0d, Max=%0d", min_arr[0], max_arr[0]);
            fail_count++;
        end
    endtask

    // Test 4: Array sort
    task test_array_sort();
        static int arr[] = '{5, 2, 8, 1, 9, 3};

        arr.sort();

        if (arr[0] == 1 && arr[5] == 9) begin
            $display("PASS: Array sort works");
            pass_count++;
        end else begin
            $display("FAIL: Array sort failed");
            fail_count++;
        end
    endtask

    // Test 5: Array rsort (reverse sort)
    task test_array_rsort();
        static int arr[] = '{5, 2, 8, 1, 9, 3};

        arr.rsort();

        if (arr[0] == 9 && arr[5] == 1) begin
            $display("PASS: Array rsort works");
            pass_count++;
        end else begin
            $display("FAIL: Array rsort failed");
            fail_count++;
        end
    endtask

    // Test 6: Array reverse
    task test_array_reverse();
        static int arr[] = '{1, 2, 3, 4, 5};

        arr.reverse();

        if (arr[0] == 5 && arr[4] == 1) begin
            $display("PASS: Array reverse works");
            pass_count++;
        end else begin
            $display("FAIL: Array reverse failed");
            fail_count++;
        end
    endtask

    // Test 7: Array shuffle
    task test_array_shuffle();
        static int arr[] = '{1, 2, 3, 4, 5};
        int original_sum;

        original_sum = arr.sum();
        arr.shuffle();

        if (arr.sum() == original_sum) begin
            $display("PASS: Array shuffle preserves elements");
            pass_count++;
        end else begin
            $display("FAIL: Array shuffle changed sum");
            fail_count++;
        end
    endtask

    // Test 8: Array unique
    task test_array_unique();
        static int arr[] = '{1, 2, 2, 3, 3, 3, 4};
        int uniq[];

        uniq = arr.unique();

        if (uniq.size() == 4) begin
            $display("PASS: Array unique works");
            pass_count++;
        end else begin
            $display("FAIL: Unique (size=%0d)", uniq.size());
            fail_count++;
        end
    endtask

    // Test 9: Array find
    task test_array_find();
        static int arr[] = '{10, 20, 30, 40, 50};
        int found[];

        found = arr.find(x) with (x > 25);
        // Locator methods traverse the array in an unspecified order (7.12.1)
        found.sort();

        if (found.size() == 3 && found[0] == 30) begin
            $display("PASS: Array find works");
            pass_count++;
        end else begin
            $display("FAIL: Find (size=%0d)", found.size());
            fail_count++;
        end
    endtask

    // Test 10: Array find_index
    task test_array_find_index();
        static int arr[] = '{10, 20, 30, 40, 50};
        int indices[];

        indices = arr.find_index(x) with (x > 25);
        // Locator methods traverse the array in an unspecified order (7.12.1)
        indices.sort();

        if (indices.size() == 3 && indices[0] == 2) begin
            $display("PASS: Array find_index works");
            pass_count++;
        end else begin
            $display("FAIL: Find_index (size=%0d)", indices.size());
            fail_count++;
        end
    endtask

    // Test 11: Array find_first
    task test_array_find_first();
        static int arr[] = '{10, 20, 30, 40, 50};
        int first[];

        first = arr.find_first(x) with (x > 25);

        if (first.size() == 1 && first[0] == 30) begin
            $display("PASS: Array find_first works");
            pass_count++;
        end else begin
            $display("FAIL: Find_first (result=%0d)", first[0]);
            fail_count++;
        end
    endtask

    // Test 12: Array find_last
    task test_array_find_last();
        static int arr[] = '{10, 20, 30, 40, 50};
        int last[];

        last = arr.find_last(x) with (x < 35);

        if (last.size() == 1 && last[0] == 30) begin
            $display("PASS: Array find_last works");
            pass_count++;
        end else begin
            $display("FAIL: Find_last (result=%0d)", last[0]);
            fail_count++;
        end
    endtask

    // Test 13: Array and/or reduction
    task test_array_reduction();
        static logic [7:0] arr[] = '{8'hFF, 8'hF0, 8'h0F};
        logic [7:0] and_result, or_result, xor_result;

        and_result = arr.and();
        or_result = arr.or();
        xor_result = arr.xor();

        if (and_result == 8'h00 && or_result == 8'hFF) begin
            $display("PASS: Array and/or reduction works");
            pass_count++;
        end else begin
            $display("FAIL: Reduction (and=%h, or=%h)", and_result, or_result);
            fail_count++;
        end
    endtask


    initial begin
        $display("=== Array Method Corner Cases Test ===");

        test_array_sum();
        test_array_product();
        test_array_min_max();
        test_array_sort();
        test_array_rsort();
        test_array_reverse();
        test_array_shuffle();
        test_array_unique();
        test_array_find();
        test_array_find_index();
        test_array_find_first();
        test_array_find_last();
        test_array_reduction();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
