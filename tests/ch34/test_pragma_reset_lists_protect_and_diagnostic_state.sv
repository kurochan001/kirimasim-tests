/*
:name: test_pragma_reset_lists_protect_and_diagnostic_state
:description: Reset one pragma without changing another, then reset both by name
:tags: ch34
:type: simulation
:lrm: 1800-2023 34.5.9.2 22.11 22.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: pragma_selective_reset_top
:expected_stdout: selective reset source compiled
*/

module diagnostics_at_start;
  ; // initial warning
endmodule

`pragma diagnostic ignore="-Wempty-member"
`pragma protect encoding=(enctype="base64", bytes=2)
`pragma reset protect
`pragma protect data_public_key
?first

module diagnostics_after_selective_reset;
  ; // selective warning
endmodule

`pragma protect encoding=(enctype="base64", bytes=2)
`pragma reset protect, diagnostic
`pragma protect data_public_key
?both

module pragma_selective_reset_top;
  ; // restored warning
  initial $display("selective reset source compiled");
endmodule
