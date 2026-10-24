/*
:name: test_illegal_drive_strength_highz0_highz1
:description: the drive strength (highz0, highz1) of a continuous assignment is illegal (IEEE 1800-2023 Section 10.3.4)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the continuous assignment to w_bad has the drive strength (highz0, highz1)
:expected_stderr_regex: test_illegal_drive_strength_highz0_highz1\.sv:28:
*/
// IEEE 1800-2023 §10.3.4: a drive strength gives one strength for the value 1
// and one for the value 0, in either order, and highz1 or highz0 may be one of
// them; but (highz1, highz0) and (highz0, highz1) are illegal. The
// assignments to w1 and w2 combine a high-impedance strength with a driving
// one, which is legal; the assignment to w_bad has (highz0, highz1).
// The 5.052 release of Verilator also reports the legal strengths with highz1
// as unsupported, so its error does not count.

module test_illegal_drive_strength_highz0_highz1;
  logic a = 1'b1;
  wire w1, w2, w_bad;

  assign (highz1, strong0) w1 = a;
  assign (weak0, highz1) w2 = a;
  assign (highz0, highz1) w_bad = a;   // illegal: both strengths are high impedance

  initial #1 $display("%v %v", w1, w2);
endmodule
