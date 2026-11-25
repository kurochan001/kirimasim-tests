/*
:name: test_protect_sequence_split_changes_active_encoding
:description: Separate protect directives update the encoding before the following payload
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: protect_state_top
:expected_stdout: protect state: 29
*/

`pragma protect begin_protected
`pragma protect encoding=(enctype="base64", bytes=3)
`pragma protect encoding=(enctype="uuencode", bytes=3)
`pragma protect data_block
#04)#
`pragma protect end_protected

module protect_state_top;
  localparam int VALUE = 29;
  initial $display("protect state: %0d", VALUE);
endmodule
