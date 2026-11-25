/*
:name: test_protect_bare_keys_and_blocks_with_single_line_payloads
:description: Bare public key, session key and block directives precede a one-line encoded payload
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.13.1 34.5.14.1 34.5.15.1 34.5.19.1 34.5.20.1 34.5.22.1 34.5.26.1 34.5.27.1
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
`pragma protect encoding=(enctype="base64", bytes=3)
`pragma protect data_public_key
QUJD
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect encoding=(enctype="base64", bytes=3)
`pragma protect data_decrypt_key
QUJD
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect encoding=(enctype="base64", bytes=3)
`pragma protect digest_public_key
QUJD
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect encoding=(enctype="base64", bytes=3)
`pragma protect digest_decrypt_key
QUJD
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect encoding=(enctype="base64", bytes=3)
`pragma protect key_public_key
QUJD
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect encoding=(enctype="base64", bytes=3)
`pragma protect data_block
QUJD
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect encoding=(enctype="base64", bytes=3)
`pragma protect digest_block
QUJD
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect encoding=(enctype="base64", bytes=3)
`pragma protect key_block
QUJD
`pragma protect end_protected

module protect_syntax_top;
  localparam int visible_value = 23;
  initial $display("protect syntax: %0d", visible_value);
endmodule
