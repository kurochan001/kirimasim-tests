/*
:name: test_specify_one_two_delay_transitions
:description: A module path with one delay uses it for all twelve transitions, and one with a rise and a fall delay uses the rise delay for 0->z and z->1, the fall delay for 1->z and z->0, and derives the x transitions from them (IEEE 1800-2023 Section 30.5.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.1 30.5.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_one_two_delay_transitions.expected
*/
// IEEE 1800-2023 §30.5.1, Table 30-2: with one delay t, the transitions among
// 0, 1 and z all take t, and so do the x transitions, which §30.5.2 derives
// as the smallest or largest of delays that are all t. With two delays
// (trise, tfall), 0->1, 0->z and z->1 take trise, and 1->0, 1->z and z->0
// take tfall. §30.5.2: a transition to x takes the smallest delay out of the
// old state (0->x: 0->z and 0->1; 1->x: 1->z and 1->0; z->x: z->1 and z->0),
// and a transition from x the largest delay into the new state (x->0: z->0
// and 1->0; x->1: z->1 and 0->1; x->z: 1->z and 0->z). So 0->x and x->1 take
// trise, 1->x and x->0 tfall, x->z the larger and z->x the smaller of the two.
// The cell c2a has (3, 7) and c2b (8, 4): x->z takes 7 and 8, z->x 3 and 4,
// which tells the larger and the smaller delay from a fixed position.
//
// A bufif1 drives each output, so that the output can be 0, 1, x (data x) and
// z (enable 0). The stimulus makes each of the twelve transitions at least
// once, 20 time units apart, which is longer than any delay, so no pulse is
// filtered. The changes of each output from time 20 on are recorded and
// printed at the end.

`timescale 1ns/1ns

module ot_cell1 (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = 5;
  endspecify
endmodule

module ot_cell2a (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = (3, 7);
  endspecify
endmodule

module ot_cell2b (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = (8, 4);
  endspecify
endmodule

module test_specify_one_two_delay_transitions;
  reg d, en;
  wire y1, y2a, y2b;
  string log1 = "", log2a = "", log2b = "";

  ot_cell1 u1 (d, en, y1);
  ot_cell2a u2a (d, en, y2a);
  ot_cell2b u2b (d, en, y2b);

  always @(y1) if ($time >= 20) log1 = {log1, $sformatf(" %0d:%b", $time, y1)};
  always @(y2a) if ($time >= 20) log2a = {log2a, $sformatf(" %0d:%b", $time, y2a)};
  always @(y2b) if ($time >= 20) log2b = {log2b, $sformatf(" %0d:%b", $time, y2b)};

  initial begin
    d = 0;
    en = 1;
    #20 d = 1;      // 20: 0->1
    #20 d = 0;      // 40: 1->0
    #20 en = 0;     // 60: 0->z
    #20 d = 1;      // 80: output stays z
    #10 en = 1;     // 90: z->1
    #20 en = 0;     // 110: 1->z
    #20 d = 0;      // 130: output stays z
    #10 en = 1;     // 140: z->0
    #20 d = 1'bx;   // 160: 0->x
    #20 d = 1;      // 180: x->1
    #20 d = 1'bx;   // 200: 1->x
    #20 d = 0;      // 220: x->0
    #20 d = 1'bx;   // 240: 0->x
    #20 en = 0;     // 260: x->z
    #20 en = 1;     // 280: z->x
    #20 d = 0;      // 300: x->0
    #20 $display("y1:%s", log1);
    $display("y2a:%s", log2a);
    $display("y2b:%s", log2b);
  end
endmodule
