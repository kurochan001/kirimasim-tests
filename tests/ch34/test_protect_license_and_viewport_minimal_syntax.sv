/*
:name: test_protect_license_and_viewport_minimal_syntax
:description: Licenses accept their three required strings and viewport accepts two named strings
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.28.1 34.5.29.1 34.5.32.1
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
`pragma protect decrypt_license=(library="sample", entry="acquire", feature="demo")
`pragma protect runtime_license=(library="sample", entry="acquire", feature="demo")
`pragma protect viewport=(object="protect_syntax_top.visible_value", access="read")
`pragma protect end

module protect_syntax_top;
  localparam int visible_value = 23;
  initial $display("protect syntax: %0d", visible_value);
endmodule
