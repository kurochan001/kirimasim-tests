/*
:name: test_illegal_alias_of_variable
:description: a variable cannot be a member of an alias statement (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the alias statement names the variable v
:expected_stderr_regex: test_illegal_alias_of_variable\.sv:26:
*/
// IEEE 1800-2023 §10.11: an alias statement gives several names to the same
// net; variables and hierarchical references cannot be used in it, and a
// violation is a fatal error. The nets a and b are aliased, which is legal;
// the variable v is aliased to the net w.
// Icarus Verilog 13.0 does not parse alias statements.

module test_illegal_alias_of_variable;
  wire a, b;
  wire w;
  logic v;

  alias a = b;
  alias v = w;   // illegal: v is a variable

  assign a = 1'b1;
  initial #1 $display("%b", b);
endmodule
