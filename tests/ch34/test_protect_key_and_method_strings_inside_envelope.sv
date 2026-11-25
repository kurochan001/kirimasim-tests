/*
:name: test_protect_key_and_method_strings_inside_envelope
:description: Data, digest and key metadata retain spaces in assignments within an envelope
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.10.1 34.5.11.1 34.5.12.1 34.5.16.1 34.5.17.1 34.5.18.1 34.5.21.1 34.5.23.1 34.5.24.1 34.5.25.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: protect_syntax_top
:expected_stdout: protect syntax: 23
*/
// The syntax checker compiles this fixture and mutates one pragma at a time.
// The display also checks that ordinary source after the directives parses.

`pragma protect begin_protected
`pragma protect data_keyowner = "data holder"
`pragma protect data_method = "aes128-cbc"
`pragma protect data_keyname = "data-2023"
`pragma protect digest_keyowner = "digest holder"
`pragma protect digest_key_method = "rsa"
`pragma protect digest_keyname = "digest-2023"
`pragma protect digest_method = "sha256"
`pragma protect key_keyowner = "exchange holder"
`pragma protect key_method = "rsa"
`pragma protect key_keyname = "exchange-2023"
`pragma protect end_protected

module protect_syntax_top;
  localparam int visible_value = 23;
  initial $display("protect syntax: %0d", visible_value);
endmodule
