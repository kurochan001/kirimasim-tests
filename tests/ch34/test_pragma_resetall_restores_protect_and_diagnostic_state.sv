/*
:name: test_pragma_resetall_restores_protect_and_diagnostic_state
:description: Reset all pragmas after changing both the payload encoding and warning policy
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.9.2 22.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: pragma_resetall_top
:expected_stdout: resetall source compiled
*/

module diagnostics_at_start;
  ; // initial warning
endmodule

`pragma diagnostic ignore="-Wempty-member"
`pragma protect encoding=(enctype="base64", bytes=2)
`pragma protect data_public_key
QUI=

module diagnostics_before_resetall;
  ; // configured warning
endmodule

`pragma resetall
`pragma protect data_public_key
?all

module pragma_resetall_top;
  ; // restored warning
  initial $display("resetall source compiled");
endmodule
