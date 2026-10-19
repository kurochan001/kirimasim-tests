/*
:name: test_pragma_unrecognized
:description: `pragma directives with names that the tool does not recognize, with or without pragma expressions, have no effect on the design (IEEE 1800-2023 Section 22.11)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.11
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pragma_unrecognized.expected
*/
// IEEE 1800-2023 §22.11: a `pragma directive names a pragma, optionally
// followed by pragma expressions: keywords, keyword = value pairs, and values
// that are numbers, strings, identifiers or parenthesized lists of
// expressions. A pragma whose name the implementation does not recognize has
// no effect on the source text. The pragmas below use made-up names, both
// outside and inside the module, and the design runs as written.

`pragma kt_made_up_option
`pragma kt_made_up_hint level = 3, (alpha, "beta"), 12, mode

module test_pragma_unrecognized;
  int n = 2;
`pragma kt_made_up_inside on = (1, 2)
  initial $display("n = %0d", n * 21);
endmodule
