/*
:name: test_null_empty_corner
:description: Tests null handles, empty arrays, and default values
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 7.5 7.10 7.8 6.16
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_null_empty_corner.expected
*/
// Tests null handles, empty arrays, and default values
`timescale 1ns/1ps

module test_null_empty_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Null class handle
    class SimpleClass;
        int value;
        function new(int v = 0);
            value = v;
        endfunction
    endclass

    task test_null_handle();
        SimpleClass obj;

        if (obj == null) begin
            $display("PASS: Uninitialized class handle is null");
            pass_count++;
        end else begin
            $display("FAIL: Handle should be null");
            fail_count++;
        end

        obj = new(42);
        if (obj != null) begin
            $display("PASS: Initialized handle is not null");
            pass_count++;
        end else begin
            $display("FAIL: Handle should not be null after new");
            fail_count++;
        end

        obj = null;
        if (obj == null) begin
            $display("PASS: Handle set to null works");
            pass_count++;
        end else begin
            $display("FAIL: Handle not null after assignment");
            fail_count++;
        end
    endtask

    // Test 2: Empty dynamic array
    task test_empty_dynamic_array();
        int arr[];

        if (arr.size() == 0) begin
            $display("PASS: Uninitialized dynamic array size is 0");
            pass_count++;
        end else begin
            $display("FAIL: Dynamic array should be empty");
            fail_count++;
        end

        arr = new[0];
        if (arr.size() == 0) begin
            $display("PASS: new[0] creates empty array");
            pass_count++;
        end else begin
            $display("FAIL: new[0] should create empty array");
            fail_count++;
        end
    endtask

    // Test 3: Empty queue
    task test_empty_queue();
        int q[$];

        if (q.size() == 0) begin
            $display("PASS: Empty queue size is 0");
            pass_count++;
        end else begin
            $display("FAIL: Queue should be empty");
            fail_count++;
        end

        // Pop from empty queue
        q.push_back(1);
        q.pop_front();

        if (q.size() == 0) begin
            $display("PASS: Queue empty after pop");
            pass_count++;
        end else begin
            $display("FAIL: Queue should be empty after pop");
            fail_count++;
        end
    endtask

    // Test 4: Empty associative array
    task test_empty_assoc_array();
        int aa[string];

        if (aa.size() == 0) begin
            $display("PASS: Empty associative array size is 0");
            pass_count++;
        end else begin
            $display("FAIL: Assoc array should be empty");
            fail_count++;
        end

        if (!aa.exists("key")) begin
            $display("PASS: Non-existent key returns false");
            pass_count++;
        end else begin
            $display("FAIL: Key should not exist");
            fail_count++;
        end
    endtask

    // Test 5: Empty string
    task test_empty_string();
        string s;

        if (s.len() == 0) begin
            $display("PASS: Empty string length is 0");
            pass_count++;
        end else begin
            $display("FAIL: String should be empty");
            fail_count++;
        end

        if (s == "") begin
            $display("PASS: Empty string equals \"\"");
            pass_count++;
        end else begin
            $display("FAIL: String comparison failed");
            fail_count++;
        end
    endtask

    // Test 6: Default values
    task test_default_values();
        int default_int;
        real default_real;
        string default_str;
        logic [7:0] default_logic;

        // int defaults to 0
        if (default_int == 0) begin
            $display("PASS: Default int is 0");
            pass_count++;
        end else begin
            $display("FAIL: Default int wrong");
            fail_count++;
        end

        // real defaults to 0.0
        if (default_real == 0.0) begin
            $display("PASS: Default real is 0.0");
            pass_count++;
        end else begin
            $display("FAIL: Default real wrong");
            fail_count++;
        end

        // string defaults to ""
        if (default_str == "") begin
            $display("PASS: Default string is empty");
            pass_count++;
        end else begin
            $display("FAIL: Default string wrong");
            fail_count++;
        end
    endtask


    // Test 8: Delete from array
    task test_array_delete();
        int aa[int];

        aa[0] = 100;
        aa[1] = 200;
        aa[2] = 300;

        aa.delete(1);

        if (aa.size() == 2 && !aa.exists(1)) begin
            $display("PASS: Delete from associative array works");
            pass_count++;
        end else begin
            $display("FAIL: Array delete failed");
            fail_count++;
        end

        aa.delete();  // Delete all

        if (aa.size() == 0) begin
            $display("PASS: Delete all from array works");
            pass_count++;
        end else begin
            $display("FAIL: Delete all failed");
            fail_count++;
        end
    endtask

    // Test 9: Clear queue
    task test_queue_clear();
        static int q[$] = '{1, 2, 3, 4, 5};

        q.delete();

        if (q.size() == 0) begin
            $display("PASS: Queue delete clears all elements");
            pass_count++;
        end else begin
            $display("FAIL: Queue delete failed");
            fail_count++;
        end
    endtask

    // Test 10: Null in comparison
    task test_null_comparison();
        static SimpleClass a = null;
        static SimpleClass b = null;
        static SimpleClass c = new(10);

        if (a == b) begin
            $display("PASS: null == null is true");
            pass_count++;
        end else begin
            $display("FAIL: null comparison failed");
            fail_count++;
        end

        if (a != c) begin
            $display("PASS: null != object is true");
            pass_count++;
        end else begin
            $display("FAIL: null-object comparison failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Null and Empty Corner Cases Test ===");

        test_null_handle();
        test_empty_dynamic_array();
        test_empty_queue();
        test_empty_assoc_array();
        test_empty_string();
        test_default_values();
        test_array_delete();
        test_queue_clear();
        test_null_comparison();

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
