/*
:name: test_gate_strength_keywords_and_highz
:description: each of supply, strong, pull and weak as strength0 and strength1 sets that strength on a gate output, and highz0 or highz1 makes it drive z in place of that value (IEEE 1800-2023 Section 28.3.2)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.2 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_gate_strength_keywords_and_highz.expected
*/
// IEEE 1800-2023 §28.3.2: a strength0 is one of supply0, strong0, pull0 and
// weak0, and a strength1 one of supply1, strong1, pull1 and weak1; they set
// the strength of the 0 and of the 1 that the gate drives. highz1 instead
// makes the gate drive z where it would drive 1, and highz0 where it would
// drive 0.
// Four buf gates use every strength0 and every strength1 keyword once, each
// paired with a different level of the other value, and two more use highz1
// and highz0. Every gate drives a net of its own; the input takes 0 and then
// 1, and %v (§21.2.1.4) shows strength and value on each net.

module test_gate_strength_keywords_and_highz;
  logic a;
  wire w1, w2, w3, w4, w5, w6;

  buf (supply0, weak1)   b1 (w1, a);
  buf (strong0, pull1)   b2 (w2, a);
  buf (pull0, strong1)   b3 (w3, a);
  buf (weak0, supply1)   b4 (w4, a);
  buf (highz1, strong0)  b5 (w5, a);
  buf (strong1, highz0)  b6 (w6, a);

  initial begin
    a = 0;
    #1 $display("a=%b: %v %v %v %v highz1:%v highz0:%v", a, w1, w2, w3, w4, w5, w6);
    a = 1;
    #1 $display("a=%b: %v %v %v %v highz1:%v highz0:%v", a, w1, w2, w3, w4, w5, w6);
  end
endmodule
