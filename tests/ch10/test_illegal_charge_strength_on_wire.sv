/*
:name: test_illegal_charge_strength_on_wire
:description: A charge strength can be given only in a trireg declaration, not in a wire declaration (IEEE 1800-2023 Section 10.3)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the wire declaration has the charge strength (medium), which only trireg can have
:expected_stderr_regex: test_illegal_charge_strength_on_wire\.sv:22:
*/
// IEEE 1800-2023 §10.3 (Syntax 10-1, footnote 16): a charge strength
// (small, medium or large) shall only be used with the trireg keyword, as
// in "trireg (medium) t;". The declaration of w below gives one to a wire.
// Icarus Verilog 13.0 and the 5.052 release of Verilator report a syntax
// error on that line; neither supports trireg nets, so it is not clear that
// they reject the charge strength for this reason.

module test_illegal_charge_strength_on_wire;
  wire (medium) w;   // illegal: charge strength on a wire
endmodule
