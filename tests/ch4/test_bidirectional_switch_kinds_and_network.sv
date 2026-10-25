/*
:name: test_bidirectional_switch_kinds_and_network
:description: The bidirectional switches tran, tranif0, tranif1, rtran, rtranif0 and rtranif1 pass signals both ways when they conduct, and the nodes of a network of switches are resolved from all its devices together (IEEE 1800-2023 Section 4.9.5)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.5 28.8 28.13 28.14 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bidirectional_switch_kinds_and_network.expected
*/
// IEEE 1800-2023 §4.9.5: the switch primitives tran, tranif0, tranif1, rtran,
// rtranif0 and rtranif1 give bidirectional signal flow, and the value of a
// node of a switch network is found from all the devices of the network
// together. §28.8: tran and rtran always conduct, tranif1 and rtranif1
// conduct when the control is 1, tranif0 and rtranif0 when it is 0, and the
// signal can go in either direction. §28.13: tran devices keep a strong
// strength; §28.14: the r devices reduce strong to pull and pull to weak.
// Line "kinds" drives one terminal of each switch with a strong value, the
// left one for some and the right one for others, and prints the other
// terminal with %v; switches that are off leave it at HiZ. Lines "network"
// show the chain n1 -tran- n2 -rtran- n3 -tran- n4 with a strong driver on n1
// and a weak 0 on n4: the strong 1 of n1 reaches n4 as a pull 1 through
// three devices and wins over the weak 0. When the driver of n1 becomes 0,
// all four nodes change.
// The release 5.052 of Verilator does not support the switch primitives.

module test_bidirectional_switch_kinds_and_network;
  logic on = 1'b1, off = 1'b0, n1_value = 1'b1;
  wire a1, b1, a2, b2, c1, d1, c2, d2, e1, f1, e2, f2;
  wire g1, h1, g2, h2, i1, j1, i2, j2;
  wire n1, n2, n3, n4;

  assign a1 = 1'b1;
  tran t1(a1, b1);
  assign b2 = 1'b0;
  tran t2(a2, b2);
  assign c1 = 1'b1;
  tranif1 ti1(c1, d1, on);
  assign d2 = 1'b0;
  tranif1 ti2(c2, d2, off);
  assign f1 = 1'b0;
  tranif0 tz1(e1, f1, off);
  assign e2 = 1'b1;
  tranif0 tz2(e2, f2, on);
  assign g1 = 1'b1;
  rtran rt1(g1, h1);
  assign (pull1, pull0) h2 = 1'b0;
  rtran rt2(g2, h2);
  assign j1 = 1'b1;
  rtranif1 rti(i1, j1, on);
  assign i2 = 1'b0;
  rtranif0 rtz(i2, j2, off);

  assign n1 = n1_value;
  assign (weak1, weak0) n4 = 1'b0;
  tran tn1(n1, n2);
  rtran tn2(n2, n3);
  tran tn3(n3, n4);

  initial begin
    #1;
    $display("kinds: tran %v %v tranif1 %v %v tranif0 %v %v", b1, a2, d1, c2, e1, f2);
    $display("kinds: rtran %v %v rtranif1 %v rtranif0 %v", h1, g2, i1, j2);
    $display("network: n1=%v n2=%v n3=%v n4=%v", n1, n2, n3, n4);
    n1_value = 1'b0;
    #1 $display("network: n1=%v n2=%v n3=%v n4=%v", n1, n2, n3, n4);
  end
endmodule
