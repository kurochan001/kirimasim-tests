/*
:name: test_illegal_pulldown_strength1_only
:description: A pulldown gate can have no strength, only a strength0 or both strengths, so a pulldown with only a strength1 is illegal (IEEE 1800-2023 Section 28.3.2)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the pulldown p4 has only the strength1 specification pull1
:expected_stderr_regex: test_illegal_pulldown_strength1_only\.sv:27:
*/
// IEEE 1800-2023 §28.3.2: the pulldown gate shall have no strength
// specification, only a strength0 specification, or both a strength1 and a
// strength0 specification. p1, p2 and p3 use these three forms, which are
// legal; p4 has only a strength1.
// The 5.052 release of Verilator does not support strengths on pulldown gates
// ("Unsupported: pulldown strength" on the legal p2 and p3), which does not
// count.

module test_illegal_pulldown_strength1_only;
  wire w1, w2, w3, w4;
  pulldown p1 (w1);
  pulldown (weak0) p2 (w2);
  pulldown (pull1, supply0) p3 (w3);
  pulldown (pull1) p4 (w4);   // illegal: a pulldown with only a strength1
  initial #1 $display("%v %v %v", w1, w2, w3);
endmodule
