/*
:name: test_illegal_charge_strength_on_wire
:description: A charge strength can be given only in a trireg declaration, not in a wire declaration (IEEE 1800-2023 Section 10.3)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the wire declaration has the charge strength (medium), which only trireg can have
:expected_stderr_regex: test_illegal_charge_strength_on_wire\.sv:22:
*/
// IEEE 1800-2023 §10.3 (Syntax 10-1, footnote 16): a charge strength
// (small, medium or large) shall only be used with the trireg keyword, as
// in "trireg (medium) t;". The declaration of w below gives one to a wire.
// Icarus Verilog 13.0 reports a syntax error on that line and parses the
// legal trireg form, so it diagnoses the rule. Verilator 5.052 reports a
// syntax error there too, but does not support trireg nets: not counted.

module test_illegal_charge_strength_on_wire;
  wire (medium) w;   // illegal: charge strength on a wire
endmodule
