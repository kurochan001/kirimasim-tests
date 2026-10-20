/*
:name: test_illegal_const_assigned
:description: A const variable cannot be assigned after its declaration (IEEE 1800-2023 Section 6.20.6)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the const variable limit is assigned by an initial procedure
:expected_stderr_regex: test_illegal_const_assigned\.sv:19:
*/
// IEEE 1800-2023 §6.20.6: a const variable gets its value where it is declared
// and is not written afterwards. The initial procedure assigns to limit.

module test_illegal_const_assigned;
  const int limit = 4;
  initial limit = 5;   // illegal: limit is const
endmodule
