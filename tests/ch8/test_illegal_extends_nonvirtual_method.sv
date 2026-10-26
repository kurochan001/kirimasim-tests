/*
:name: test_illegal_extends_nonvirtual_method
:description: a method marked extends must override a virtual method of a base class
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the marked method uses extends although the base method is not virtual
:expected_stderr_regex: test_illegal_extends_nonvirtual_method\.sv:26:
*/
// IEEE 1800-2023 8.20: the extends specifier says that a method is a virtual
// override; specifying it when the base method is not virtual is an error. The
// base method in this design is not virtual, and the marked subclass method
// uses :extends, which a tool has to reject.

class base_nv;
  function int f(int a);
    return a;
  endfunction
endclass

class child_nv extends base_nv;
  function :extends int f(int a); // illegal: base f is not virtual
    return a + 1;
  endfunction
endclass

module test_illegal_extends_nonvirtual_method;
  child_nv c;
  initial c = new;
endmodule
