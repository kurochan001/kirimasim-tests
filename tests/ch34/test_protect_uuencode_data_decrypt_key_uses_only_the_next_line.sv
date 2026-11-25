/*
:name: test_protect_uuencode_data_decrypt_key_uses_only_the_next_line
:description: A uuencode data decryption key occupies the line immediately before ordinary source
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.14.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: protect_state_top
:expected_stdout: protect state: 29
*/

`pragma protect begin
`pragma protect encoding=(enctype="uuencode", bytes=3)
`pragma protect data_decrypt_key
#04)#
module protect_state_top;
  localparam int VALUE = 29;
  initial $display("protect state: %0d", VALUE);
endmodule
`pragma protect end
