/*
:name: test_illegal_override_return_type_mismatch
:description: a virtual function override must return a matching type or a derived class type
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the override returns longint where the prototype returns int
:expected_stderr_regex: test_illegal_override_return_type_mismatch\.sv:26:
*/
// IEEE 1800-2023 8.20: the return type of a virtual function override shall
// be a matching type of the superclass return type or a derived class type of
// it. longint is not a matching type of int, so the marked override is
// illegal.

class base_ret;
  virtual function int f();
    return 1;
  endfunction
endclass

class child_ret extends base_ret;
  virtual function longint f(); // illegal: return type is not matching
    return 2;
  endfunction
endclass

module test_illegal_override_return_type_mismatch;
  child_ret c;
  initial c = new;
endmodule
