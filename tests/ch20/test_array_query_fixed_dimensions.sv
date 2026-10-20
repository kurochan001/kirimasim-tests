/*
:name: test_array_query_fixed_dimensions
:description: The array query functions can name, with a dimension number, any fixed-size dimension of an array that also has a variable-sized one, and a variable-sized dimension through a select of the elements before it (IEEE 1800-2023 Section 20.7.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.7.1 20.7 7.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_array_query_fixed_dimensions.expected
*/
// IEEE 1800-2023 §20.7.1: a query such as $size(v, n) with n greater than 1
// is an error when dimension n is variable-sized, but fixed-size dimensions
// can be queried that way, and $dimensions and $unpacked_dimensions take no
// dimension number. grid has a fixed first dimension, a dynamic second one
// (7.5) and a fixed third one; its dynamic dimension is queried through
// grid[1] and grid[0], whose own first dimension it is.
//
// With Verilator 5.052, $size(grid, 3) gives 0.

module test_array_query_fixed_dimensions;
  byte grid [2][][3];

  initial begin
    grid[1] = new[5];
    $display("unpacked dimensions: %0d, dimensions: %0d", $unpacked_dimensions(grid),
             $dimensions(grid));
    $display("size 1: %0d, size 3: %0d, left 3: %0d", $size(grid, 1), $size(grid, 3),
             $left(grid, 3));
    $display("grid[1]: %0d, grid[0]: %0d", $size(grid[1], 1), $size(grid[0], 1));
  end
endmodule
