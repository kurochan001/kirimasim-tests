/*
:name: test_protect_license_optional_fields_and_viewport_string_syntax
:description: Both license tuples accept optional exit and match and viewport preserves spaces in strings
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
`pragma protect decrypt_license=(library="lib", entry="get", feature="demo", match=1)
`pragma protect runtime_license=(library="lib", entry="get", feature="demo", exit="done")
`pragma protect decrypt_license=(library="lib", entry="get", feature="demo", exit="done", match=1)
`pragma protect runtime_license=(library="lib", entry="get", feature="demo", exit="done", match=1)
`pragma protect viewport=(object="protect_syntax_top.visible_value", access="read only")
`pragma protect end

module protect_syntax_top;
  localparam int visible_value = 23;
  initial $display("protect syntax: %0d", visible_value);
endmodule
