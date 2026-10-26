/*
:name: test_illegal_constructor_default_outside_subclass
:description: the default constructor argument keyword is legal only in a subclass
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a class without a superclass uses the default constructor argument
:expected_stderr_regex: test_illegal_constructor_default_outside_subclass\.sv:20:
*/
// IEEE 1800-2023 8.17: the default keyword in a constructor argument list
// expands to the superclass constructor arguments, so the class shall be a
// subclass. The marked constructor of a class with no superclass uses default,
// which a tool has to reject.

class no_parent;
  function new(default); // illegal: the class has no superclass
  endfunction
endclass

module test_illegal_constructor_default_outside_subclass;
  no_parent p;
  initial p = new;
endmodule
