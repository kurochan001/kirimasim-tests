/*
:name: test_illegal_recursive_property_negated
:description: not cannot be applied to a property expression that instantiates a recursive property (IEEE 1800-2023 Section 16.12.17)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.17 16.12.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the negation operator not is applied to an instance of the recursive property ack_each
:expected_stderr_regex: test_illegal_recursive_property_negated\.sv:32:
*/
// IEEE 1800-2023 §16.12.17, restriction 1: the negation operator not (§16.12.3)
// and the strong operators shall not be applied to a property expression that
// instantiates a recursive property, so the negation of a recursive property
// cannot be asserted. ack_each(req, ack) needs ack one tick after every req
// from its start on; it is recursive and legal on its own, as its instance
// follows 1'b1 |=> and takes its own formals as actuals. The assertion negates
// an instance of it. Icarus Verilog 13.0 does not support property
// declarations, and Verilator 5.052 does not support recursive properties, so
// the errors they report do not count.

module test_illegal_recursive_property_negated;
  logic clk = 0, rq = 0, ak = 0;
  int fails = 0;

  property ack_each(req, ack);
    (req |=> ack) and (1'b1 |=> ack_each(req, ack));
  endproperty

  a_neg: assert property (@(posedge clk) not ack_each(rq, ak)) else fails++;  // illegal
endmodule
