/*
:name: test_22_extra_include_syntax
:description: `include accepts a file name in double quotes or in angle brackets, at the top of the source and between the items of a module (IEEE 1800-2023 Section 22.4)
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
// that belong to the language (see the separate angle-search requirement).
// Here the quoted form appears on a line of its own before the module and
// between the items of the module, and the angle form appears before the
// module; all three included files contribute to the one design. Icarus
// Verilog 13.0 has no angle-bracket form ("malformed `include directive"), so
// the expected output is the one Verilator 5.052 produces.

`include "test_22_extra_include_syntax_quoted.svh"
`include <test_22_extra_include_syntax_angle.svh>

module test_22_extra_include_syntax;
  `include "test_22_extra_include_syntax_body.svh"

  initial $display("width=%0d name=%s body=%0d", `QUOTED_WIDTH, `ANGLE_NAME, BODY_VALUE);
endmodule
