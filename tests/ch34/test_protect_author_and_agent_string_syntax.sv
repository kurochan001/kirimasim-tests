/*
:name: test_protect_author_and_agent_string_syntax
:description: Author, encryption agent and comment pragmas keep quoted punctuation in string arguments
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

`pragma protect author="Example Author"
`pragma protect author_info="document build 2"
`pragma protect encrypt_agent="Example Tool"
`pragma protect encrypt_agent_info="release (2023)"
`pragma protect comment="do not treat begin, end, or reset as directives"

module protect_syntax_top;
  localparam int visible_value = 23;
  initial $display("protect syntax: %0d", visible_value);
endmodule
