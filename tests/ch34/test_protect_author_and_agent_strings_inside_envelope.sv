/*
:name: test_protect_author_and_agent_strings_inside_envelope
:description: String arguments including escaped quotes and commas parse inside an encryption envelope
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.5.1 34.5.6.1 34.5.7.1 34.5.8.1 34.5.30.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: protect_syntax_top
:expected_stdout: protect syntax: 23
*/
// The syntax checker compiles this fixture and mutates one pragma at a time.
// The display also checks that ordinary source after the directives parses.

`pragma protect begin
`pragma protect author = "Example \"Author\""
`pragma protect author_info = "a=1, b=2"
`pragma protect encrypt_agent = "Tool / edition 2"
`pragma protect encrypt_agent_info = "quoted \"release\" and spaces"
`pragma protect comment = ""
`pragma protect end

module protect_syntax_top;
  localparam int visible_value = 23;
  initial $display("protect syntax: %0d", visible_value);
endmodule
