/*
:name: test_illegal_three_delays_on_n_output_gate
:description: A three-value delay on an n-output gate is rejected beside its legal two-value form
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3 28.3.3 A.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an n-output gate declares a third delay value
:expected_stderr_regex: test_illegal_three_delays_on_n_output_gate\.sv:20:(?:\d+:)?[^\n]*(?i:(?:delay|syntax|unexpected|expected))
*/
module test_illegal_three_delays_on_n_output_gate;
  wire x = 1'b1;
  wire driven = 1'b0;
  wire ok, other, bad, bad_other, off;
  bufif1 #(2, 3, 5) allowed_delay3(off, x, 1'b0);
  not #(2, 3) control(ok, other, x);
  not #(2, 3, 5) invalid(bad, bad_other, x);
endmodule
