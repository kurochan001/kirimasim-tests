/*
:name: test_associative_array_corner
:description: Tests associative array operations with various index types
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9 7.8.1 7.8.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_associative_array_corner.expected
*/
// Tests associative array operations with various index types
`timescale 1ns/1ps

module test_associative_array_corner;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: String-indexed associative array
    task test_string_index();
        int arr[string];

        arr["one"] = 1;
        arr["two"] = 2;
        arr["three"] = 3;

        if (arr["one"] == 1 && arr["two"] == 2 && arr["three"] == 3) begin
            $display("PASS: String-indexed array works");
            pass_count++;
        end else begin
            $display("FAIL: String-indexed array failed");
            fail_count++;
        end

        if (arr.size() == 3) begin
            $display("PASS: Array size = %0d", arr.size());
            pass_count++;
        end else begin
            $display("FAIL: Array size = %0d (expected 3)", arr.size());
            fail_count++;
        end
    endtask

    // Test 2: Integer-indexed associative array
    task test_int_index();
        string arr[int];

        arr[100] = "hundred";
        arr[200] = "two hundred";
        arr[-50] = "negative fifty";

        if (arr[100] == "hundred" && arr[-50] == "negative fifty") begin
            $display("PASS: Int-indexed array works");
            pass_count++;
        end else begin
            $display("FAIL: Int-indexed array failed");
            fail_count++;
        end
    endtask

    // Test 3: exists() method
    task test_exists();
        int arr[string];

        arr["key1"] = 10;

        if (arr.exists("key1") && !arr.exists("key2")) begin
            $display("PASS: exists() method works");
            pass_count++;
        end else begin
            $display("FAIL: exists() method failed");
            fail_count++;
        end
    endtask

    // Test 4: delete() method
    task test_delete_element();
        int arr[string];

        arr["a"] = 1;
        arr["b"] = 2;
        arr["c"] = 3;

        arr.delete("b");

        if (!arr.exists("b") && arr.size() == 2) begin
            $display("PASS: delete() element works");
            pass_count++;
        end else begin
            $display("FAIL: delete() element failed");
            fail_count++;
        end

        arr.delete(); // Delete all
        if (arr.size() == 0) begin
            $display("PASS: delete() all works");
            pass_count++;
        end else begin
            $display("FAIL: delete() all failed");
            fail_count++;
        end
    endtask

    // Test 5: first() and next() iteration
    task test_first_next();
        int arr[int];
        int idx;
        static int count = 0;

        arr[10] = 100;
        arr[20] = 200;
        arr[30] = 300;

        if (arr.first(idx)) begin
            do begin
                $display("  arr[%0d] = %0d", idx, arr[idx]);
                count++;
            end while (arr.next(idx));
        end

        if (count == 3) begin
            $display("PASS: first()/next() iteration works, count=%0d", count);
            pass_count++;
        end else begin
            $display("FAIL: first()/next() count=%0d (expected 3)", count);
            fail_count++;
        end
    endtask

    // Test 6: last() and prev() iteration
    task test_last_prev();
        int arr[int];
        int idx;
        static int count = 0;

        arr[10] = 100;
        arr[20] = 200;
        arr[30] = 300;

        if (arr.last(idx)) begin
            do begin
                count++;
            end while (arr.prev(idx));
        end

        if (count == 3) begin
            $display("PASS: last()/prev() iteration works");
            pass_count++;
        end else begin
            $display("FAIL: last()/prev() count=%0d (expected 3)", count);
            fail_count++;
        end
    endtask

    // Test 7: num() method
    task test_num();
        int arr[string];

        arr["x"] = 1;
        arr["y"] = 2;

        if (arr.num() == 2) begin
            $display("PASS: num() returns %0d", arr.num());
            pass_count++;
        end else begin
            $display("FAIL: num() = %0d (expected 2)", arr.num());
            fail_count++;
        end
    endtask

    // Test 8: Enum as index
    typedef enum {RED, GREEN, BLUE} color_t;

    task test_enum_index();
        string arr[color_t];

        arr[RED] = "red";
        arr[GREEN] = "green";
        arr[BLUE] = "blue";

        if (arr[RED] == "red" && arr[GREEN] == "green" && arr[BLUE] == "blue") begin
            $display("PASS: Enum-indexed array works");
            pass_count++;
        end else begin
            $display("FAIL: Enum-indexed array failed");
            fail_count++;
        end
    endtask

    // Test 9: Class handle as index
    class KeyClass;
        int id;
        function new(int i);
            id = i;
        endfunction
    endclass

    task test_class_index();
        int arr[KeyClass];
        KeyClass k1, k2;

        k1 = new(1);
        k2 = new(2);

        arr[k1] = 100;
        arr[k2] = 200;

        if (arr[k1] == 100 && arr[k2] == 200) begin
            $display("PASS: Class handle-indexed array works");
            pass_count++;
        end else begin
            $display("FAIL: Class handle-indexed array failed");
            fail_count++;
        end
    endtask

    // Test 10: Wildcard index type
    task test_wildcard_index();
        int arr[*]; // Wildcard index

        arr[42] = 100;
        arr["string_key"] = 200;

        if (arr.size() == 2) begin
            $display("PASS: Wildcard index array works, size=%0d", arr.size());
            pass_count++;
        end else begin
            $display("FAIL: wildcard index size = %0d", arr.size());
            fail_count++;
        end
    endtask

    // Test 12: Array of arrays
    task test_array_of_arrays();
        int arr[string][];

        arr["first"] = new[3]('{1, 2, 3});
        arr["second"] = new[2]('{4, 5});

        if (arr["first"].size() == 3 && arr["second"].size() == 2) begin
            $display("PASS: Associative array of dynamic arrays works");
            pass_count++;
        end else begin
            $display("FAIL: Associative array of dynamic arrays failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Associative Array Corner Cases Test ===");

        test_string_index();
        test_int_index();
        test_exists();
        test_delete_element();
        test_first_next();
        test_last_prev();
        test_num();
        test_enum_index();
        test_class_index();
        test_wildcard_index();
        test_array_of_arrays();

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
