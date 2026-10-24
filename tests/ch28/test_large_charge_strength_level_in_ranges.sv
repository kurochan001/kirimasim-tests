/*
:name: test_large_charge_strength_level_in_ranges
:description: the large charge strength has level 4, which %v shows in the range of a large 0 or 1 combined with a pull H or L (IEEE 1800-2023 Section 28.11)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.11 28.12.3 28.15.2 28.13 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_large_charge_strength_level_in_ranges.expected
*/
// IEEE 1800-2023 §28.11, Table 28-7: large0 and large1 have the strength
// level 4, between pull (5) and weak (3). Two trireg (large) nets are
// charged by bufif1 gates to 1 and to 0 and then left, so that they hold
// their value with the large charge strength (28.15.2). nmos switches that
// are on copy them, with their strength (28.13), onto nets that also have a
// pull bufif1 with an x control, which drives PuH or PuL. By 28.12.3 the
// levels of the H or L above 4 remain: a large 1 with PuH is a 1 from level
// 5 to 4, a large 0 with PuL a 0 from 5 to 4, and with the opposite value
// the result is an x whose levels %v (21.2.1.4) shows as 4 and 5.
// Icarus Verilog 13.0 and Verilator 5.052 do not support trireg nets.

`timescale 1ns/1ns
module test_large_charge_strength_level_in_ranges;
  logic x = 1'bx;
  logic charge;
  trireg (large) t1, t0;
  bufif1 d1(t1, 1'b1, charge);
  bufif1 d0(t0, 1'b0, charge);

  wire la1_puh, la0_pul, la0_puh, la1_pul;
  nmos c1(la1_puh, t1, 1'b1);
  bufif1 (pull0, pull1) p1(la1_puh, 1'b1, x);
  nmos c2(la0_pul, t0, 1'b1);
  bufif1 (pull0, pull1) p2(la0_pul, 1'b0, x);
  nmos c3(la0_puh, t0, 1'b1);
  bufif1 (pull0, pull1) p3(la0_puh, 1'b1, x);
  nmos c4(la1_pul, t1, 1'b1);
  bufif1 (pull0, pull1) p4(la1_pul, 1'b0, x);

  initial begin
    charge = 1'b1;
    #1 charge = 1'b0;
    #1;
    $display("sources: t1=%v t0=%v", t1, t0);
    $display("La1 + PuH: %v", la1_puh);
    $display("La0 + PuL: %v", la0_pul);
    $display("La0 + PuH: %v", la0_puh);
    $display("La1 + PuL: %v", la1_pul);
  end
endmodule
