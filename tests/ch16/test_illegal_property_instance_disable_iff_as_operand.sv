/*
:name: test_illegal_property_instance_disable_iff_as_operand
:description: a property instance used as the operand of a property operator cannot bring in a disable iff (IEEE 1800-2023 Section 16.12.1)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the consequent of the implication in a_bad is the property p_dis, whose body has a disable iff
:expected_stderr_regex: test_illegal_property_instance_disable_iff_as_operand\.sv:33:
*/
// IEEE 1800-2023 §16.12.1: an instance of a named property is legal only if
// its body, with the actuals substituted, is legal where the instance
// stands; so an instance used as an operand of an operator that builds a
// property cannot introduce a disable iff, which may only head a
// property_spec. a_top asserts p_dis itself, and a_nodis uses p_plain,
// which has no disable iff, as the consequent; a_bad uses p_dis there.
// Icarus Verilog 13.0 does not support concurrent assertions, and the 5.052
// release of Verilator stops with an internal fault; neither counts.

module test_illegal_property_instance_disable_iff_as_operand;
  logic clk = 0, rst = 0, a = 0, b = 0, c = 0;
  property p_dis;
    @(posedge clk) disable iff (rst) b |=> c;
  endproperty
  property p_plain;
    b |=> c;
  endproperty
  a_top: assert property (p_dis);
  a_nodis: assert property (@(posedge clk) a |-> p_plain);
  a_bad: assert property (@(posedge clk) a |-> p_dis);   // illegal
endmodule
