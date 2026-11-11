/*
:name: test_illegal_alias_net_to_itself
:description: an alias statement cannot alias a signal to itself (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the alias statement aliases the net s to itself
:expected_stderr_regex: test_illegal_alias_net_to_itself\.sv:27:
*/
// IEEE 1800-2023 §10.11: to avoid errors in specification, it is not allowed
// to specify an alias from an individual signal to itself. The nets a and b
// are aliased, which is legal; the last statement aliases s to s.
// Icarus Verilog 13.0 does not parse alias statements.
// The 5.052 release of Verilator rejects it as an alias given more than once,
// a check that also rejects the legal reuse of a net in two alias
// statements, so its error does not count.

module test_illegal_alias_net_to_itself;
  wire a, b;
  wire s;

  alias a = b;
  alias s = s;   // illegal: a signal aliased to itself

  assign a = 1'b1;
  initial #1 $display("%b", b);
endmodule
