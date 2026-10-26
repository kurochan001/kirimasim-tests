/*
:name: test_illegal_override_default_presence
:description: a virtual override must have a default expression exactly where the prototype has one
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the override drops the default expression that the prototype has
:expected_stderr_regex: test_illegal_override_default_presence\.sv:26:
*/
// IEEE 1800-2023 8.20: virtual overrides need not repeat the same default
// expressions, but the presence of a default for each argument shall match the
// prototype. The base prototype gives its argument a default and the marked
// override does not, which a tool has to reject.

class base_def;
  virtual function int f(int a = 3);
    return a;
  endfunction
endclass

class child_def extends base_def;
  virtual function int f(int a); // illegal: default presence differs
    return a + 1;
  endfunction
endclass

module test_illegal_override_default_presence;
  child_def c;
  initial c = new;
endmodule
