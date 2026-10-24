/*
:name: test_specify_derived_x_transition_delays
:description: Without explicit x delays, a transition to x takes the smallest delay from the old state to the other known states and a transition from x the largest delay into the new state, for paths with three and with six delays and with either delay of each pair the smaller (IEEE 1800-2023 Section 30.5.2)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.2 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_derived_x_transition_delays.expected
*/
// IEEE 1800-2023 §30.5.2, Table 30-3: when a path has no explicit x delays,
// s->x takes the minimum of the delays from s to the other known states, and
// x->s the maximum of the delays from the other known states to s: 0->x is
// min(0->z, 0->1), 1->x min(1->z, 1->0), z->x min(z->1, z->0), x->0
// max(z->0, 1->0), x->1 max(z->1, 0->1) and x->z max(1->z, 0->z).
// §30.5.1, Table 30-2 gives the six known-state delays: with three delays
// (trise, tfall, tz) they are trise, tfall, tz, trise, tz, tfall; with six
// they are given in the order 0->1, 1->0, 0->z, z->1, 1->z, z->0.
//
// Each pair is checked both ways round. With six delays, c6a (2, 3, 4, 5, 6,
// 7) gives 0->x 2 (from 0->1), 1->x 3 (1->0), z->x 5 (z->1), x->0 7 (z->0),
// x->1 5 (z->1) and x->z 6 (1->z). c6b (9, 8, 4, 6, 3, 5) turns every pair
// round: 0->x 4 (0->z), 1->x 3 (1->z), z->x 5 (z->0), x->0 8 (1->0), x->1 9
// (0->1) and x->z 4 (0->z). With three
// delays, c3a (3, 6, 9) gives 1->x 6 (tfall), z->x 3 (trise), x->0 6 and x->z
// 9, and c3b (7, 4, 2) gives 1->x 2 (tz), z->x 4 (tfall), x->0 4 and x->z 2.
//
// A bufif1 drives each output, so that the output can be 0, 1, x (data x) and
// z (enable 0). The stimulus makes each of the twelve transitions at least
// once, 20 time units apart, which is longer than any delay, so no pulse is
// filtered. The changes of each output from time 20 on are recorded and
// printed at the end.

`timescale 1ns/1ns

module dx_cell3a (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = (3, 6, 9);
  endspecify
endmodule

module dx_cell3b (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = (7, 4, 2);
  endspecify
endmodule

module dx_cell6a (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = (2, 3, 4, 5, 6, 7);
  endspecify
endmodule

module dx_cell6b (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = (9, 8, 4, 6, 3, 5);
  endspecify
endmodule

module test_specify_derived_x_transition_delays;
  reg d, en;
  wire y3a, y3b, y6a, y6b;
  string log3a = "", log3b = "", log6a = "", log6b = "";

  dx_cell3a u3a (d, en, y3a);
  dx_cell3b u3b (d, en, y3b);
  dx_cell6a u6a (d, en, y6a);
  dx_cell6b u6b (d, en, y6b);

  always @(y3a) if ($time >= 20) log3a = {log3a, $sformatf(" %0d:%b", $time, y3a)};
  always @(y3b) if ($time >= 20) log3b = {log3b, $sformatf(" %0d:%b", $time, y3b)};
  always @(y6a) if ($time >= 20) log6a = {log6a, $sformatf(" %0d:%b", $time, y6a)};
  always @(y6b) if ($time >= 20) log6b = {log6b, $sformatf(" %0d:%b", $time, y6b)};

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
    #20 $display("y3a:%s", log3a);
    $display("y3b:%s", log3b);
    $display("y6a:%s", log6a);
    $display("y6b:%s", log6b);
  end
endmodule
