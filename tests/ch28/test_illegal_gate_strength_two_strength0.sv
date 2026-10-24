/*
:name: test_illegal_gate_strength_two_strength0
:description: The drive strength of a gate has one strength0 and one strength1 specification, so (strong0, weak0) on an or gate is illegal, while (strong0, weak1) is legal (IEEE 1800-2023 Section 28.3.2)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the drive strength of the or gate g2 has two strength0 specifications and no strength1
:expected_stderr_regex: test_illegal_gate_strength_two_strength0\.sv:24:
*/
// IEEE 1800-2023 §28.3.2: the drive strength of a gate instance other than
// pullup and pulldown shall have a strength1 specification, which is supply1,
// strong1, pull1 or weak1, and a strength0 specification, which is supply0,
// strong0, pull0 or weak0. g1 has strong0 and weak1, which is legal; g2 has
// strong0 and weak0.

module test_illegal_gate_strength_two_strength0;
  logic a = 1'b0, b = 1'b0;
  wire y1, y2;
  or (strong0, weak1) g1 (y1, a, b);
  or (strong0, weak0) g2 (y2, a, b);   // illegal: two strength0 specifications
  initial #1 $display("%v", y1);
endmodule
