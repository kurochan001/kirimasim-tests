/*
:name: test_illegal_final_class_extends
:description: a class declared final cannot be extended
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the subclass extends a class declared final
:expected_stderr_regex: test_illegal_final_class_extends\.sv:21:
*/
// IEEE 1800-2023 8.13: a class declared with the final qualifier cannot be
// extended, so deriving from it is an error. The marked declaration extends
// the final class, which a tool has to reject.

class :final sealed_class;
endclass

class illegal_child extends sealed_class; // illegal: sealed_class is final
endclass

module test_illegal_final_class_extends;
  illegal_child c;
  initial c = new;
endmodule
