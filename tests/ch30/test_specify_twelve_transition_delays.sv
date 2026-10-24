/*
:name: test_specify_twelve_transition_delays
:description: A module path with twelve delays gives each of the twelve transitions between 0, 1, x and z its own delay in the order of Syntax 30-6, while the same path with only the first six delays derives the x transitions from them (IEEE 1800-2023 Section 30.5.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.1 30.5 30.5.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_twelve_transition_delays.expected
*/
// IEEE 1800-2023 §30.5: the six delays of a path are, in this order, for the
// transitions 0->1, 1->0, 0->z, z->1, 1->z and z->0; twelve delays add, in this
// order, 0->x, x->1, 1->x, x->0, x->z and z->x. §30.5.1, Table 30-2: with
// twelve delays every transition uses its own delay. The cell c12 has the
// delays 2 to 13, all different, so a delay taken from the wrong position
// shows up as a wrong time. The cell c6 has only the first six of them, so
// (§30.5.2) its x transitions take the smallest delay out of the old state and
// the largest delay into the new state: 0->x 2, x->1 5, 1->x 3, x->0 7, x->z 6
// and z->x 5, none of which equals the explicit delay of c12.
//
// A bufif1 drives each output, so that the output can be 0, 1, x (data x) and
// z (enable 0). The stimulus makes each of the twelve transitions at least
// once, 20 time units apart, which is longer than any delay, so no pulse is
// filtered. The changes of each output from time 20 on are recorded and
// printed at the end.

`timescale 1ns/1ns

module tw_cell12 (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);
  endspecify
endmodule

module tw_cell6 (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = (2, 3, 4, 5, 6, 7);
  endspecify
endmodule

module test_specify_twelve_transition_delays;
  reg d, en;
  wire y12, y6;
  string log12 = "", log6 = "";

  tw_cell12 u12 (d, en, y12);
  tw_cell6 u6 (d, en, y6);

  always @(y12) if ($time >= 20) log12 = {log12, $sformatf(" %0d:%b", $time, y12)};
  always @(y6) if ($time >= 20) log6 = {log6, $sformatf(" %0d:%b", $time, y6)};

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
    #20 $display("y12:%s", log12);
    $display("y6:%s", log6);
  end
endmodule
