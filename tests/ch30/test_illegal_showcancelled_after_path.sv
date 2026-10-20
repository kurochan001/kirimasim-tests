/*
:name: test_illegal_showcancelled_after_path
:description: A showcancelled declaration cannot name a path output after a module path to it has been declared (IEEE 1800-2023 Section 30.7.4.2)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.7.4.2 30.7.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: showcancelled names y after the module path to y
:expected_stderr_regex: test_illegal_showcancelled_after_path\.sv:22:
*/
// IEEE 1800-2023 §30.7.4.2: it is an error if a module path output appears in a
// showcancelled declaration after it has already appeared in a module path
// declaration.

module test_illegal_showcancelled_after_path (input a, output y);
  buf (y, a);
  specify
    (a => y) = (5, 1);
    showcancelled y;   // illegal: after the path to y
  endspecify
endmodule
