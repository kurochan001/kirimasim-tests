/*
:name: test_bidirectional_switch_category
:description: tran, rtran, tranif0, tranif1, rtranif0 and rtranif1 are bidirectional switches that pass a signal from either terminal to the other, the controlled ones only while they are on (IEEE 1800-2023 Section 28.3.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.1 28.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bidirectional_switch_category.expected
*/
// IEEE 1800-2023 §28.3.1, Table 28-1: tran, tranif0, tranif1, rtran, rtranif0
// and rtranif1 are the bidirectional switches. §28.8: tran and rtran have two
// bidirectional terminals and always conduct, in either direction. The
// other four have two bidirectional terminals followed by a control input;
// tranif1 and rtranif1 conduct while the control is 1, tranif0 and rtranif0
// while it is 0, and a switch that is off blocks the signal.
// Each switch connects two nets of its own, l and r, and a bufif1 gate on
// each side drives that net from a only while ea is 1, or from b only while
// eb is 1. The steps drive the left side and then the right side, with each
// value and with each control value, and print both nets of every switch,
// left then right: the side that is not driven shows what came through.

module test_bidirectional_switch_category;
  logic a, b, ea, eb, ctl;
  wire l_tran, r_tran, l_rtran, r_rtran, l_tif0, r_tif0;
  wire l_tif1, r_tif1, l_rtif0, r_rtif0, l_rtif1, r_rtif1;

  bufif1 (l_tran, a, ea), (r_tran, b, eb), (l_rtran, a, ea), (r_rtran, b, eb);
  bufif1 (l_tif0, a, ea), (r_tif0, b, eb), (l_tif1, a, ea), (r_tif1, b, eb);
  bufif1 (l_rtif0, a, ea), (r_rtif0, b, eb), (l_rtif1, a, ea), (r_rtif1, b, eb);

  tran     s1 (l_tran, r_tran);
  rtran    s2 (l_rtran, r_rtran);
  tranif0  s3 (l_tif0, r_tif0, ctl);
  tranif1  s4 (l_tif1, r_tif1, ctl);
  rtranif0 s5 (l_rtif0, r_rtif0, ctl);
  rtranif1 s6 (l_rtif1, r_rtif1, ctl);

  task automatic show;
    $write("ea=%b eb=%b ctl=%b: tran=%b%b rtran=%b%b ", ea, eb, ctl, l_tran, r_tran,
           l_rtran, r_rtran);
    $display("tranif0=%b%b tranif1=%b%b rtranif0=%b%b rtranif1=%b%b", l_tif0, r_tif0,
             l_tif1, r_tif1, l_rtif0, r_rtif0, l_rtif1, r_rtif1);
  endtask

  initial begin
    ea = 1; eb = 0; a = 1; b = 0; ctl = 1;
    #1 show;
    ea = 0; eb = 1; a = 1; b = 0; ctl = 1;
    #1 show;
    ea = 1; eb = 0; a = 0; b = 1; ctl = 0;
    #1 show;
    ea = 0; eb = 1; a = 0; b = 1; ctl = 0;
    #1 show;
  end
endmodule
