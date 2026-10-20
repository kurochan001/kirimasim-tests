/*
:name: test_copy_row_of_unpacked_struct_array
:description: A row of a two-dimensional array of unpacked structures is an array that can be read and written as a whole (IEEE 1800-2023 Section 7.4.4)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.4 7.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_copy_row_of_unpacked_struct_array.expected
*/
// IEEE 1800-2023 §7.4.4: selecting one index of a two-dimensional unpacked
// array, grid[1], gives the one-dimensional array of that row. §7.6: an
// unpacked array can be assigned to another of the same shape, element by
// element, also when the elements are unpacked structures. So row = grid[1]
// copies the three structures of the row, and grid[0] = row writes them into
// another row.

module test_copy_row_of_unpacked_struct_array;
  typedef struct { int id; } r_t;
  r_t grid[2][3];
  r_t row[3];

  initial begin
    foreach (grid[i, j]) grid[i][j].id = 10 * i + 2 - j;
    row = grid[1];
    $display("row: %0d %0d %0d", row[0].id, row[1].id, row[2].id);
    grid[0] = row;
    $display("grid[0]: %0d %0d %0d", grid[0][0].id, grid[0][1].id, grid[0][2].id);
  end
endmodule
