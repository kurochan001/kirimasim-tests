/*
:name: test_illegal_dumpports_duplicate_scope
:description: one $dumpports call names the same scope twice (IEEE 1800-2023 Section 21.7.3.1)
:tags: ch21
:type: elaboration
:lrm: 1800-2023 21.7.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the scope list of $dumpports names the module m twice
:expected_stderr_regex: test_illegal_dumpports_duplicate_scope\.sv:25:
*/
// Each scope in the scope list of $dumpports shall be unique, and the
// scope lists of several calls shall also be unique. This call lists
// the module m twice.

module m;
  logic a;
endmodule
module test_illegal_dumpports_duplicate_scope;
  m u1();
  m u2();
  initial begin
    $dumpports(m, m, "ports.evcd");   // illegal: m twice
  end
endmodule
