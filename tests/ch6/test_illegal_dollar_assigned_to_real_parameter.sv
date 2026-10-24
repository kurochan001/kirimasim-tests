/*
:name: test_illegal_dollar_assigned_to_real_parameter
:description: $ can be assigned only to a value parameter of a simple bit vector type; a real parameter cannot have the value $ (IEEE 1800-2023 Section 6.20.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parameter RP of type real is assigned $
:expected_stderr_regex: test_illegal_dollar_assigned_to_real_parameter\.sv:35:
*/
// IEEE 1800-2023 §6.20.7: $ is a special constant that can be used only in the
// contexts the clause lists, among them the dimension [$] of a queue, a queue
// select, where it is the last element, an open end of a value range such as
// [lo:$], and the value of a parameter. It shall be used only as a whole
// self-contained expression, except in a queue select, where operators may be
// applied to it (such as q[$-1]). $ can be assigned to a value parameter of a
// simple bit vector type, and such a parameter can then be used only where $
// itself can be, except in queue contexts; it can be assigned to another
// parameter.
// The legal part assigns $ to the parameter P, which has no explicit type, and
// to the parameter IP of type int, a simple bit vector type, and prints
// $isunbounded of both: 1 1. The parameter RP of type real is assigned $.
// Icarus Verilog 13.0 does not support $ as the value of a parameter and
// reports syntax errors on the legal declarations as well, which do not count.
// The 5.052 release reports the last declaration as an unsupported use of $,
// which does not count.

module test_illegal_dollar_assigned_to_real_parameter;
  parameter P = $;
  parameter int IP = $;
  initial $display("%0d %0d", $isunbounded(P), $isunbounded(IP));
  parameter real RP = $;   // illegal: $ for a real parameter
endmodule
