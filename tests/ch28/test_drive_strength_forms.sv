/*
:name: test_drive_strength_forms
:description: Each of the six orders of a drive strength pair drives the value it names, every strength0 and strength1 keyword appears, highz0 and highz1 replace one value with z, and the three charge strengths on a trireg net show with %v (IEEE 1800-2023 Sections 28.3.2 and 28.15)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.2 28.15 21.2.1.4 A.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_drive_strength_forms.expected
*/
// IEEE 1800-2023 A.2.2.2: a drive strength is a parenthesized pair, either
// (strength0, strength1), (strength1, strength0), (strength0, highz1),
// (strength1, highz0), (highz0, strength1) or (highz1, strength0).
// strength0 is supply0, strong0, pull0 or weak0; strength1 is supply1,
// strong1, pull1 or weak1; a charge strength is small, medium or large and
// is legal only on a trireg net.
//   - b1 writes weak0 and supply1, b2 strong1 and pull0, b3 pull0 and
//     highz1, b4 supply1 and highz0, b5 highz0 and strong1, b6 highz1 and
//     weak0, so the six orders all appear and each of the eight strength
//     keywords appears at least once,
//   - a highz value makes the gate drive z instead of that value.
// %v (21.2.1.4) shows the strength and the value of each net.
//
// Icarus Verilog 13.0 produces these values. Verilator 5.052 does not model
// strengths.

module test_drive_strength_forms;
  logic a;
  wire w1, w2, w3, w4, w5, w6;

  buf (weak0, supply1) b1 (w1, a);
  buf (strong1, pull0) b2 (w2, a);
  buf (pull0, highz1) b3 (w3, a);
  buf (supply1, highz0) b4 (w4, a);
  buf (highz0, strong1) b5 (w5, a);
  buf (highz1, weak0) b6 (w6, a);

  initial begin
    a = 1'b0;
    #1 $display("a=0: %v %v %v %v %v %v", w1, w2, w3, w4, w5, w6);
    a = 1'b1;
    #1 $display("a=1: %v %v %v %v %v %v", w1, w2, w3, w4, w5, w6);
  end
endmodule
