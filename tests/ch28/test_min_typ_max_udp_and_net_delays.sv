/*
:name: test_min_typ_max_udp_and_net_delays
:description: the rise and fall delays of a UDP instance and the rise, fall and turn-off delays of a net can each be min:typ:max expressions in any numeric order, and the change comes after one of the three values (IEEE 1800-2023 Section 28.16.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.16.1 29.8 6.7.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_min_typ_max_udp_and_net_delays.expected
*/
// IEEE 1800-2023 §28.16.1: the delays of UDP instances (up to two, 29.8)
// and of nets (up to three, in the net declaration, 6.7.1) can each be
// given as minimum, typical and maximum expressions separated by colons,
// with no required relation between the three values. Which of the three a
// run uses is left to the tool, so the test checks only times outside all
// three: the values are at least 2 and at most 9, each list is in no order,
// and every change of the inputs is checked 1 and 10 time units later. The
// net is driven by a continuous assignment without a delay that drives z
// while c is 0, so that the turn-off delay of the net is used too.
// Icarus Verilog 13.0 does not parse a min:typ:max delay on a UDP instance
// and does not support net delays; Verilator 5.052 does not parse
// min:typ:max delays here.

`timescale 1ns/1ns
primitive p_buf(output out, input in);
  table
    0 : 0;
    1 : 1;
  endtable
endprimitive

module test_min_typ_max_udp_and_net_delays;
  logic d, c;
  wire o_u;
  wire #(9:3:6, 8:4:6, 7:2:5) o_n;
  p_buf #(9:3:6, 8:4:6) u(o_u, d);
  assign o_n = c ? d : 1'bz;

  task automatic show(string what);
    #1 $display("%s +1: udp=%b net=%b", what, o_u, o_n);
    #9 $display("%s +10: udp=%b net=%b", what, o_u, o_n);
  endtask

  initial begin
    d = 1'b0;
    c = 1'b1;
    #20;
    d = 1'b1;
    show("rise");
    d = 1'b0;
    show("fall");
    c = 1'b0;
    #1 $display("turn-off +1: net=%b", o_n);
    #9 $display("turn-off +10: net=%b", o_n);
  end
endmodule
