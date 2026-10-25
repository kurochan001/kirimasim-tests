/*
:name: test_illegal_alias_wand_to_wor
:description: the nets joined by an alias statement have to be of the same net type, so a wand net cannot be aliased to a wor net (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the alias statement joins the wand net wa and the wor net wo
:expected_stderr_regex: test_illegal_alias_wand_to_wor\.sv:29:
*/
// IEEE 1800-2023 §10.11: the nets connected with an alias statement shall be
// of the same net type; a violation is a fatal error. Two wire nets and two
// wand nets are aliased, which is legal; the wand net wa and the wor net wo
// are not of the same net type.
// Icarus Verilog 13.0 does not parse alias statements.
// The design is accepted by the 5.052 release of Verilator.

module test_illegal_alias_wand_to_wor;
  wire w1, w2;
  wand wa1, wa2;
  wand wa;
  wor wo;

  alias w1 = w2;
  alias wa1 = wa2;
  alias wa = wo;   // illegal: wand and wor

  assign w1 = 1'b1;
  assign wa1 = 1'b1;
  initial #1 $display("%b %b", w2, wa2);
endmodule
