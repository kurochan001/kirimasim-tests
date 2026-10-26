/*
:name: test_illegal_local_protected_member
:description: a member cannot be both local and protected
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.18
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the property declaration carries both local and protected
:expected_stderr_regex: test_illegal_local_protected_member\.sv:19:
*/
// IEEE 1800-2023 8.18: a local member and a protected member are alternative
// encapsulation qualifiers, and a member cannot repeat or combine them. The
// marked declaration gives one property both, which a tool has to reject.

class both_c;
  local protected int value; // illegal: local and protected together
endclass

module test_illegal_local_protected_member;
  both_c c;
  initial c = new;
endmodule
