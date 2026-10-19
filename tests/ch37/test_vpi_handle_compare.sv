/*
:name: test_vpi_handle_compare
:description: Handles to the same object, obtained by full name, by name in a scope, by iteration, as the parent of a bit and as the module of a variable, compare equal with vpi_compare_objects, and handles to different objects do not (IEEE 1800-2023 Section 37.2)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.2.1 37.2.3 38.3 37.17 37.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_handle_compare.c
:expected_stdout: @test_vpi_handle_compare.expected
*/
// IEEE 1800-2023 §37.2.1: a tool may give two distinct handles for one object,
// and such handles are equivalent. §37.2.3, §38.3: equivalence is decided by
// vpi_compare_objects, which gives 1 for the same object and 0 otherwise, not
// by comparing the handles with ==. The application gets r by its full name,
// by its name in the module, by vpi_iterate(vpiReg) over the module, and as
// the vpiParent of the bit r[3] (37.17 detail 26), and gets the module by name
// and as vpiModule of r (37.10). It compares them and also r with s and the
// bit with r.

module test_vpi_handle_compare;
  logic [7:0] r = 8'h11, s = 8'h22;

  initial $vt_compare;
endmodule
