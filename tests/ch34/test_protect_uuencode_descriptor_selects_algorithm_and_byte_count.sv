/*
:name: test_protect_uuencode_descriptor_selects_algorithm_and_byte_count
:description: A uuencode block uses the named algorithm and the count of original bytes
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: protect_state_top
:expected_stdout: protect state: 29
*/

`pragma protect begin_protected
`pragma protect encoding=(enctype="uuencode", bytes=3)
`pragma protect data_block
#04)#
`pragma protect end_protected

module protect_state_top;
  localparam int VALUE = 29;
  initial $display("protect state: %0d", VALUE);
endmodule
