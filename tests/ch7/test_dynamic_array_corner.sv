/*
:name: test_dynamic_array_corner
:description: Tests dynamic array operations, resizing, and methods
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5 7.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_array_corner.expected
*/
// Tests dynamic array operations, resizing, and methods
`timescale 1ns/1ps

module test_dynamic_array_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Basic dynamic array creation
    task test_basic_creation();
        int arr[];

        arr = new[5];
        if (arr.size() == 5) begin
            $display("PASS: Dynamic array created with size 5");
            pass_count++;
        end else begin
            $display("FAIL: Dynamic array size = %0d (expected 5)", arr.size());
            fail_count++;
        end
    endtask

    // Test 2: Array initialization
    task test_initialization();
        int arr[];

        arr = new[4]('{1, 2, 3, 4});
        if (arr[0] == 1 && arr[1] == 2 && arr[2] == 3 && arr[3] == 4) begin
            $display("PASS: Dynamic array initialized correctly");
            pass_count++;
        end else begin
            $display("FAIL: Initialization failed: %p", arr);
            fail_count++;
        end
    endtask

    // Test 3: Resize with preservation
    task test_resize_preserve();
        int arr[];

        arr = new[3]('{10, 20, 30});
        arr = new[5](arr); // Resize preserving old values

        if (arr.size() == 5 && arr[0] == 10 && arr[1] == 20 && arr[2] == 30) begin
            $display("PASS: Resize with preservation works");
            pass_count++;
        end else begin
            $display("FAIL: Resize preservation failed");
            fail_count++;
        end
    endtask

    // Test 4: Resize shrink
    task test_resize_shrink();
        int arr[];

        arr = new[5]('{1, 2, 3, 4, 5});
        arr = new[3](arr); // Shrink

        if (arr.size() == 3 && arr[0] == 1 && arr[1] == 2 && arr[2] == 3) begin
            $display("PASS: Resize shrink works");
            pass_count++;
        end else begin
            $display("FAIL: Resize shrink failed");
            fail_count++;
        end
    endtask

    // Test 5: Delete array
    task test_delete();
        int arr[];

        arr = new[5]('{1, 2, 3, 4, 5});
        arr.delete();

        if (arr.size() == 0) begin
            $display("PASS: Array deleted, size = %0d", arr.size());
            pass_count++;
        end else begin
            $display("FAIL: Delete failed, size = %0d", arr.size());
            fail_count++;
        end
    endtask

    // Test 6: Empty array operations
    task test_empty_array();
        int arr[];
        int size_before;

        size_before = arr.size();
        if (size_before == 0) begin
            $display("PASS: Uninitialized array has size 0");
            pass_count++;
        end else begin
            $display("FAIL: Uninitialized array size = %0d", size_before);
            fail_count++;
        end
    endtask

    // Test 7: Array copy
    task test_array_copy();
        int src[], dst[];

        src = new[4]('{100, 200, 300, 400});
        dst = src; // Shallow copy

        if (dst.size() == 4 && dst[0] == 100 && dst[3] == 400) begin
            $display("PASS: Array copy works");
            pass_count++;
        end else begin
            $display("FAIL: Array copy failed");
            fail_count++;
        end
    endtask

    // Test 8: Array of objects
    class SimpleClass;
        int value;
        function new(int v);
            value = v;
        endfunction
    endclass

    task test_array_of_objects();
        SimpleClass objs[];

        objs = new[3];
        objs[0] = new(10);
        objs[1] = new(20);
        objs[2] = new(30);

        if (objs[0].value == 10 && objs[1].value == 20 && objs[2].value == 30) begin
            $display("PASS: Array of objects works");
            pass_count++;
        end else begin
            $display("FAIL: Array of objects failed");
            fail_count++;
        end
    endtask

    // Test 9: 2D dynamic array
    task test_2d_dynamic();
        int arr[][];

        arr = new[3];
        arr[0] = new[2]('{1, 2});
        arr[1] = new[3]('{3, 4, 5});
        arr[2] = new[1]('{6});

        if (arr.size() == 3 && arr[0].size() == 2 && arr[1].size() == 3 && arr[2].size() == 1) begin
            $display("PASS: 2D dynamic array works");
            pass_count++;
        end else begin
            $display("FAIL: 2D dynamic array failed");
            fail_count++;
        end
    endtask

    // Test 10: Array methods
    task test_array_methods();
        int arr[];
        int sum_val, min_val, max_val;

        arr = new[5]('{5, 2, 8, 1, 9});

        sum_val = arr.sum();
        min_val = arr.min()[0];
        max_val = arr.max()[0];

        if (sum_val == 25 && min_val == 1 && max_val == 9) begin
            $display("PASS: Array methods work: sum=%0d, min=%0d, max=%0d", sum_val, min_val, max_val);
            pass_count++;
        end else begin
            $display("FAIL: Array methods incorrect");
            fail_count++;
        end
    endtask

    // Test 11: Array find methods
    task test_array_find();
        int arr[];
        int found[];

        arr = new[6]('{1, 5, 3, 5, 2, 5});

        found = arr.find with (item == 5);
        if (found.size() == 3) begin
            $display("PASS: find() found %0d elements with value 5", found.size());
            pass_count++;
        end else begin
            $display("FAIL: find() returned %0d elements (expected 3)", found.size());
            fail_count++;
        end
    endtask

    // Test 12: Array sort and reverse
    task test_sort_reverse();
        int arr[];

        arr = new[5]('{3, 1, 4, 1, 5});
        arr.sort();

        if (arr[0] == 1 && arr[1] == 1 && arr[2] == 3 && arr[3] == 4 && arr[4] == 5) begin
            $display("PASS: Array sort works");
            pass_count++;
        end else begin
            $display("FAIL: Array sort failed: %p", arr);
            fail_count++;
        end

        arr.reverse();
        if (arr[0] == 5 && arr[4] == 1) begin
            $display("PASS: Array reverse works");
            pass_count++;
        end else begin
            $display("FAIL: Array reverse failed: %p", arr);
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Dynamic Array Corner Cases Test ===");

        test_basic_creation();
        test_initialization();
        test_resize_preserve();
        test_resize_shrink();
        test_delete();
        test_empty_array();
        test_array_copy();
        test_array_of_objects();
        test_2d_dynamic();
        test_array_methods();
        test_array_find();
        test_sort_reverse();

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
