/*
:name: test_dimensions
:description: $dimensions, $unpacked_dimensions
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dimensions.expected
*/
// $dimensions, $unpacked_dimensions
module test_dimensions;
    logic [7:0] vec1d;                          // 1 packed dim
    logic [3:0][7:0] vec2d;                     // 2 packed dims
    logic [7:0] arr1d [0:3];                    // 1 unpacked + 1 packed
    logic [7:0] arr2d [0:3][0:1];               // 2 unpacked + 1 packed
    logic [3:0][7:0] arr3d [0:2][0:1][0:3];     // 3 unpacked + 2 packed

    integer int_var;
    real real_var;
    logic [7:0] queue_var [$];
    logic [7:0] dyn_arr [];

    integer pass_count;

    initial begin
        pass_count = 0;

        // Test 1: $dimensions of packed vectors
        if ($dimensions(vec1d) == 1 && $dimensions(vec2d) == 2) begin
            $display("Test 1: $dimensions packed - PASS");
            $display("  vec1d[7:0]: %0d dims", $dimensions(vec1d));
            $display("  vec2d[3:0][7:0]: %0d dims", $dimensions(vec2d));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: $dimensions packed - FAIL");
        end

        // Test 2: $dimensions of unpacked arrays
        if ($dimensions(arr1d) == 2 && $dimensions(arr2d) == 3) begin
            $display("Test 2: $dimensions unpacked - PASS");
            $display("  arr1d[0:3]: %0d dims", $dimensions(arr1d));
            $display("  arr2d[0:3][0:1]: %0d dims", $dimensions(arr2d));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2: $dimensions unpacked - FAIL (%0d, %0d)",
                     $dimensions(arr1d), $dimensions(arr2d));
        end

        // Test 3: $unpacked_dimensions
        if ($unpacked_dimensions(arr1d) == 1 && $unpacked_dimensions(arr2d) == 2) begin
            $display("Test 3: $unpacked_dimensions - PASS");
            $display("  arr1d: %0d unpacked dims", $unpacked_dimensions(arr1d));
            $display("  arr2d: %0d unpacked dims", $unpacked_dimensions(arr2d));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 3: $unpacked_dimensions - FAIL");
        end

        // Test 4: Mixed packed/unpacked array
        if ($dimensions(arr3d) == 5 && $unpacked_dimensions(arr3d) == 3) begin
            $display("Test 4: Mixed array - PASS");
            $display("  arr3d[0:2][0:1][0:3] of [3:0][7:0]:");
            $display("    total dims: %0d, unpacked: %0d",
                     $dimensions(arr3d), $unpacked_dimensions(arr3d));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 4: Mixed array - FAIL (%0d total, %0d unpacked)",
                     $dimensions(arr3d), $unpacked_dimensions(arr3d));
        end

        // Test 5: $dimensions of basic types
        // An integer type is treated as a packed vector [31:0], so it has one
        // dimension (20.7).
        if ($dimensions(int_var) == 1) begin
            $display("Test 5: $dimensions basic types - PASS");
            $display("  integer: %0d dims", $dimensions(int_var));
            pass_count = pass_count + 1;
        end else begin
            $display("Test 5: $dimensions basic - FAIL");
        end

        if (pass_count == 5)
            $display("All dimensions tests PASS");
        else
            $display("Some tests FAIL: %0d/5 passed", pass_count);

        $finish;
    end
endmodule
