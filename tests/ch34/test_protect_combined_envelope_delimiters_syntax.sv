/*
:name: test_protect_combined_envelope_delimiters_syntax
:description: Comma-separated begin, end and reset expressions parse on shared pragma lines
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.1.1 34.5.2.1 34.5.31.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: protect_syntax_top
:expected_stdout: protect syntax: 23
*/
// The syntax checker compiles this fixture and mutates one pragma at a time.
// The display also checks that ordinary source after the directives parses.

`pragma protect reset, begin
`pragma protect end, reset

module protect_syntax_top;
  localparam int visible_value = 23;
  initial $display("protect syntax: %0d", visible_value);
endmodule
