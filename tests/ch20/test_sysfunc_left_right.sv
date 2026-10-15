/*
:name: test_sysfunc_left_right
:description: Test $left/$right system functions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_left_right.expected
*/
// Test $left/$right system functions
module test_sysfunc_left_right;
    int pass_count = 0;
    int total_tests = 8;

    // Ascending range
    logic [0:7] asc_vec;
    logic [0:15] asc_arr[0:9];

    // Descending range
    logic [31:0] desc_vec;
    logic [15:0] desc_arr[7:0];

    // Mixed ranges
    logic [7:0] mixed_arr[0:3];  // Descending packed, ascending unpacked
    logic [0:7] mixed_arr2[4:0]; // Ascending packed, descending unpacked

    // Multi-dimensional
    logic [7:0] multi[3:0][0:5];

    // Dynamic and queue (use runtime bounds)
    int dyn_arr[];
    int queue_arr[$];

    initial begin
        // Initialize dynamic array and queue
        dyn_arr = new[10];
        for (int i = 0; i < 5; i++) queue_arr.push_back(i);

        // Test 1: $left/$right of descending vector
        if ($left(desc_vec) == 31 && $right(desc_vec) == 0) begin
            $display("Test 1 PASS: desc_vec[31:0]: $left=%0d, $right=%0d", $left(desc_vec), $right(desc_vec));
            pass_count++;
        end else begin
            $display("Test 1 FAIL: $left=%0d, $right=%0d", $left(desc_vec), $right(desc_vec));
        end

        // Test 2: $left/$right of ascending vector
        if ($left(asc_vec) == 0 && $right(asc_vec) == 7) begin
            $display("Test 2 PASS: asc_vec[0:7]: $left=%0d, $right=%0d", $left(asc_vec), $right(asc_vec));
            pass_count++;
        end else begin
            $display("Test 2 FAIL: $left=%0d, $right=%0d", $left(asc_vec), $right(asc_vec));
        end

        // Test 3: $left/$right of array (first dimension - unpacked)
        if ($left(desc_arr) == 7 && $right(desc_arr) == 0) begin
            $display("Test 3 PASS: desc_arr[7:0]: $left=%0d, $right=%0d", $left(desc_arr), $right(desc_arr));
            pass_count++;
        end else begin
            $display("Test 3 FAIL: $left=%0d, $right=%0d", $left(desc_arr), $right(desc_arr));
        end

        // Test 4: $left/$right with dimension argument
        if ($left(multi, 1) == 3 && $right(multi, 1) == 0) begin
            $display("Test 4 PASS: multi dim1: $left=%0d, $right=%0d", $left(multi, 1), $right(multi, 1));
            pass_count++;
        end else begin
            $display("Test 4 FAIL: multi dim1 bounds incorrect");
        end

        // Test 5: Second dimension bounds
        if ($left(multi, 2) == 0 && $right(multi, 2) == 5) begin
            $display("Test 5 PASS: multi dim2: $left=%0d, $right=%0d", $left(multi, 2), $right(multi, 2));
            pass_count++;
        end else begin
            $display("Test 5 FAIL: multi dim2 bounds incorrect");
        end

        // Test 6: Dynamic array bounds
        if ($left(dyn_arr) == 0 && $right(dyn_arr) == 9) begin
            $display("Test 6 PASS: dyn_arr: $left=%0d, $right=%0d", $left(dyn_arr), $right(dyn_arr));
            pass_count++;
        end else begin
            $display("Test 6 FAIL: dyn_arr: $left=%0d, $right=%0d", $left(dyn_arr), $right(dyn_arr));
        end

        // Test 7: Queue bounds
        if ($left(queue_arr) == 0 && $right(queue_arr) == 4) begin
            $display("Test 7 PASS: queue_arr: $left=%0d, $right=%0d", $left(queue_arr), $right(queue_arr));
            pass_count++;
        end else begin
            $display("Test 7 FAIL: queue_arr: $left=%0d, $right=%0d", $left(queue_arr), $right(queue_arr));
        end

        // Test 8: Mixed range array
        if ($left(mixed_arr) == 0 && $right(mixed_arr) == 3) begin
            $display("Test 8 PASS: mixed_arr[0:3]: $left=%0d, $right=%0d", $left(mixed_arr), $right(mixed_arr));
            pass_count++;
        end else begin
            $display("Test 8 FAIL: $left=%0d, $right=%0d", $left(mixed_arr), $right(mixed_arr));
        end

        if (pass_count == total_tests) $display("PASS: sysfunc_left_right (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: sysfunc_left_right (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
