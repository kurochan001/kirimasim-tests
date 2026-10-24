/*
:name: test_illegal_strength_highz1_highz0_on_assign
:description: The drive strength of a continuous assignment cannot be highz for both values, here in the order (highz1, highz0), while (highz1, pull0) is legal (IEEE 1800-2023 Section 28.11)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the continuous assignment to w_bad has the drive strength (highz1, highz0)
:expected_stderr_regex: test_illegal_strength_highz1_highz0_on_assign\.sv:26:
*/
// IEEE 1800-2023 §28.11: the strength combinations (highz0, highz1) and
// (highz1, highz0) are illegal; the order of the two components does not
// matter. The assignment to w_ok uses highz1 with pull0, which is legal; the
// assignment to w_bad uses highz1 with highz0.
// The 5.052 release of Verilator does not support highz strengths and stops
// with "Unsupported: highz strength" on the legal assignment as well, so its
// error on the illegal line does not count.

module test_illegal_strength_highz1_highz0_on_assign;
  logic a = 1'b0;
  wire w_ok, w_bad;
  assign (highz1, pull0) w_ok = a;
  assign (highz1, highz0) w_bad = a;   // illegal: both strengths are highz
  initial #1 $display("%v", w_ok);
endmodule
