/*
:name: test_protect_open_envelope_matches_its_end_after_source
:description: The end after ordinary source closes the matching begin and allows another envelope
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

`pragma protect begin
module protect_state_top;
  localparam int VALUE = 29;
  initial $display("protect state: %0d", VALUE);
endmodule
`pragma protect end
`pragma protect begin, end
