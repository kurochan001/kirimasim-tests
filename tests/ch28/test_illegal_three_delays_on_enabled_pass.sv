/*
:name: test_illegal_three_delays_on_enabled_pass
:description: A three-value delay on an enabled pass switch is rejected beside its legal two-value form
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3 28.3.3 A.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an enabled pass switch declares a third delay value
:expected_stderr_regex: test_illegal_three_delays_on_enabled_pass\.sv:20:(?:\d+:)?[^\n]*(?i:(?:delay|syntax|unexpected|expected))
*/
module test_illegal_three_delays_on_enabled_pass;
  wire x = 1'b1;
  wire driven = 1'b0;
  wire ok, other, bad, bad_other, off;
  bufif1 #(2, 3, 5) allowed_delay3(off, x, 1'b0);
  tranif1 #(2, 3) control(ok, driven, x);
  tranif1 #(2, 3, 5) invalid(bad, driven, x);
endmodule
