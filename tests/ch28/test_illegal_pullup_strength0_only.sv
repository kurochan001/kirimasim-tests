/*
:name: test_illegal_pullup_strength0_only
:description: A pullup gate can have no strength, only a strength1 or both strengths, so a pullup with only a strength0 is illegal (IEEE 1800-2023 Section 28.3.2)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the pullup p4 has only the strength0 specification strong0
:expected_stderr_regex: test_illegal_pullup_strength0_only\.sv:27:
*/
// IEEE 1800-2023 §28.3.2: the pullup gate shall have no strength
// specification, only a strength1 specification, or both a strength1 and a
// strength0 specification. p1, p2 and p3 use these three forms, which are
// legal; p4 has only a strength0.
// The 5.052 release of Verilator does not support strengths on pullup gates
// ("Unsupported: pullup strength" on the legal p2 and p3), which does not
// count.

module test_illegal_pullup_strength0_only;
  wire w1, w2, w3, w4;
  pullup p1 (w1);
  pullup (weak1) p2 (w2);
  pullup (strong1, strong0) p3 (w3);
  pullup (strong0) p4 (w4);   // illegal: a pullup with only a strength0
  initial #1 $display("%v %v %v", w1, w2, w3);
endmodule
