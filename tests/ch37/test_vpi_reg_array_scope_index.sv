/*
:name: test_vpi_reg_array_scope_index
:description: A reg array (unpacked array of logic) gives the scope and the module that declare it, vpiIsMemory is TRUE only for a one-dimensional one, and vpi_handle_by_index and vpi_handle_by_multi_index select its elements (IEEE 1800-2023 Section 37.20)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.20 37.17 38.19 38.20 K.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_reg_array_scope_index.c
:expected_stdout: @test_vpi_reg_array_scope_index.expected
*/
// IEEE 1800-2023 §37.20: a reg array (an array var of logic, 37.17 detail 19)
// has a one-to-one relation to the scope and to the module that declare it,
// and its elements are reached by index. mem and grid are declared in the
// module, lm in the named block blk of the module: vpiScope of lm is blk, not
// the module, while vpiModule of each array is the module. The comment of
// vpiIsMemory in vpi_user.h (Annex K.2) makes it TRUE for a one-dimensional
// reg array, so it is 1 for mem and lm and 0 for the two-dimensional grid.
// vpi_handle_by_index (38.19) with 2 on mem and vpi_handle_by_multi_index
// (38.20) with 2, 4 on grid and with 3 on mem select those elements: each is
// the same object as the one found by its name, and its value is the one the
// design wrote.

module test_vpi_reg_array_scope_index;
  logic [7:0] mem [0:3];
  logic [3:0] grid [1:2][5:4];

  initial begin : blk
    logic [1:0] lm [0:1];
    for (int k = 0; k < 4; k++) mem[k] = 8'h10 + k;
    foreach (grid[i, j]) grid[i][j] = 4'(i * 4 + j);
    lm[0] = 2'd1;
    lm[1] = 2'd2;
    #1 $vt_reg_array;
  end
endmodule
