/*
:name: test_protect_two_envelopes_close_independently
:description: Each of two encryption envelopes closes before the next one begins
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
module protect_helper; endmodule
`pragma protect end
`pragma protect begin
module protect_state_top;
  localparam int VALUE = 29;
  initial $display("protect state: %0d", VALUE);
endmodule
`pragma protect end
