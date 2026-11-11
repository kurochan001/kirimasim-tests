/*
:name: test_compilation_unit_shared_across_files
:description: When use model a) of 3.12.1 is chosen, all files of one command line form one compilation unit, so a variable and a function declared in one file are visible in another file (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: compilation_unit_shared_across_files_unit.sv
:compilation_unit: single
:expected_stdout: @test_compilation_unit_shared_across_files.expected
*/
// IEEE 1800-2023 §3.12.1: which files form a compilation unit is left to the
// tool, but a tool has to provide two use models: a) all files of one command
// line form one unit, b) each file is its own unit. This test holds only
// when use model a) of 3.12.1 is chosen, which :compilation_unit: single
// says. The unit variable unit_shared and the unit function unit_add are
// declared in compilation_unit_shared_across_files_unit.sv, which :files:
// compiles before this test. Under use model a) this module is in the same
// compilation unit, so it can read the variable and call the function:
// unit_add(40) is 42. Under use model b) the two names are not visible here.

module test_compilation_unit_shared_across_files;
  initial $display("unit=%0d", unit_add(unit_shared));
endmodule
