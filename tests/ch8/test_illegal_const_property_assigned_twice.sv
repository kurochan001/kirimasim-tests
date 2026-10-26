/*
:name: test_illegal_const_property_assigned_twice
:description: a const class property without an initializer can be assigned only once, in its constructor
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.19
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constructor assigns the instance constant twice
:expected_stderr_regex: test_illegal_const_property_assigned_twice\.sv:24:
*/
// IEEE 1800-2023 8.19: an instance constant is a const class property without
// a declaration initializer; it may be assigned a value at run time only once
// in the corresponding class constructor. The marked second assignment in the
// constructor is illegal.

class once_c;
  const int size;

  function new();
    size = 1;
    size = 2; // illegal: the instance constant is already assigned
  endfunction
endclass

module test_illegal_const_property_assigned_twice;
  once_c c;
  initial c = new;
endmodule
