/*
:name: test_gate_drive_strength_beside_net_value
:description: Gate instances with drive strengths give their outputs those strengths, a stronger gate output wins over a weaker one on the same net, and the strength stays beside the value of the net: nets of different strength compare equal, and an assignment carries only the value (IEEE 1800-2023 Section 6.3.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.3.2 28.3.2 28.12.1 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_gate_drive_strength_beside_net_value.expected
*/
// IEEE 1800-2023 §6.3.2: a net has strength information besides its value,
// the strength is not part of its data type, and gate declarations can
// specify a drive strength. §28.3.2: the drive strength of a gate gives the
// strength of its 0 and 1 outputs, in either order, and highz1 gives z in
// place of 1. §28.12.1: of two drivers of different strength the stronger
// value wins; equal strengths with different values give x of that
// strength. %v prints the strength and the value (§21.2.1.4).
// - buf (weak0, weak1) driving 1: We1; not (pull1, pull0) with input 1:
//   Pu0; buf (supply0, supply1) driving 1: Su1; buf (strong0, highz1)
//   driving 1: HiZ; and (pull0, weak1) with inputs 1, 1: We1;
// - w_fight has a strong 0 and a pull 1: St0; w_tie has a weak 0 and a weak
//   1: WeX;
// - w_we1 (We1) and w_su1 (Su1) both have the value 1, so they compare
//   equal and have one bit each; the continuous assignment w_copy = w_we1
//   drives w_copy with its own default strength, St1, and the variable v
//   assigned from w_we1 gets 1.

`timescale 1ns/1ns

module test_gate_drive_strength_beside_net_value;
  wire w_we1, w_pu0, w_su1, w_hz, w_and, w_fight, w_tie, w_copy;
  logic v;

  buf (weak0, weak1) g_we1 (w_we1, 1'b1);
  not (pull1, pull0) g_pu0 (w_pu0, 1'b1);
  buf (supply0, supply1) g_su1 (w_su1, 1'b1);
  buf (strong0, highz1) g_hz (w_hz, 1'b1);
  and (pull0, weak1) g_and (w_and, 1'b1, 1'b1);

  buf (strong0, strong1) g_fight0 (w_fight, 1'b0);
  bufif1 (pull0, pull1) g_fight1 (w_fight, 1'b1, 1'b1);

  buf (weak0, weak1) g_tie0 (w_tie, 1'b0);
  buf (weak0, weak1) g_tie1 (w_tie, 1'b1);

  assign w_copy = w_we1;

  initial begin
    #1;
    v = w_we1;
    $display("gates: buf=%v not=%v supply=%v highz1=%v and=%v", w_we1, w_pu0, w_su1, w_hz,
             w_and);
    $display("two drivers: fight=%v tie=%v", w_fight, w_tie);
    $display("values: w_we1=%b w_su1=%b equal=%b bits=%0d,%0d", w_we1, w_su1, w_we1 == w_su1,
             $bits(w_we1), $bits(w_su1));
    $display("assigned: w_copy=%v v=%b", w_copy, v);
  end
endmodule
