/*
:name: test_illegal_gate_strength_single_component
:description: The drive strength of a gate other than pullup and pulldown has a strength0 and a strength1 specification in either order, so an and gate with only a strength1 is illegal (IEEE 1800-2023 Section 28.3.2)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the and gate g3 has only the strength1 specification strong1
:expected_stderr_regex: test_illegal_gate_strength_single_component\.sv:25:
*/
// IEEE 1800-2023 §28.3.2: except for pullup and pulldown, the drive strength
// specification of a gate instance shall have a strength1 and a strength0
// specification, separated by a comma, in either order, within parentheses.
// g1 writes (weak0, pull1) and g2 writes (pull1, weak0), both legal; g3 has
// only strong1.

module test_illegal_gate_strength_single_component;
  logic a = 1'b1, b = 1'b1;
  wire y1, y2, y3;
  and (weak0, pull1) g1 (y1, a, b);
  and (pull1, weak0) g2 (y2, a, b);
  and (strong1) g3 (y3, a, b);   // illegal: only one strength
  initial #1 $display("%v %v", y1, y2);
endmodule
