/*
:name: test_illegal_dollar_parameter_in_queue_select
:description: a parameter whose value is $ cannot be used in a queue context such as a queue select (IEEE 1800-2023 Section 6.20.7)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the parameter P, whose value is $, is used as the index of the queue select q[P]
:expected_stderr_regex: test_illegal_dollar_parameter_in_queue_select\.sv:39:
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
// The legal part assigns $ to the parameter P and P to the parameter Q, and
// prints $isunbounded of both, the last and the next to last element of the
// queue q through q[$] and q[$-1], and whether 7 is in the range [5:$]: 1 1 9 7
// 1. The last statement selects q[P] with the parameter P, whose value is $.
// Icarus Verilog 13.0 does not support $ as the value of a parameter and
// reports syntax errors on the legal declarations as well, which do not count.
// The 5.052 release accepts the design.

module test_illegal_dollar_parameter_in_queue_select;
  parameter P = $;
  parameter Q = P;
  int q [$] = '{4, 7, 9};
  int k;
  initial begin
    $display("%0d %0d %0d %0d %0d", $isunbounded(P), $isunbounded(Q), q[$], q[$-1],
             7 inside {[5:$]});
    k = q[P];   // illegal: a $ parameter in a queue select
  end
endmodule
