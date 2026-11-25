/*
:name: test_protect_reset_restores_default_before_reconfiguration
:description: A protect reset restores the default encoding before a later directive selects a different encoding
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.31.2 34.5.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: protect_reset_reconfiguration_top
:expected_stdout: protect encoding configured again
*/

`pragma protect encoding=(enctype="base64", bytes=2)
`pragma protect data_public_key
QUI=
`pragma protect reset
`pragma protect data_public_key
?restored
`pragma protect encoding=(enctype="uuencode", bytes=3)
`pragma protect data_public_key
#04)#

module protect_reset_reconfiguration_top;
  initial $display("protect encoding configured again");
endmodule
