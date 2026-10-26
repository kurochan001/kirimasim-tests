/*
:name: test_illegal_weak_reference_scalar_type
:description: weak_reference requires a class type parameter
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.30.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: weak_reference is specialized with the scalar type int
:expected_stderr_regex: test_illegal_weak_reference_scalar_type\.sv:20:
*/
// IEEE 1800-2023 8.30.1: weak_reference is a built-in parameterized class
// whose type parameter T shall be a class type; any other specialization is a
// compilation error. The marked declaration specializes it with int, which a
// tool has to reject.

module test_illegal_weak_reference_scalar_type;
  weak_reference #(int) w; // illegal: int is not a class type
endmodule
