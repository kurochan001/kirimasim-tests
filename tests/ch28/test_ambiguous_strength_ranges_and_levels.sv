/*
:name: test_ambiguous_strength_ranges_and_levels
:description: a signal of known strength combined with an ambiguous one keeps the ambiguous levels above its own and drops the others, ranges show the levels of medium and small as 2 and 1, and a highz0 gate output with an unknown result is H (IEEE 1800-2023 Section 28.12.3)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.12.3 28.12.2 28.11 28.14 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_ambiguous_strength_ranges_and_levels.expected
*/
// IEEE 1800-2023 §28.12.3: when a signal of known value and one strength
// combines with a signal of ambiguous strength, the levels of the ambiguous
// one above that strength remain, those at or below it disappear, and a
// gap that this leaves between opposite values is filled. §28.12.2: two
// ambiguous signals give a range over both, an and gate with a highz0
// strength and an unknown result drives H (1 or z), and with another
// strength0 it drives x. %v (21.2.1.4) shows a range of a 0 or a 1 as the
// highest and lowest level, and an x as the highest 0 and 1 levels, with
// the levels of Table 28-7 (28.11): pull 5, weak 3, medium 2 and small 1.
// The ambiguous drivers are bufif1 gates with an x control, a pull bufif1
// for PuH and PuL and an nmos for StH. Medium and small come from a weak
// assignment through one or two rtran switches (28.14), and an nmos that is
// on copies them onto the net where they combine, so that nothing flows
// back from that net into the rtran switches.

module test_ambiguous_strength_ranges_and_levels;
  logic x = 1'bx;

  // Medium and small 1 and 0.
  wire w1, w0, me1, me0, sm1, sm0;
  assign (weak0, weak1) w1 = 1'b1;
  assign (weak0, weak1) w0 = 1'b0;
  rtran r_me1(w1, me1), r_me0(w0, me0);
  rtran r_sm1(me1, sm1), r_sm0(me0, sm0);

  // An and gate with an unknown result.
  wire g_hz, g_we;
  and (strong1, highz0) a_hz(g_hz, 1'b1, x);
  and (strong1, weak0) a_we(g_we, 1'b1, x);

  // A known signal with an ambiguous one.
  wire st1_puh, st0_puh, pu1_puh, we1_sth;
  assign st1_puh = 1'b1;
  bufif1 (pull0, pull1) b1(st1_puh, 1'b1, x);
  assign st0_puh = 1'b0;
  bufif1 (pull0, pull1) b2(st0_puh, 1'b1, x);
  assign (pull0, pull1) pu1_puh = 1'b1;
  bufif1 (pull0, pull1) b3(pu1_puh, 1'b1, x);
  assign (weak0, weak1) we1_sth = 1'b1;
  nmos n4(we1_sth, 1'b1, x);

  // Medium and small with PuH and PuL.
  wire me1_puh, me0_pul, me0_puh, me1_pul, sm1_puh, sm0_pul, sm0_puh, sm1_pul;
  nmos c1(me1_puh, me1, 1'b1);
  bufif1 (pull0, pull1) p1(me1_puh, 1'b1, x);
  nmos c2(me0_pul, me0, 1'b1);
  bufif1 (pull0, pull1) p2(me0_pul, 1'b0, x);
  nmos c3(me0_puh, me0, 1'b1);
  bufif1 (pull0, pull1) p3(me0_puh, 1'b1, x);
  nmos c4(me1_pul, me1, 1'b1);
  bufif1 (pull0, pull1) p4(me1_pul, 1'b0, x);
  nmos c5(sm1_puh, sm1, 1'b1);
  bufif1 (pull0, pull1) p5(sm1_puh, 1'b1, x);
  nmos c6(sm0_pul, sm0, 1'b1);
  bufif1 (pull0, pull1) p6(sm0_pul, 1'b0, x);
  nmos c7(sm0_puh, sm0, 1'b1);
  bufif1 (pull0, pull1) p7(sm0_puh, 1'b1, x);
  nmos c8(sm1_pul, sm1, 1'b1);
  bufif1 (pull0, pull1) p8(sm1_pul, 1'b0, x);

  // Two ranges of opposite values: StH with We1, and PuL with Me0.
  wire both;
  nmos q1(both, 1'b1, x);
  assign (weak0, weak1) both = 1'b1;
  bufif1 (pull0, pull1) q2(both, 1'b0, x);
  nmos q3(both, me0, 1'b1);

  initial begin
    #1;
    $display("sources: me1=%v me0=%v sm1=%v sm0=%v", me1, me0, sm1, sm0);
    $display("and (strong1, highz0) 1 & x: %v", g_hz);
    $display("and (strong1, weak0) 1 & x: %v", g_we);
    $display("St1 + PuH: %v", st1_puh);
    $display("St0 + PuH: %v", st0_puh);
    $display("Pu1 + PuH: %v", pu1_puh);
    $display("We1 + StH: %v", we1_sth);
    $display("Me1 + PuH: %v", me1_puh);
    $display("Me0 + PuL: %v", me0_pul);
    $display("Me0 + PuH: %v", me0_puh);
    $display("Me1 + PuL: %v", me1_pul);
    $display("Sm1 + PuH: %v", sm1_puh);
    $display("Sm0 + PuL: %v", sm0_pul);
    $display("Sm0 + PuH: %v", sm0_puh);
    $display("Sm1 + PuL: %v", sm1_pul);
    $display("StH + We1 + PuL + Me0: %v", both);
  end
endmodule
