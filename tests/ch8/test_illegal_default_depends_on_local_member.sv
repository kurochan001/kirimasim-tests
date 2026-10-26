/*
:name: test_illegal_default_depends_on_local_member
:description: default expansion is illegal when a superclass constructor default expression refers to a local member
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the default keyword expands a superclass argument whose default names a local member
:expected_stderr_regex: test_illegal_default_depends_on_local_member\.sv:27:
*/
// IEEE 1800-2023 8.17: it is an error to use the default keyword if the
// default value of a superclass constructor argument refers to a local member.
// The base constructor default names its local member m, and the marked
// subclass constructor uses default, which a tool has to reject.

class local_base;
  local int m;

  function new(int x = m);
  endfunction
endclass

class local_child extends local_base;
  function new(default); // illegal: the expanded default uses local m
  endfunction
endclass

module test_illegal_default_depends_on_local_member;
  local_child c;
  initial c = new(1);
endmodule
