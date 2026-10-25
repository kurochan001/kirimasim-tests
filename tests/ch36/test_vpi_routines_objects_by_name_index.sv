/*
:name: test_vpi_routines_objects_by_name_index
:description: the routines of Table 36-5 do what it lists: vpi_handle_by_name finds an object by its full name or by its name within a scope, vpi_handle_by_index finds a bit of a vector and an element of an array, and vpi_handle_by_multi_index finds a word of a two-dimensional array and a bit of that word (IEEE 1800-2023 Section 36.11)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.11 38.21 38.19 38.20 38.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_routines_objects_by_name_index.c
:expected_stdout: @test_vpi_routines_objects_by_name_index.expected
*/
// IEEE 1800-2023 §36.11, Table 36-5: vpi_handle_by_name obtains the handle of
// a named object, vpi_handle_by_index of an indexed object, and
// vpi_handle_by_multi_index of a word or bit in an array. §38.21: a
// hierarchical name is searched from the top of the hierarchy when the scope
// is NULL, and a simple name only within the scope given. §38.19: the index
// of a bit of a vector or of an element of an array selects it. §38.20: the
// indices follow the unpacked dimensions from the left, and may end with a
// bit-select index.
// At time 1 the application finds u1.v by its full name and by the name v
// within u1, bit 2 of vec, element 1 of arr, word grid[1][2] and bit 2 of
// that word, and prints their full names and values with vpi_get_value
// (38.15). Each object has a value of its own, so a wrong selection shows.
// Icarus Verilog 13.0 does not declare vpi_handle_by_multi_index.

module test_vpi_routines_objects_by_name_index_leaf;
  logic [3:0] v;

  initial v = 4'b1010;
endmodule

module test_vpi_routines_objects_by_name_index;
  logic [7:0] vec;
  logic [3:0] arr [0:2];
  logic [3:0] grid [0:1][0:2];

  test_vpi_routines_objects_by_name_index_leaf u1();

  initial begin
    vec = 8'b0000_0100;
    arr[0] = 4'd1;
    arr[1] = 4'd9;
    arr[2] = 4'd3;
    foreach (grid[i, j]) grid[i][j] = 4'(i * 3 + j);
    #2 $display("design: grid[1][2]=%0d", grid[1][2]);
  end
endmodule
