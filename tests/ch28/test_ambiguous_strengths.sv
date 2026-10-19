/*
:name: test_ambiguous_strengths
:description: equal strengths of opposite values combine to x of that strength, three-state drivers with an x control give H or L, two such outputs of opposite values combine to x over both ranges, and an unambiguous weaker signal removes the levels of an ambiguous one that it overrides while the gap between opposite values stays (IEEE 1800-2023 Sections 28.12.2, 28.12.3)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.12.2 28.12.3 28.12.1 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_ambiguous_strengths.expected
*/
// IEEE 1800-2023 §28.12.2: two signals of equal strength and opposite value
// combine to x with that strength; a bufif1 or bufif0 with an x control
// drives H or L, a range from its strength down to high impedance; two
// ambiguous signals combine to a range covering both. §28.12.3: when an
// unambiguous signal combines with an ambiguous one, the levels of the
// ambiguous one above its strength remain, those at or below it disappear,
// and a gap between opposite values is filled: a strong H with a pull 0
// gives x from Pu0 to St1. §21.2.1.4: %v prints such a value as the strength
// mnemonic and the value, or as the two highest levels, strength0 first, and
// the value.

module test_ambiguous_strengths;
  reg one = 1, zero = 0, ctl = 1'bx;
  wire w_eq, w_h, w_l, w_hl, w_hp;

  buf (weak1, weak0) g1(w_eq, one);
  buf (weak1, weak0) g2(w_eq, zero);
  bufif1 g3(w_h, one, ctl);
  bufif0 g4(w_l, zero, ctl);
  bufif1 g5(w_hl, one, ctl);
  bufif0 g6(w_hl, zero, ctl);
  bufif1 g7(w_hp, one, ctl);
  buf (pull1, pull0) g8(w_hp, zero);

  initial #1 begin
    $display("weak 1 and weak 0: %v", w_eq);
    $display("bufif1 with an x control: %v", w_h);
    $display("bufif0 with an x control: %v", w_l);
    $display("both on one net: %v", w_hl);
    $display("strong H and pull 0: %v", w_hp);
  end
endmodule
