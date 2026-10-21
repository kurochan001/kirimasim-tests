/*
:name: test_vpi_compare_objects_variable_select
:description: vpi_compare_objects compares a select with a variable index, an argument of a system task call, with an array element or a bit as the object that the select names when it is called, so the result follows the index (IEEE 1800-2023 Section 38.3)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.3 37.2.3 38.19
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_compare_objects_variable_select.c
:expected_stdout: @test_vpi_compare_objects_variable_select.expected
*/
// IEEE 1800-2023 §38.3, §37.2.3: vpi_compare_objects returns 1 when its two
// handles refer to the same simulation object at the time of the call, and 0
// otherwise. A handle to a select whose index is a variable therefore refers
// to the element or bit that the index selects at that time. $vt_compare is
// called twice from one place in a loop, with mem[j] and r[j] as arguments;
// the application compares them with mem[0], mem[1], r[0] and r[1] obtained
// with vpi_handle_by_index (38.19). Icarus Verilog 13.0 gives 0 for every one
// of these comparisons.

module test_vpi_compare_objects_variable_select;
  logic [7:0] mem [0:3];
  logic [7:0] r;
  int j;

  initial
    for (j = 0; j < 2; j++)
      $vt_compare(mem[j], r[j]);
endmodule
