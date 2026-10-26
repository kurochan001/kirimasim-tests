/*
:name: test_illegal_override_argument_type_mismatch
:description: a virtual function override must have the argument types of the base prototype
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the override takes byte where the base prototype takes int
:expected_stderr_regex: test_illegal_override_argument_type_mismatch\.sv:26:
*/
// IEEE 1800-2023 8.20: a virtual method override shall have matching argument
// types, identical argument names, qualifiers and directions to the prototype.
// The marked override changes the argument type from int to byte, which a tool
// has to reject.

class base_arg;
  virtual function int f(int a);
    return a;
  endfunction
endclass

class child_arg extends base_arg;
  virtual function int f(byte a); // illegal: argument type differs
    return a + 1;
  endfunction
endclass

module test_illegal_override_argument_type_mismatch;
  child_arg c;
  initial c = new;
endmodule
