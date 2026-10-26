/*
:name: test_illegal_constructor_default_repeated
:description: a constructor argument list cannot contain the default keyword twice
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the subclass constructor argument list has two default keywords
:expected_stderr_regex: test_illegal_constructor_default_repeated\.sv:24:
*/
// IEEE 1800-2023 8.17: the default keyword shall appear no more than once in a
// constructor argument list. The marked subclass constructor has two of them,
// which a tool has to reject.

class base_r;
  function new(int x);
  endfunction
endclass

class repeated_c extends base_r;
  function new(default, default); // illegal: default appears twice
  endfunction
endclass

module test_illegal_constructor_default_repeated;
  repeated_c c;
  initial c = new(1);
endmodule
