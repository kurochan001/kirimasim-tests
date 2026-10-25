/*
:name: test_cont_assign_vector_rise_fall_turnoff
:description: a continuous assignment with three delays to a vector net uses the falling delay for a change from nonzero to zero, the turn-off delay for a change to z, and the rising delay for every other change (IEEE 1800-2023 Section 10.3.3)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_cont_assign_vector_rise_fall_turnoff.expected
*/
// IEEE 1800-2023 §10.3.3: when the left-hand side of a continuous assignment
// is a vector net, the delay is chosen from the change of the whole
// right-hand side: a change from a nonzero value to zero takes the falling
// delay, a change to z takes the turn-off delay, and any other change takes
// the rising delay. So a change between two nonzero values takes the rising
// delay even when the value gets smaller, and so do changes from z and to or
// from x.
//
// w is driven with the delays (2, 5, 8). r changes every 20 time units, and
// every change of w after time 20 is printed with its time:
//   0000 -> 0011  rising     22
//   0011 -> 0001  rising     42 (smaller, but not zero)
//   0001 -> 0000  falling    65
//   0000 -> zzzz  turn-off   88
//   zzzz -> 0101  rising    102
//   0101 -> xxxx  rising    122
//   xxxx -> 0110  rising    142
//   0110 -> 0000  falling   165
//
// Icarus Verilog 13.0 takes the falling delay for 0011 -> 0001, for
// zzzz -> 0101 and for xxxx -> 0110, where some bits go to 0 but the value
// does not become zero; the standard asks for the rising delay there.

`timescale 1ns/1ns
module test_cont_assign_vector_rise_fall_turnoff;
  logic [3:0] r = 4'b0000;
  wire [3:0] w;

  assign #(2, 5, 8) w = r;

  always @(w) if ($time >= 20) $display("t=%0t w=%b", $time, w);

  initial begin
    #20 r = 4'b0011;
    #20 r = 4'b0001;
    #20 r = 4'b0000;
    #20 r = 4'bzzzz;
    #20 r = 4'b0101;
    #20 r = 4'bxxxx;
    #20 r = 4'b0110;
    #20 r = 4'b0000;
    #20 $finish;
  end
endmodule
