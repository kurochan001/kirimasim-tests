/*
:name: test_drive_strength_components_on_gates_and_assigns
:description: gates and continuous assignments drive their 0 with the strength0 and their 1 with the strength1 of their strength specification, each one of supply, strong, pull, weak and highz (IEEE 1800-2023 Section 28.11)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.11 28.3.2 10.3.4 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_drive_strength_components_on_gates_and_assigns.expected
*/
// IEEE 1800-2023 §28.11: a strength specification has a strength0, one of
// supply0, strong0, pull0, weak0 and highz0, for the 0 part of the value,
// and a strength1, one of supply1, strong1, pull1, weak1 and highz1, for the
// 1 part; the driving strengths are those of gate outputs (28.3.2) and of
// continuous assignments (10.3.4). Each continuous assignment and each gate
// below drives a net of its own with the value v or its inverse, and %v
// (21.2.1.4) shows the strength and value of every net for v = 1, 0 and x.
// A 0 shows the strength0 and a 1 the strength1, a highz strength gives z
// for that value, and an x shows both levels: a mnemonic when they are
// equal, the 0 level and the 1 level otherwise, and H or L when one of them
// is highz.

module test_drive_strength_components_on_gates_and_assigns;
  logic v;
  wire a_su, a_st, a_pu, a_we, a_mix, a_rev, a_hz0, a_hz1;
  assign (supply0, supply1) a_su = v;
  assign (strong0, strong1) a_st = v;
  assign (pull0, pull1) a_pu = v;
  assign (weak0, weak1) a_we = v;
  assign (weak0, supply1) a_mix = v;
  assign (strong1, pull0) a_rev = v;
  assign (highz0, strong1) a_hz0 = v;
  assign (weak0, highz1) a_hz1 = v;

  wire g_su, g_pu, g_mix, g_hz1;
  buf (supply0, supply1) b_su(g_su, v);
  not (pull0, pull1) n_pu(g_pu, v);
  buf (pull0, weak1) b_mix(g_mix, v);
  not (strong0, highz1) n_hz1(g_hz1, v);

  logic vals[3] = '{1'b1, 1'b0, 1'bx};

  initial begin
    for (int i = 0; i < 3; i++) begin
      v = vals[i];
      #1;
      $display("v=%b assign: su=%v st=%v pu=%v we=%v (weak0,supply1)=%v (strong1,pull0)=%v", v,
               a_su, a_st, a_pu, a_we, a_mix, a_rev);
      $display("v=%b assign: (highz0,strong1)=%v (weak0,highz1)=%v", v, a_hz0, a_hz1);
      $display("v=%b gate: buf su=%v not pu=%v buf (pull0,weak1)=%v not (strong0,highz1)=%v", v,
               g_su, g_pu, g_mix, g_hz1);
    end
  end
endmodule
