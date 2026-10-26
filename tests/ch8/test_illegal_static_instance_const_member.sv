/*
:name: test_illegal_static_instance_const_member
:description: an instance constant class property cannot be declared static
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.19
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a const property without an initializer is declared static
:expected_stderr_regex: test_illegal_static_instance_const_member\.sv:20:
*/
// IEEE 1800-2023 8.19: a const class property without a declaration
// initializer is an instance constant assigned once in its constructor, and an
// instance constant cannot be static. The marked declaration is static, which
// a tool has to reject.

class static_const_c;
  static const int size; // illegal: an instance constant cannot be static
endclass
