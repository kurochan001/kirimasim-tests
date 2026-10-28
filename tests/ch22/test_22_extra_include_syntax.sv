/*
:name: test_22_extra_include_syntax
:description: `include accepts a file name in double quotes before the module and between the items of a module, and searches the directories the user gives (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.4 22.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: test_22_extra_include_syntax_quoted.svh test_22_extra_include_syntax_body.svh
:incdirs: test_22_extra_include_syntax_angle
:expected_stdout: @test_22_extra_include_syntax.expected
*/
// IEEE 1800-2023 §22.4: the syntax of `include is `include "filename" or
// `include <filename>, and the directive can be specified anywhere within the
// SystemVerilog source description. The quoted file name is looked for in the
// current working directory and in the locations the user gives; the angle
// bracket form searches only the implementation-dependent location for files
// that belong to the language, so an include directory that a design gives
// cannot make an angle-bracket include work. This test therefore uses the
// quoted form for all three files, one of them found through :incdirs:, and
// all three contribute to the one design. Here the quoted form appears on a
// line of its own before the module and between the items of the module.
// The expected output was recorded with Verilator 5.052; Icarus Verilog 13.0
// does not have the angle-bracket form that an earlier version used.

`include "test_22_extra_include_syntax_quoted.svh"
`include "test_22_extra_include_syntax_angle.svh"

module test_22_extra_include_syntax;
  `include "test_22_extra_include_syntax_body.svh"

  initial $display("width=%0d name=%s body=%0d", `QUOTED_WIDTH, `ANGLE_NAME, BODY_VALUE);
endmodule
