/*
:name: test_memory_array_ops
:description: Tests various memory and array operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4 7.5 7.8 7.10 7.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_memory_array_ops.expected
*/
// Tests various memory and array operations
`timescale 1ns/1ps

module test_memory_array_ops;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Memory declaration and access
    task test_memory_access();
        logic [7:0] mem [0:15];
        int i;

        // Initialize memory
        for (i = 0; i < 16; i++) begin
            mem[i] = i * 16;
        end

        if (mem[0] == 0 && mem[15] == 240) begin
            $display("PASS: Memory access works");
            pass_count++;
        end else begin
            $display("FAIL: Memory access failed");
            fail_count++;
        end
    endtask

    // Test 2: Multi-dimensional array
    task test_multidim_array();
        int arr[4][4];
        int i, j;

        for (i = 0; i < 4; i++) begin
            for (j = 0; j < 4; j++) begin
                arr[i][j] = i * 4 + j;
            end
        end

        if (arr[0][0] == 0 && arr[3][3] == 15) begin
            $display("PASS: Multi-dimensional array works");
            pass_count++;
        end else begin
            $display("FAIL: Multi-dimensional array failed");
            fail_count++;
        end
    endtask

    // Test 3: Dynamic array
    task test_dynamic_array();
        int dyn[];

        dyn = new[10];

        for (int i = 0; i < 10; i++) begin
            dyn[i] = i * 2;
        end

        if (dyn.size() == 10 && dyn[5] == 10) begin
            $display("PASS: Dynamic array works");
            pass_count++;
        end else begin
            $display("FAIL: Dynamic array failed");
            fail_count++;
        end
    endtask

    // Test 4: Dynamic array resize
    task test_dynamic_resize();
        int dyn[];

        dyn = new[5];
        dyn[0] = 100;
        dyn[4] = 400;

        dyn = new[10](dyn);  // Resize preserving old values

        if (dyn.size() == 10 && dyn[0] == 100 && dyn[4] == 400) begin
            $display("PASS: Dynamic array resize works");
            pass_count++;
        end else begin
            $display("FAIL: Dynamic resize (size=%0d)", dyn.size());
            fail_count++;
        end
    endtask

    // Test 5: Associative array with int key
    task test_assoc_int_key();
        int assoc[int];

        assoc[1] = 100;
        assoc[100] = 200;
        assoc[1000] = 300;

        if (assoc.size() == 3 && assoc[100] == 200) begin
            $display("PASS: Associative array (int key) works");
            pass_count++;
        end else begin
            $display("FAIL: Associative array (int) failed");
            fail_count++;
        end
    endtask

    // Test 6: Associative array with string key
    task test_assoc_string_key();
        int assoc[string];

        assoc["alpha"] = 1;
        assoc["beta"] = 2;
        assoc["gamma"] = 3;

        if (assoc.size() == 3 && assoc["beta"] == 2) begin
            $display("PASS: Associative array (string key) works");
            pass_count++;
        end else begin
            $display("FAIL: Associative array (string) failed");
            fail_count++;
        end
    endtask

    // Test 7: Queue basic operations
    task test_queue_basic();
        int q[$];

        q.push_back(10);
        q.push_back(20);
        q.push_back(30);

        if (q.size() == 3 && q[1] == 20) begin
            $display("PASS: Queue basic operations work");
            pass_count++;
        end else begin
            $display("FAIL: Queue basic failed");
            fail_count++;
        end
    endtask

    // Test 8: Queue push/pop front
    task test_queue_front();
        int q[$];
        int val;

        q.push_front(30);
        q.push_front(20);
        q.push_front(10);

        val = q.pop_front();

        if (val == 10 && q.size() == 2) begin
            $display("PASS: Queue front operations work");
            pass_count++;
        end else begin
            $display("FAIL: Queue front failed");
            fail_count++;
        end
    endtask

    // Test 9: Queue insert/delete
    task test_queue_insert_delete();
        int q[$];
        q.push_back(1); q.push_back(2); q.push_back(4); q.push_back(5);

        q.insert(2, 3);  // Insert 3 at position 2

        if (q.size() == 5 && q[2] == 3) begin
            $display("PASS: Queue insert works");
            pass_count++;
        end else begin
            $display("FAIL: Queue insert failed");
            fail_count++;
        end

        q.delete(2);  // Delete element at position 2

        if (q.size() == 4 && q[2] == 4) begin
            $display("PASS: Queue delete works");
            pass_count++;
        end else begin
            $display("FAIL: Queue delete failed");
            fail_count++;
        end
    endtask

    // Test 10: Array locator methods - find
    task test_array_find();
        static int arr[] = '{1, 2, 3, 4, 5, 6};
        int result[$];

        result = arr.find with (item > 3);

        if (result.size() == 3) begin
            $display("PASS: Array find works");
            pass_count++;
        end else begin
            $display("FAIL: Array find (size=%0d)", result.size());
            fail_count++;
        end
    endtask

    // Test 11: Array locator - find_first/find_last
    task test_array_find_first_last();
        static int arr[] = '{5, 2, 8, 2, 9};
        int result[$];

        result = arr.find_first with (item == 2);

        if (result.size() == 1 && result[0] == 2) begin
            $display("PASS: Array find_first works");
            pass_count++;
        end else begin
            $display("FAIL: Array find_first (size=%0d)", result.size());
            fail_count++;
        end
    endtask

    // Test 12: Array reduction - sum
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

    // Test 13: Array reduction - product
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

    // Test 14: Array ordering - sort
    task test_array_sort();
        static int arr[] = '{5, 2, 8, 1, 9};

        arr.sort();

        if (arr[0] == 1 && arr[4] == 9) begin
            $display("PASS: Array sort works");
            pass_count++;
        end else begin
            $display("FAIL: Array sort failed");
            fail_count++;
        end
    endtask

    // Test 15: Array ordering - rsort
    task test_array_rsort();
        static int arr[] = '{5, 2, 8, 1, 9};

        arr.rsort();

        if (arr[0] == 9 && arr[4] == 1) begin
            $display("PASS: Array rsort works");
            pass_count++;
        end else begin
            $display("FAIL: Array rsort failed");
            fail_count++;
        end
    endtask

    // Test 16: Array shuffle
    task test_array_shuffle();
        static int arr[] = '{1, 2, 3, 4, 5};
        int orig_sum, new_sum;

        orig_sum = arr.sum();
        arr.shuffle();
        new_sum = arr.sum();

        if (orig_sum == new_sum) begin
            $display("PASS: Array shuffle preserves elements");
            pass_count++;
        end else begin
            $display("FAIL: Array shuffle modified sum");
            fail_count++;
        end
    endtask

    // Test 17: Array reverse
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

    // Test 18: Array min/max
    task test_array_min_max();
        static int arr[] = '{5, 2, 8, 1, 9};
        int result[$];

        result = arr.min();
        if (result.size() > 0 && result[0] == 1) begin
            $display("PASS: Array min works");
            pass_count++;
        end else begin
            $display("FAIL: Array min test");
            fail_count++;
        end

        result = arr.max();
        if (result.size() > 0 && result[0] == 9) begin
            $display("PASS: Array max works");
            pass_count++;
        end else begin
            $display("FAIL: Array max test");
            fail_count++;
        end
    endtask

    // Test 19: Array unique
    task test_array_unique();
        static int arr[] = '{1, 2, 2, 3, 3, 3, 4};
        int result[$];

        result = arr.unique();

        if (result.size() == 4) begin
            $display("PASS: Array unique works");
            pass_count++;
        end else begin
            $display("FAIL: Array unique (size=%0d)", result.size());
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Memory and Array Operations Test ===");

        test_memory_access();
        test_multidim_array();
        test_dynamic_array();
        test_dynamic_resize();
        test_assoc_int_key();
        test_assoc_string_key();
        test_queue_basic();
        test_queue_front();
        test_queue_insert_delete();
        test_array_find();
        test_array_find_first_last();
        test_array_sum();
        test_array_product();
        test_array_sort();
        test_array_rsort();
        test_array_shuffle();
        test_array_reverse();
        test_array_min_max();
        test_array_unique();

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
