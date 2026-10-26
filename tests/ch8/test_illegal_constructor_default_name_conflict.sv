/*
:name: test_illegal_constructor_default_name_conflict
:description: an explicit constructor argument cannot share a name with a superclass constructor argument when default is used
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the explicit argument name repeats the superclass argument name
:expected_stderr_regex: test_illegal_constructor_default_name_conflict\.sv:27:
*/
// IEEE 1800-2023 8.17: no argument in a constructor argument list that uses
// default shall have the same name as an argument of the superclass
// constructor. The marked list adds an argument named x although the
// superclass constructor already has x, which a tool has to reject. An
// argument following default takes the default input direction and the default
// logic type, so it is written without a separate type.

class base_n;
  function new(int x);
  endfunction
endclass

class child_n extends base_n;
  function new(default, x); // illegal: x repeats the superclass argument name
  endfunction
endclass

module test_illegal_constructor_default_name_conflict;
  child_n c;
  initial c = new(1);
endmodule
