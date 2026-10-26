/*
:name: test_illegal_modport_output_expression
:description: a modport expression of an output port is not a variable lvalue (IEEE 1800-2023 Section 25.5.4)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output modport expression .P(r + 1) is not a variable lvalue
:expected_stderr_regex: test_illegal_modport_output_expression\.sv:20:
*/
// A modport expression is self-determined and shall be legal for the
// port kind. An output port needs a variable lvalue, but r + 1 is an
// expression that cannot be driven.

interface i;
  logic [7:0] r;
  modport mp (output .P(r + 1));   // illegal: not an lvalue
endinterface

module t;
  i u();
endmodule
