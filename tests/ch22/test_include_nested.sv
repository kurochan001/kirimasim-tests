/*
:name: test_include_nested
:description: An included file can itself include another file, and declarations from both levels are visible where the outer file is included (IEEE 1800-2023 Section 22.4)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: include_nested_outer.svh include_nested_inner.svh
:expected_stdout: @test_include_nested.expected
*/
// IEEE 1800-2023 §22.4: an `include directive can appear in a file that is
// itself included; tools allow at least 15 levels. The outer file includes the
// inner one before using its parameter, so both parameters are declared in the
// module.

module test_include_nested;
  `include "include_nested_outer.svh"

  initial $display("inner=%0d outer=%0d", INCLUDE_NESTED_INNER, INCLUDE_NESTED_OUTER);
endmodule
