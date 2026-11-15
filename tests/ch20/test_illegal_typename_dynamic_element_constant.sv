/*
:name: test_illegal_typename_dynamic_element_constant
:description: an elaboration-time $typename refers to an element of a dynamic array (IEEE 1800-2023 Section 20.6.1)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the localparam B is $typename of dyn[0], an element of the dynamic array dyn
:expected_stderr_regex: test_illegal_typename_dynamic_element_constant\.sv:30:
*/
// IEEE 1800-2023 §20.6.1: when $typename is used as an elaboration-time
// constant, its expression shall contain no hierarchical reference and no
// reference to an element of a dynamic object. The localparam A is
// $typename of fixed[0], an element of a fixed-size array of this module,
// which is legal; the localparam B is $typename of dyn[0], an element of a
// dynamic array, which is the one error. With fixed[1] in place of dyn[0]
// the design is legal.
// Icarus Verilog 13.0 reports both localparams, also the legal A, as a
// variable in a constant expression, so its error does not count, and the
// 5.054 release of Verilator accepts the design; the cited clause alone
// decides this test.

module test_illegal_typename_dynamic_element_constant;
  byte fixed [2];
  byte dyn [];
  localparam string A = $typename(fixed[0]);
  localparam string B = $typename(dyn[0]);   // illegal: dynamic element
  initial $display("%s %s", A, B);
endmodule
