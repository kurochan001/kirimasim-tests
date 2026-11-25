/*
:name: test_protect_encoding_bytes_and_both_numbers_syntax
:description: Encoding accepts bytes by itself or after a numeric line length
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.9.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: protect_syntax_top
:expected_stdout: protect syntax: 23
*/
// The syntax checker compiles this fixture and mutates one pragma at a time.
// The display also checks that ordinary source after the directives parses.

`pragma protect encoding=(enctype="base64", bytes=3)
`pragma protect encoding=(enctype="base64", line_length=76, bytes=6)

module protect_syntax_top;
  localparam int visible_value = 23;
  initial $display("protect syntax: %0d", visible_value);
endmodule
