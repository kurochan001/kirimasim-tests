/*
:name: test_size_array
:description: Test for $size for arrays
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7 7.4 7.5 7.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_size_array.expected
*/
// Test for $size for arrays
module test_size_array;
    logic [7:0] fixed_arr [0:9];           // Size 10
    logic [7:0] fixed_arr2 [5:14];         // Size 10, offset range
    logic [15:0] wide_arr [0:4][0:3];      // 5x4 = 20 elements
    logic [7:0] queue_test [$];
    logic [7:0] dyn_arr [];

    logic [3:0][7:0] packed_arr;           // Packed: 4 bytes
    logic [31:0] simple_vec;               // Single dimension

    integer pass_count;
    integer i;

    initial begin
        pass_count = 0;

        if ($size(fixed_arr) == 10) begin
            $display("Test 1: $size(fixed_arr[0:9]) = %0d - PASS", $size(fixed_arr));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: $size fixed_arr - FAIL (got %0d)", $size(fixed_arr));
        end

        // Test 2: $size with offset range
        if ($size(fixed_arr2) == 10) begin
            $display("Test 2: $size(fixed_arr2[5:14]) = %0d - PASS", $size(fixed_arr2));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2: $size offset range - FAIL (got %0d)", $size(fixed_arr2));
        end

        // Test 3: $size of multidimensional array (first dimension)
        if ($size(wide_arr) == 5 && $size(wide_arr, 1) == 5 && $size(wide_arr, 2) == 4) begin
            $display("Test 3: $size(wide_arr) dims: %0d x %0d - PASS",
                     $size(wide_arr, 1), $size(wide_arr, 2));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 3: $size multidim - FAIL");
        end

        // Test 4: $size of dynamic array
        dyn_arr = new[8];
        if ($size(dyn_arr) == 8) begin
            dyn_arr = new[20];
            if ($size(dyn_arr) == 20) begin
                $display("Test 4: $size(dyn_arr) resized: 8 -> 20 - PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("Test 4: $size after resize - FAIL");
            end
        end else begin
            $display("Test 4: $size initial - FAIL");
        end

        // Test 5: $size of queue
        for (i = 0; i < 5; i = i + 1) begin
            queue_test.push_back(i);
        end
        if ($size(queue_test) == 5) begin
            queue_test.push_back(100);
            queue_test.push_back(200);
            if ($size(queue_test) == 7) begin
                $display("Test 5: $size(queue) = %0d - PASS", $size(queue_test));
                pass_count = pass_count + 1;
            end else begin
                $display("Test 5: $size queue after push - FAIL");
            end
        end else begin
            $display("Test 5: $size queue initial - FAIL (got %0d)", $size(queue_test));
        end

        if (pass_count == 5)
            $display("All size tests PASS");
        else
            $display("Some tests FAIL: %0d/5 passed", pass_count);

        $finish;
    end
endmodule
