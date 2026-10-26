/*
:name: test_illegal_dumpports_string_scope
:description: $dumpports names its scope with a string literal (IEEE 1800-2023 Section 21.7.3.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.7.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the scope argument of $dumpports is the string literal "m"
:expected_stderr_regex: test_illegal_dumpports_string_scope\.sv:23:
*/
// The scope list of $dumpports holds module identifiers or hierarchical
// paths to modules; string literals and variables are not allowed.

module m;
  logic a;
endmodule
module test_illegal_dumpports_string_scope;
  m u1();
  initial begin
    $dumpports("m", "ports.evcd");   // illegal: string scope
  end
endmodule
