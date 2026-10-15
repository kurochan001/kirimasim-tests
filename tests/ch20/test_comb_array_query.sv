/*
:name: test_comb_array_query
:description: Test array query system functions ($size, $left, $right, $low, $high, $dimensions, $increment)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_array_query.expected
*/
// Test array query system functions ($size, $left, $right, $low, $high, $dimensions, $increment)
// IEEE 1800-2023 §20.7

module test_comb_array_query;
    int pass = 0, fail = 0;

    // Test arrays with various dimensions and ranges
    logic [7:0] fixed_arr [0:3];           // 4 elements, ascending
    logic [15:0] desc_arr [3:0];           // 4 elements, descending
    logic [3:0] arr2d [0:1][0:2];          // 2x3 multi-dimensional
    logic [7:0] arr3d [1:2][5:7][0:1];     // 3D array
    int dyn_arr [];                         // Dynamic array
    logic [7:4] packed_arr;                 // Packed array with descending range

    initial begin
        // Initialize dynamic array
        dyn_arr = new[5];

        if ($size(fixed_arr) == 4) pass++;
        else begin fail++; $display("FAIL: $size(fixed_arr)=%0d exp 4", $size(fixed_arr)); end

        // Test 2: $size on descending array [3:0]
        if ($size(desc_arr) == 4) pass++;
        else begin fail++; $display("FAIL: $size(desc_arr)=%0d exp 4", $size(desc_arr)); end

        // Test 3: $left on ascending array [0:3]
        if ($left(fixed_arr) == 0) pass++;
        else begin fail++; $display("FAIL: $left(fixed_arr)=%0d exp 0", $left(fixed_arr)); end

        // Test 4: $right on ascending array [0:3]
        if ($right(fixed_arr) == 3) pass++;
        else begin fail++; $display("FAIL: $right(fixed_arr)=%0d exp 3", $right(fixed_arr)); end

        // Test 5: $left on descending array [3:0]
        if ($left(desc_arr) == 3) pass++;
        else begin fail++; $display("FAIL: $left(desc_arr)=%0d exp 3", $left(desc_arr)); end

        // Test 6: $right on descending array [3:0]
        if ($right(desc_arr) == 0) pass++;
        else begin fail++; $display("FAIL: $right(desc_arr)=%0d exp 0", $right(desc_arr)); end

        // Test 7: $low on ascending array [0:3] - returns minimum bound
        if ($low(fixed_arr) == 0) pass++;
        else begin fail++; $display("FAIL: $low(fixed_arr)=%0d exp 0", $low(fixed_arr)); end

        // Test 8: $high on ascending array [0:3] - returns maximum bound
        if ($high(fixed_arr) == 3) pass++;
        else begin fail++; $display("FAIL: $high(fixed_arr)=%0d exp 3", $high(fixed_arr)); end

        // Test 9: $low on descending array [3:0] - returns minimum bound (0)
        if ($low(desc_arr) == 0) pass++;
        else begin fail++; $display("FAIL: $low(desc_arr)=%0d exp 0", $low(desc_arr)); end

        // Test 10: $high on descending array [3:0] - returns maximum bound (3)
        if ($high(desc_arr) == 3) pass++;
        else begin fail++; $display("FAIL: $high(desc_arr)=%0d exp 3", $high(desc_arr)); end

        // Test 11: $increment on ascending array [0:3] - returns 1
        if ($increment(fixed_arr) == -1) pass++;
        else begin fail++; $display("FAIL: $increment(fixed_arr)=%0d exp -1", $increment(fixed_arr)); end

        // Test 12: $increment on descending array [3:0] - returns -1
        if ($increment(desc_arr) == 1) pass++;
        else begin fail++; $display("FAIL: $increment(desc_arr)=%0d exp 1", $increment(desc_arr)); end

        // Test 13: $size on dynamic array after new[5]
        if ($size(dyn_arr) == 5) pass++;
        else begin fail++; $display("FAIL: $size(dyn_arr)=%0d exp 5", $size(dyn_arr)); end

        // Test 14: $dimensions on 2D array
        if ($dimensions(arr2d) == 3) pass++;
        else begin fail++; $display("FAIL: $dimensions(arr2d)=%0d exp 3", $dimensions(arr2d)); end

        // Test 15: $dimensions on 3D array
        if ($dimensions(arr3d) == 4) pass++;
        else begin fail++; $display("FAIL: $dimensions(arr3d)=%0d exp 4", $dimensions(arr3d)); end

        // Test 16: $size with dimension argument on 2D array - dimension 1 (first dimension [0:1])
        if ($size(arr2d, 1) == 2) pass++;
        else begin fail++; $display("FAIL: $size(arr2d,1)=%0d exp 2", $size(arr2d, 1)); end

        // Test 17: $size with dimension argument on 2D array - dimension 2 (second dimension [0:2])
        if ($size(arr2d, 2) == 3) pass++;
        else begin fail++; $display("FAIL: $size(arr2d,2)=%0d exp 3", $size(arr2d, 2)); end

        // Test 18: $left on 3D array dimension 1 [1:2]
        if ($left(arr3d, 1) == 1) pass++;
        else begin fail++; $display("FAIL: $left(arr3d,1)=%0d exp 1", $left(arr3d, 1)); end

        // Test 19: $right on 3D array dimension 2 [5:7]
        if ($right(arr3d, 2) == 7) pass++;
        else begin fail++; $display("FAIL: $right(arr3d,2)=%0d exp 7", $right(arr3d, 2)); end

        // Test 20: $low on 3D array dimension 3 [0:1]
        if ($low(arr3d, 3) == 0) pass++;
        else begin fail++; $display("FAIL: $low(arr3d,3)=%0d exp 0", $low(arr3d, 3)); end

        // Test 21: $high on 3D array dimension 2 [5:7]
        if ($high(arr3d, 2) == 7) pass++;
        else begin fail++; $display("FAIL: $high(arr3d,2)=%0d exp 7", $high(arr3d, 2)); end

        // Test 22: $increment on 3D array dimension 1 [1:2] - ascending
        if ($increment(arr3d, 1) == -1) pass++;
        else begin fail++; $display("FAIL: $increment(arr3d,1)=%0d exp -1", $increment(arr3d, 1)); end

        // Test 23: $left on packed array [7:4] - descending
        if ($left(packed_arr) == 7) pass++;
        else begin fail++; $display("FAIL: $left(packed_arr)=%0d exp 7", $left(packed_arr)); end

        // Test 24: $right on packed array [7:4] - descending
        if ($right(packed_arr) == 4) pass++;
        else begin fail++; $display("FAIL: $right(packed_arr)=%0d exp 4", $right(packed_arr)); end

        // Test 25: $increment on packed array [7:4]
        // $left >= $right, so $increment is 1 (20.7)
        if ($increment(packed_arr) == 1) pass++;
        else begin fail++; $display("FAIL: $increment(packed_arr)=%0d exp 1", $increment(packed_arr)); end

        $display("array_query: pass=%0d fail=%0d", pass, fail);
        if (fail == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
