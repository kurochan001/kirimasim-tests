/*
:name: test_illegal_cg_cross_set_type
:description: a cross bin set expression yields a queue of integers (IEEE 1800-2023 Section 19.6.1.4)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the bin one of the cross is set from a queue of integers, not from the cross CrossQueueType
:expected_stderr_regex: test_illegal_cg_cross_set_type\.sv:28:
*/
// A cross set expression shall yield the enclosing cross's
// CrossQueueType, whose elements are CrossValType. A queue of single
// integers is not that type.
//
// Icarus Verilog 13.0 does not implement covergroups; its cascading
// syntax errors fall on every line of the construct, including the line
// named below, so they are no evidence for the rule there. The cited
// clause alone decides this test.

module test_illegal_cg_cross_set_type;
  covergroup cg(input int a, input int b);
    pa: coverpoint a;
    pb: coverpoint b;
    cr: cross pa, pb {
      bins one = '{1, 2, 3};   // illegal: not CrossQueueType
    }
  endgroup
endmodule
