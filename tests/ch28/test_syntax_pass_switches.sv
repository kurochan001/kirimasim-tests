/*
:name: test_syntax_pass_switches
:description: tran, rtran, tranif0, tranif1, rtranif0 and rtranif1 declared with several named and unnamed instances, and tranif1 with two delays, conduct in both directions while on and reduce strength when resistive (IEEE 1800-2023 Section 28.8)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.8 28.13 28.14 A.3.1 A.3.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_pass_switches.expected
*/
// IEEE 1800-2023 §28.8, A.3.1, A.3.4: tran and rtran take no strength or
// delay and one or more instances, each with an optional name and two
// bidirectional terminals; they always conduct, in either direction.
// tranif0, tranif1, rtranif0 and rtranif1 take up to two delays and one or
// more instances with two bidirectional terminals and a control input, and
// conduct while the control is 0 (tranif0, rtranif0) or 1 (tranif1,
// rtranif1). With two delays, the first is the turn-on and the second the
// turn-off delay. §28.13, §28.14: the r forms reduce a strong signal to
// pull, the others pass it unchanged.
//
// Strong drivers drive the left terminal of some instances and the right
// terminal of others, and the opposite terminal is printed with %v for both
// control values. A tranif1 declaration with #(3, 5) and two instances is
// printed before and after its turn-on and turn-off delays.

`timescale 1ns/1ns

module test_syntax_pass_switches;
  reg v, en, dv, den;
  wire a1, b1, a2, b2, a3, b3;
  wire a4, b4, a5, b5, a6, b6, a7, b7, a8, b8;
  wire da1, db1, da2, db2;

  assign a1 = v, b2 = v, a3 = v;
  assign a4 = v, b5 = v, a6 = v, b7 = v, a8 = v;
  assign da1 = dv, db2 = dv;

  tran g_t (a1, b1), (a2, b2);
  rtran (a3, b3);
  tranif1 g_t1 (a4, b4, en), (a5, b5, en);
  tranif0 (a6, b6, en);
  rtranif1 g_rt1 (a7, b7, en);
  rtranif0 g_rt0 (a8, b8, en);

  tranif1 #(3, 5) g_dt (da1, db1, den), (da2, db2, den);

  task show;
    $display("v=%b en=%b tran=%v %v rtran=%v tranif1=%v %v tranif0=%v rtranif1=%v rtranif0=%v",
             v, en, b1, a2, b3, b4, a5, b6, a7, b8);
  endtask

  task timed;
    $display("t=%0t tranif1=%v %v", $time, db1, da2);
  endtask

  initial begin
    v = 1; en = 1; dv = 1; den = 0;
    #1 show;
    v = 0;
    #1 show;
    en = 0;
    #1 show;
    v = 1;
    #1 show;
    #6 den = 1;   // t=10: turns on at 13
    #2 timed;     // t=12
    #2 timed;     // t=14
    den = 0;      // turns off at 19
    #4 timed;     // t=18
    #2 timed;     // t=20
  end
endmodule
