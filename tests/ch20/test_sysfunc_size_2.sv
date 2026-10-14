/*
:name: test_sysfunc_size_2
:description: Test $size system function
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sysfunc_size_2.expected
*/
// Test $size system function
module test_sysfunc_size;
    int pass_count = 0;
    int total_tests = 8;

    logic [7:0] arr1d[10];
    logic [7:0] arr2d[5][8];
    logic [7:0] arr3d[3][4][5];

    // Dynamic array
    int dyn_arr[];

    // Queue
    int queue_arr[$];

    // Packed array
    logic [3:0][7:0] packed_arr;  // 4 bytes packed

    // Multi-dimensional packed
    logic [1:0][3:0][7:0] multi_packed;  // 2 x 4 x 8 bits

    // Descending range
    logic [15:0] desc_arr[7:0];  // 8 elements, indices 7 down to 0

    initial begin
        // Initialize dynamic array
        dyn_arr = new[15];

        // Initialize queue
        for (int i = 0; i < 7; i++) queue_arr.push_back(i);

        if ($size(arr1d) == 10) begin
            $display("Test 1 PASS: $size(arr1d) = %0d", $size(arr1d));
            pass_count++;
        end else begin
            $display("Test 1 FAIL: $size(arr1d) = %0d, expected 10", $size(arr1d));
        end

        // Test 2: $size of 2D array (first dimension)
        if ($size(arr2d) == 5 && $size(arr2d, 1) == 5) begin
            $display("Test 2 PASS: $size(arr2d) = %0d, $size(arr2d,1) = %0d", $size(arr2d), $size(arr2d, 1));
            pass_count++;
        end else begin
            $display("Test 2 FAIL: 2D array size incorrect");
        end

        // Test 3: $size of 2D array (second dimension)
        if ($size(arr2d, 2) == 8) begin
            $display("Test 3 PASS: $size(arr2d, 2) = %0d", $size(arr2d, 2));
            pass_count++;
        end else begin
            $display("Test 3 FAIL: $size(arr2d, 2) = %0d, expected 8", $size(arr2d, 2));
        end

        // Test 4: $size of 3D array dimensions
        if ($size(arr3d, 1) == 3 && $size(arr3d, 2) == 4 && $size(arr3d, 3) == 5) begin
            $display("Test 4 PASS: 3D array: dim1=%0d, dim2=%0d, dim3=%0d",
                     $size(arr3d, 1), $size(arr3d, 2), $size(arr3d, 3));
            pass_count++;
        end else begin
            $display("Test 4 FAIL: 3D array dimensions incorrect");
        end

        // Test 5: $size of dynamic array
        if ($size(dyn_arr) == 15) begin
            $display("Test 5 PASS: $size(dyn_arr) = %0d", $size(dyn_arr));
            pass_count++;
        end else begin
            $display("Test 5 FAIL: $size(dyn_arr) = %0d, expected 15", $size(dyn_arr));
        end

        // Test 6: $size of queue
        if ($size(queue_arr) == 7) begin
            $display("Test 6 PASS: $size(queue_arr) = %0d", $size(queue_arr));
            pass_count++;
        end else begin
            $display("Test 6 FAIL: $size(queue_arr) = %0d, expected 7", $size(queue_arr));
        end

        // Test 7: $size of packed array dimension
        if ($size(packed_arr) == 4) begin
            $display("Test 7 PASS: $size(packed_arr) = %0d", $size(packed_arr));
            pass_count++;
        end else begin
            $display("Test 7 FAIL: $size(packed_arr) = %0d, expected 4", $size(packed_arr));
        end

        // Test 8: $size of descending range array
        if ($size(desc_arr) == 8) begin
            $display("Test 8 PASS: $size(desc_arr[7:0]) = %0d", $size(desc_arr));
            pass_count++;
        end else begin
            $display("Test 8 FAIL: $size(desc_arr) = %0d, expected 8", $size(desc_arr));
        end

        $display("PASS: sysfunc_size (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
