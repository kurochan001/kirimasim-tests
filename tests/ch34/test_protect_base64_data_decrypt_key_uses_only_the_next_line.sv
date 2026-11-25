/*
:name: test_protect_base64_data_decrypt_key_uses_only_the_next_line
:description: A padded base64 data decryption key occupies the line immediately before ordinary source
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
`pragma protect encoding=(enctype="base64", bytes=2)
`pragma protect data_decrypt_key
QUI=
module protect_state_top;
  localparam int VALUE = 29;
  initial $display("protect state: %0d", VALUE);
endmodule
`pragma protect end
