/*
:name: test_vpi_compilation_unit_iteration
:description: The PLI iterates over the compilation units of a design: iterating the instances from a NULL handle gives the compilation unit as a package whose vpiUnit is true, and from it the application reaches the variables and the function declared in the compilation-unit scope (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 37.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_compilation_unit_iteration.c
:expected_stdout: @test_vpi_compilation_unit_iteration.expected
*/
// IEEE 1800-2023 §3.12.1: the items of a compilation-unit scope cannot be
// named from outside it, but the PLI can reach them, and it has an iterator
// over all the compilation units. §37.10: an iteration of vpiInstance from a
// NULL handle gives the instances, among them the packages; a package that is
// a compilation unit has the property vpiUnit true, and it iterates its
// variables with vpiVariables and its tasks and functions with vpiTaskFunc
// (37.10 detail 5: the full name of an object in a compilation unit begins
// with "$unit::").
// The single source file declares the variables cu_count (5) and cu_nib
// (4'hA) and the function cu_twice in its compilation-unit scope, so the
// design has exactly one compilation unit, whatever use model of §3.12.1 the
// tool takes. At 1 the module calls $vt_units, which iterates the instances
// from NULL, keeps those that are packages with vpiUnit true, and prints the
// variables (with their values) and the functions of each one, sorted, and
// then the number of compilation units it found. The module itself prints
// the values it reads before that.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiTaskFunc and vpiUnit, and the 5.054
// release of Verilator does not support user-defined system tasks.

int cu_count = 5;
logic [3:0] cu_nib = 4'hA;

function automatic int cu_twice(int x);
  return 2 * x;
endfunction

module test_vpi_compilation_unit_iteration;
  initial begin
    #1 $display("design: cu_twice(cu_count)=%0d cu_nib=%0d", cu_twice(cu_count), cu_nib);
    $vt_units;
  end
endmodule
