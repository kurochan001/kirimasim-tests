/*
:name: test_compilation_unit_shared_across_files
:description: When several source files are compiled on one command line, their compilation-unit scope is one unit, so a variable and a function declared in one file are visible in another file (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: compilation_unit_shared_across_files_unit.sv
:expected_stdout: @test_compilation_unit_shared_across_files.expected
*/
// IEEE 1800-2023 §3.12.1: a use model that compiles several source files on
// one command line treats them as one compilation unit. The unit variable
// unit_shared and the unit function unit_add are declared in
// compilation_unit_shared_across_files_unit.sv, which :files: compiles
// before this test. This module is in the same compilation unit, so it can read
// the variable and call the function: unit_add(40) is 42.

module test_compilation_unit_shared_across_files;
  initial $display("unit=%0d", unit_add(unit_shared));
endmodule
