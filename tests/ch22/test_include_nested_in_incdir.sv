/*
:name: test_include_nested_in_incdir
:description: A file found through an include directory can include another file of that directory by its name alone (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:incdirs: incdirs_nested_ch22
:expected_stdout: @test_include_nested_in_incdir.expected
*/
// IEEE 1800-2023 §22.4: a relative file name in double quotes is looked for in
// the current working directory and then in the locations the user gives. The
// runner gives incdirs_nested_ch22 as an include directory (:incdirs:); the
// outer file found there includes the inner one by its name alone, which the
// same search finds, since the runners run each test in an empty temporary
// directory.

`include "incdirs_nested_outer.svh"

module test_include_nested_in_incdir;
  initial $display("outer=%0d inner=%0d", `NESTED_OUTER, `NESTED_INNER);
endmodule
