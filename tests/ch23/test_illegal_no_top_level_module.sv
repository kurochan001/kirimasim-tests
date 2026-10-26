/*
:name: test_illegal_no_top_level_module
:description: the modules of the design instantiate each other, so there is no top-level module (IEEE 1800-2023 Section 23.3.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: every module is instantiated by another one, so the design has no top-level module
:expected_stderr_regex: test_illegal_no_top_level_module\.sv:(18|22):
*/
// A design shall contain at least one top-level module, that is, a module
// that no module instantiation statement names. Here a instantiates b and
// b instantiates a, so neither is top-level.

module a;
  b u();
endmodule
module b;
  a u();   // illegal: closes the cycle, leaving no top-level module
endmodule
