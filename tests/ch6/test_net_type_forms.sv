/*
:name: test_net_type_forms
:description: Nets of every built-in net type except trireg take their values from their drivers or from the type: supply nets are constant, wired nets resolve their drivers, tri0 and tri1 pull down and up, and uwire, wire and tri carry one driver (IEEE 1800-2023 Sections 6.6 and 28.15)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6 28.15 A.2.2.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_type_forms.expected
*/
// IEEE 1800-2023 A.2.2.1: net_type is one of supply0, supply1, tri,
// triand, trior, trireg, tri0, tri1, uwire, wire, wand and wor. 6.6 and
// 28.15 give each its value: supply0 and supply1 are the constant 0 and 1,
// triand and wand are the AND of their drivers, trior and wor the OR, tri0
// and tri1 pull toward 0 and 1 when nothing drives them, and uwire, wire and
// tri pass the value of their one driver. The trireg net type is in
// test_charge_strength_forms, which needs a net that holds a charge.
// ta is driven with 1 and 0, so it is 0; tor with 1 and 0, so it is 1; wa
// with 1 twice, so it is 1; wo with 0 twice, so it is 0.
//
// Icarus Verilog 13.0 produces these values. Verilator 5.052 does not model
// net types with more than one driver or the pull values.

module test_net_type_forms;
  supply0 s0;
  supply1 s1;
  tri t;
  triand ta;
  trior tor;
  tri0 t0;
  tri1 t1;
  uwire uw;
  wire w;
  wand wa;
  wor wo;

  logic d0 = 1'b0;
  logic d1 = 1'b1;

  assign t = d1;
  assign ta = d1;
  assign ta = d0;
  assign tor = d1;
  assign tor = d0;
  assign uw = d1;
  assign w = d1;
  assign wa = d1;
  assign wa = d1;
  assign wo = d0;
  assign wo = d0;

  initial #1 $display("s0=%b s1=%b t=%b ta=%b tor=%b t0=%b t1=%b uw=%b w=%b wa=%b wo=%b",
                      s0, s1, t, ta, tor, t0, t1, uw, w, wa, wo);
endmodule
