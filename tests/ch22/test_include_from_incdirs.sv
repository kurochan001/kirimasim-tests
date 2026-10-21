/*
:name: test_include_from_incdirs
:description: `include of a file name in double quotes finds the file in an include directory that the tool is given (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.4 22.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:incdirs: incdirs_ch22
:expected_stdout: @test_include_from_incdirs.expected
*/
// IEEE 1800-2023 §22.4: a relative file name in double quotes is looked for
// in the current working directory of the compiler and then in the locations
// the user gives. The included file is in the directory incdirs_ch22 next to
// the test, which the runner gives as an include directory (:incdirs:); the
// runners run each test in an empty temporary directory, so that is the only
// place that has it. The macros it defines (22.5.1) are then used here.

`include "incdirs_values.svh"

module test_include_from_incdirs;
  initial $display("WIDTH=%0d NAME=%s", `INCDIRS_WIDTH, `INCDIRS_NAME);
endmodule
