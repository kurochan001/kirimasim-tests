/*
:name: test_wired_logic_strength
:description: wand, wor, triand and trior combine drivers of the same strength with and or or logic and keep that strength, while a stronger driver still wins over a weaker one whatever its value (IEEE 1800-2023 Section 28.12.4)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.12.4 28.12.1 6.6.3 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wired_logic_strength.expected
*/
// IEEE 1800-2023 §28.12.4: the wired logic net types resolve conflicts between
// drivers of the same strength by treating them as inputs of an and (wand,
// triand) or an or (wor, trior), and the result has the strength of the
// combined signals; with weak drivers of 0 and 1, wand gives We0 and wor We1.
// The logic applies to drivers of the same strength only (§28.12.1): a strong
// 1 and a weak 0 on a wand give St1, a strong 0 and a weak 1 on a wor St0.
// §6.6.3: triand and trior are the same as wand and wor. §21.2.1.4: %v prints
// the strength and the value.

module test_wired_logic_strength;
  reg one = 1, zero = 0;
  wand wa;
  wor wo;
  triand ta;
  trior tr;
  wand wa_mixed;
  wor wo_mixed;

  buf (weak1, weak0) g1(wa, one), g2(wa, zero);
  buf (weak1, weak0) g3(wo, one), g4(wo, zero);
  buf (pull1, pull0) g5(ta, one), g6(ta, zero);
  buf (pull1, pull0) g7(tr, one), g8(tr, zero);
  buf (strong1, strong0) g9(wa_mixed, one);
  buf (weak1, weak0) g10(wa_mixed, zero);
  buf (strong1, strong0) g11(wo_mixed, zero);
  buf (weak1, weak0) g12(wo_mixed, one);

  initial #1 begin
    $display("wand, weak 1 and weak 0: %v", wa);
    $display("wor, weak 1 and weak 0: %v", wo);
    $display("triand, pull 1 and pull 0: %v", ta);
    $display("trior, pull 1 and pull 0: %v", tr);
    $display("wand, strong 1 and weak 0: %v", wa_mixed);
    $display("wor, strong 0 and weak 1: %v", wo_mixed);
  end
endmodule
