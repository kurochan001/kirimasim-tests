/*
:name: test_illegal_extends_default_without_default_argument
:description: with extends(default) a user constructor argument list must contain default
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class extends Base(default) but defines a constructor without default
:expected_stderr_regex: test_illegal_extends_default_without_default_argument\.sv:25:
*/
// IEEE 1800-2023 8.17: when the extends specifier contains default and the
// subclass provides a user-defined new(), the constructor argument list shall
// contain the default keyword. The marked constructor omits it, which a tool
// has to reject.

class base_d;
  function new(int x);
  endfunction
endclass

class child_d extends base_d(default);
  function new(int y); // illegal: default missing from the argument list
  endfunction
endclass

module test_illegal_extends_default_without_default_argument;
  child_d c;
  initial c = new(1);
endmodule
