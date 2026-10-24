/*
:name: test_vpi_var_select_iteration
:description: vpi_iterate(vpiVarSelect) on an array var gives a var select for each element, named with its indices, of the size of an element, with its typespec, its index by vpi_handle in one dimension and by iteration from the selected element outward in two, and a value that can be read and written (IEEE 1800-2023 Sections 37.17 and 37.19)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.19 37.17 37.25 38.15 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_var_select_iteration.c
:expected_stdout: @test_vpi_var_select_iteration.expected
*/
// IEEE 1800-2023 §37.19 and §37.17: an array var has a one-to-many relation
// to var selects, its elements (37.17 detail 7; the vpiVarSelect transition
// reaches all elements, not one dimension at a time, 37.18 detail 3). A var
// select has vpiName and vpiFullName, which include its indices (37.17 detail
// 28), a vpiSize of the bits of the packed element (detail 10), a typespec,
// the array as vpiParent, and a value that vpi_get_value reads and
// vpi_put_value writes. vpi_handle(vpiIndex) gives the index of a var select
// of the one-dimensional mem, and vpi_iterate(vpiIndex) the indices of one of
// the two-dimensional m2 from its own index outward: 3 then 1 for m2[1][3]
// (detail 5). The element type of mem is logic [7:0], a logic typespec with
// range 7:0; that of m2 an int typespec (37.25). The application writes 8'ha5
// through mem[2] and 99 through m2[1][3]; the design prints them at 2. Lists
// are sorted by name.

module test_vpi_var_select_iteration;
  logic [7:0] mem [3:1];
  int m2 [0:1][2:4];

  initial begin
    foreach (mem[i]) mem[i] = 8'(i * 16 + 1);
    foreach (m2[i, j]) m2[i][j] = i * 10 + j;
    #1 $vt_selects;
    #1 $display("mem[2] = %h, m2[1][3] = %0d, m2[1][2] = %0d", mem[2], m2[1][3], m2[1][2]);
  end
endmodule
