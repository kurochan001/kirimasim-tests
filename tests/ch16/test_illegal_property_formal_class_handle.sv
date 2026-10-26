/*
:name: test_illegal_property_formal_class_handle
:description: A typed formal argument of a named property shall be property, sequence, event, or a type allowed in 16.6, so a class handle formal that is not cast compatible with an integral type is an error (IEEE 1800-2023 Section 16.12.18)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.18 16.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: property p_bad declares the formal argument h of the class handle type c_handle
:expected_stderr_regex: test_illegal_property_formal_class_handle\.sv:33:
*/
// IEEE 1800-2023 §16.12.18: if a formal argument of a named property is
// typed, the type shall be property, sequence, event, or one of the types
// allowed in 16.6. Expressions in concurrent assertions shall be cast
// compatible with an integral type, and a class handle is not. p_ok has an
// int formal and is legal; p_bad has a c_handle formal and is illegal even
// though the body never uses it.

class c_handle;
  int v;
endclass

module test_illegal_property_formal_class_handle;
  logic clk = 0;
  logic a = 1;

  property p_ok(int i);
    @(posedge clk) i;
  endproperty

  property p_bad(c_handle h);   // illegal: class handle formal type
    @(posedge clk) a;
  endproperty

  p1: assert property (p_ok(1));
endmodule
