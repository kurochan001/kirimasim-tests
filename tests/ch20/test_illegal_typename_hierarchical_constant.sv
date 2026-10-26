/*
:name: test_illegal_typename_hierarchical_constant
:description: an elaboration-time $typename uses a hierarchical reference (IEEE 1800-2023 Section 20.6.1)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.6.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the elaboration-time constant T is $typename of the hierarchical reference u.sig
:expected_stderr_regex: test_illegal_typename_hierarchical_constant\.sv:23:
*/
// $typename returns the self-determined type of its expression without
// evaluating it. In an elaboration-time constant the expression shall not
// contain a hierarchical reference, but this one names u.sig.

module leaf;
  logic [3:0] sig;
endmodule
module test_illegal_typename_hierarchical_constant;
  leaf u();
  localparam string T = $typename(u.sig);   // illegal: hierarchical
  initial $display(T);
endmodule
