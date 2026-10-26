/*
:name: test_illegal_super_default_without_expansion
:description: super.new(default) is illegal when the constructor argument list did not use default
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: super.new(default) is used without default in the constructor argument list
:expected_stderr_regex: test_illegal_super_default_without_expansion\.sv:26:
*/
// IEEE 1800-2023 8.17: the default keyword may be passed as the sole argument
// to super.new() only when the class constructor argument list also used
// default. The marked subclass constructor does not, which a tool has to
// reject.

class base_sd;
  function new(int x);
  endfunction
endclass

class child_sd extends base_sd;
  function new(int y);
    super.new(default); // illegal: no default in the argument list
  endfunction
endclass

module test_illegal_super_default_without_expansion;
  child_sd c;
  initial c = new(1);
endmodule
