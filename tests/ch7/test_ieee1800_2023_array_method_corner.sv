/*
:name: test_ieee1800_2023_array_method_corner
:description: Array Manipulation Methods Corner Cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 7.12.1 7.12.2 7.12.3 7.10.2 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ieee1800_2023_array_method_corner.expected
*/
// IEEE 1800-2023 §7.12 Array Manipulation Methods Corner Cases
// Tests edge cases in array manipulation methods

module test_ieee1800_2023_array_method_corner;
    int test_count = 0;
    int pass_count = 0;

    // Test 1: Empty dynamic array size
    task test_empty_array_size();
        int arr[];
        test_count++;
        if (arr.size() == 0) begin
            pass_count++;
            $display("PASS: Test 1 - Empty dynamic array size");
        end else begin
            $display("FAIL: Test 1 - Expected size 0, got %0d", arr.size());
        end
    endtask

    // Test 2: Delete on dynamic array via new[0]
    task test_delete_array();
        static int arr[] = '{1, 2, 3, 4, 5};
        test_count++;
        arr = new[0];  // Resize to 0 to clear
        if (arr.size() == 0) begin
            pass_count++;
            $display("PASS: Test 2 - Delete dynamic array via new[0]");
        end else begin
            $display("FAIL: Test 2 - After delete size=%0d", arr.size());
        end
    endtask

    // Test 3: Reverse array
    task test_reverse_array();
        static int arr[] = '{1, 2, 3, 4, 5};
        test_count++;
        arr.reverse();
        if (arr[0] == 5 && arr[4] == 1) begin
            pass_count++;
            $display("PASS: Test 3 - Reverse array");
        end else begin
            $display("FAIL: Test 3 - Reverse arr[0]=%0d, arr[4]=%0d", arr[0], arr[4]);
        end
    endtask

    // Test 4: Sort ascending
    task test_sort_ascending();
        static int arr[] = '{5, 2, 8, 1, 9};
        test_count++;
        arr.sort();
        if (arr[0] == 1 && arr[4] == 9) begin
            pass_count++;
            $display("PASS: Test 4 - Sort ascending");
        end else begin
            $display("FAIL: Test 4 - Sort arr[0]=%0d, arr[4]=%0d", arr[0], arr[4]);
        end
    endtask

    // Test 5: Rsort (descending)
    task test_rsort_descending();
        static int arr[] = '{5, 2, 8, 1, 9};
        test_count++;
        arr.rsort();
        if (arr[0] == 9 && arr[4] == 1) begin
            pass_count++;
            $display("PASS: Test 5 - Rsort descending");
        end else begin
            $display("FAIL: Test 5 - Rsort arr[0]=%0d, arr[4]=%0d", arr[0], arr[4]);
        end
    endtask

    // Test 6: Shuffle array
    task test_shuffle_array();
        static int arr[] = '{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
        int original_sum;
        int shuffled_sum;
        test_count++;
        original_sum = arr.sum();
        arr.shuffle();
        shuffled_sum = arr.sum();
        // Sum should be same, but order likely different
        if (shuffled_sum == original_sum) begin
            pass_count++;
            $display("PASS: Test 6 - Shuffle array (sum preserved)");
        end else begin
            $display("FAIL: Test 6 - Shuffle sum changed from %0d to %0d", original_sum, shuffled_sum);
        end
    endtask

    // Test 7: Sum method
    task test_sum_method();
        static int arr[] = '{1, 2, 3, 4, 5};
        int sum;
        test_count++;
        sum = arr.sum();
        if (sum == 15) begin
            pass_count++;
            $display("PASS: Test 7 - Sum method");
        end else begin
            $display("FAIL: Test 7 - Sum expected 15, got %0d", sum);
        end
    endtask

    // Test 8: Product method
    task test_product_method();
        static int arr[] = '{1, 2, 3, 4, 5};
        int prod;
        test_count++;
        prod = arr.product();
        if (prod == 120) begin
            pass_count++;
            $display("PASS: Test 8 - Product method");
        end else begin
            $display("FAIL: Test 8 - Product expected 120, got %0d", prod);
        end
    endtask

    // Test 9: And reduction
    task test_and_reduction();
        static bit [7:0] arr[] = '{8'hFF, 8'hF0, 8'h0F};
        bit [7:0] result;
        test_count++;
        result = arr.and();
        if (result == 8'h00) begin
            pass_count++;
            $display("PASS: Test 9 - And reduction");
        end else begin
            $display("FAIL: Test 9 - And expected 00, got %h", result);
        end
    endtask

    // Test 10: Or reduction
    task test_or_reduction();
        static bit [7:0] arr[] = '{8'h01, 8'h02, 8'h04};
        bit [7:0] result;
        test_count++;
        result = arr.or();
        if (result == 8'h07) begin
            pass_count++;
            $display("PASS: Test 10 - Or reduction");
        end else begin
            $display("FAIL: Test 10 - Or expected 07, got %h", result);
        end
    endtask

    // Test 11: Xor reduction
    task test_xor_reduction();
        static bit [7:0] arr[] = '{8'hFF, 8'hFF, 8'h00};
        bit [7:0] result;
        test_count++;
        result = arr.xor();
        if (result == 8'h00) begin
            pass_count++;
            $display("PASS: Test 11 - Xor reduction");
        end else begin
            $display("FAIL: Test 11 - Xor expected 00, got %h", result);
        end
    endtask

    // Test 12: Min method
    task test_min_method();
        static int arr[] = '{5, 2, 8, 1, 9};
        int result[];
        test_count++;
        result = arr.min();
        if (result.size() == 1 && result[0] == 1) begin
            pass_count++;
            $display("PASS: Test 12 - Min method");
        end else begin
            $display("FAIL: Test 12 - Min expected 1, got size=%0d", result.size());
        end
    endtask

    // Test 13: Max method
    task test_max_method();
        static int arr[] = '{5, 2, 8, 1, 9};
        int result[];
        test_count++;
        result = arr.max();
        if (result.size() == 1 && result[0] == 9) begin
            pass_count++;
            $display("PASS: Test 13 - Max method");
        end else begin
            $display("FAIL: Test 13 - Max expected 9, got size=%0d", result.size());
        end
    endtask

    // Test 14: Unique method
    task test_unique_method();
        static int arr[] = '{1, 2, 2, 3, 3, 3, 4};
        int result[];
        test_count++;
        result = arr.unique();
        if (result.size() == 4) begin
            pass_count++;
            $display("PASS: Test 14 - Unique method (size=%0d)", result.size());
        end else begin
            $display("FAIL: Test 14 - Unique expected size 4, got %0d", result.size());
        end
    endtask

    // Test 15: Find method
    task test_find_method();
        static int arr[] = '{1, 5, 2, 8, 3};
        int result[];
        test_count++;
        result = arr.find(x) with (x > 4);
        if (result.size() == 2) begin  // 5 and 8
            pass_count++;
            $display("PASS: Test 15 - Find method (found %0d elements)", result.size());
        end else begin
            $display("FAIL: Test 15 - Find expected 2 elements, got %0d", result.size());
        end
    endtask

    // Test 16: Find_index method
    task test_find_index_method();
        static int arr[] = '{1, 5, 2, 8, 3};
        int result[];
        test_count++;
        result = arr.find_index(x) with (x > 4);
        // Locator methods traverse the array in an unspecified order (7.12.1)
        result.sort();
        if (result.size() == 2 && result[0] == 1 && result[1] == 3) begin  // indices of 5 and 8
            pass_count++;
            $display("PASS: Test 16 - Find_index method");
        end else begin
            $display("FAIL: Test 16 - Find_index got size=%0d", result.size());
        end
    endtask

    // Test 17: Find_first method
    task test_find_first_method();
        static int arr[] = '{1, 5, 2, 8, 3};
        int result[];
        test_count++;
        result = arr.find_first(x) with (x > 4);
        if (result.size() == 1 && result[0] == 5) begin
            pass_count++;
            $display("PASS: Test 17 - Find_first method");
        end else begin
            $display("FAIL: Test 17 - Find_first expected 5");
        end
    endtask

    // Test 18: Find_last method
    task test_find_last_method();
        static int arr[] = '{1, 5, 2, 8, 3};
        int result[];
        test_count++;
        result = arr.find_last(x) with (x > 4);
        if (result.size() == 1 && result[0] == 8) begin
            pass_count++;
            $display("PASS: Test 18 - Find_last method");
        end else begin
            $display("FAIL: Test 18 - Find_last expected 8");
        end
    endtask

    // Test 19: Single element array operations
    task test_single_element();
        static int arr[] = '{42};
        test_count++;
        arr.reverse();
        if (arr.size() == 1 && arr[0] == 42) begin
            pass_count++;
            $display("PASS: Test 19 - Single element reverse");
        end else begin
            $display("FAIL: Test 19 - Single element reverse failed");
        end
    endtask

    // Test 20: Queue pop_front/pop_back
    task test_queue_pop();
        static int q[$] = '{1, 2, 3, 4, 5};
        int front, back;
        test_count++;
        front = q.pop_front();
        back = q.pop_back();
        if (front == 1 && back == 5 && q.size() == 3) begin
            pass_count++;
            $display("PASS: Test 20 - Queue pop_front/pop_back");
        end else begin
            $display("FAIL: Test 20 - Queue pop f=%0d, b=%0d, size=%0d", front, back, q.size());
        end
    endtask

    // Test 21: Queue push_front/push_back
    task test_queue_push();
        int q[$];
        test_count++;
        q.push_back(1);
        q.push_front(0);
        q.push_back(2);
        if (q.size() == 3 && q[0] == 0 && q[1] == 1 && q[2] == 2) begin
            pass_count++;
            $display("PASS: Test 21 - Queue push_front/push_back");
        end else begin
            $display("FAIL: Test 21 - Queue push failed");
        end
    endtask

    // Test 22: Queue insert
    task test_queue_insert();
        static int q[$] = '{1, 3, 4};
        test_count++;
        q.insert(1, 2);  // Insert 2 at index 1
        if (q.size() == 4 && q[0] == 1 && q[1] == 2 && q[2] == 3) begin
            pass_count++;
            $display("PASS: Test 22 - Queue insert");
        end else begin
            $display("FAIL: Test 22 - Queue insert failed");
        end
    endtask

    // Test 23: Associative array exists/delete
    task test_assoc_array();
        int aa[string];
        test_count++;
        aa["one"] = 1;
        aa["two"] = 2;
        if (aa.exists("one") && !aa.exists("three")) begin
            aa.delete("one");
            if (!aa.exists("one") && aa.exists("two")) begin
                pass_count++;
                $display("PASS: Test 23 - Associative array exists/delete");
            end else begin
                $display("FAIL: Test 23 - Associative array delete failed");
            end
        end else begin
            $display("FAIL: Test 23 - Associative array exists failed");
        end
    endtask

    // Test 24: Associative array first/next
    task test_assoc_first_next();
        int aa[int];
        int key;
        static int count = 0;
        test_count++;
        aa[10] = 100;
        aa[20] = 200;
        aa[30] = 300;
        if (aa.first(key)) begin
            do begin
                count++;
            end while (aa.next(key));
        end
        if (count == 3) begin
            pass_count++;
            $display("PASS: Test 24 - Associative array first/next");
        end else begin
            $display("FAIL: Test 24 - first/next count=%0d", count);
        end
    endtask

    // Test 25: Dynamic array resize
    task test_multidim_subarray();
        int arr[];
        int sum;
        test_count++;
        arr = new[5];
        arr = '{1, 2, 3, 4, 5};
        sum = arr.sum();
        if (sum == 15) begin  // 1+2+3+4+5 = 15
            pass_count++;
            $display("PASS: Test 25 - Dynamic array sum after resize");
        end else begin
            $display("FAIL: Test 25 - Array sum expected 15, got %0d", sum);
        end
    endtask

    initial begin
        test_empty_array_size();
        test_delete_array();
        test_reverse_array();
        test_sort_ascending();
        test_rsort_descending();
        test_shuffle_array();
        test_sum_method();
        test_product_method();
        test_and_reduction();
        test_or_reduction();
        test_xor_reduction();
        test_min_method();
        test_max_method();
        test_unique_method();
        test_find_method();
        test_find_index_method();
        test_find_first_method();
        test_find_last_method();
        test_single_element();
        test_queue_pop();
        test_queue_push();
        test_queue_insert();
        test_assoc_array();
        test_assoc_first_next();
        test_multidim_subarray();

        $display("\n=== Array Method Corner Cases Summary ===");
        $display("Tests: %0d/%0d passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
