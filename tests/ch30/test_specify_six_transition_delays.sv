/*
:name: test_specify_six_transition_delays
:description: A module path with six delays gives each transition between 0, 1 and z its own delay, one with three delays uses the third for every change to z, and changes to and from x take the shortest and the longest of the related delays (IEEE 1800-2023 Section 30.5.1)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5.1 30.5.2 30.4.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_six_transition_delays.expected
*/
// IEEE 1800-2023 §30.5.1, Table 30-2: with six delays (2, 3, 4, 5, 6, 7) the
// transitions 0->1, 1->0, 0->z, z->1, 1->z and z->0 take them in that order.
// With three delays (2, 3, 9) the first is for 0->1 and z->1, the second for
// 1->0 and z->0, and the third for 0->z and 1->z. §30.5.2: a change from 0
// to x takes the smaller of the 0->z and 0->1 delays, 2 for both modules, and
// a change from x to 1 the larger of the z->1 and 0->1 delays: 5 with six
// delays and 2 with three. Both inputs share each path (30.4.6), so the delay
// does not depend on which input changed. The changes of y6 and y3 are
// recorded and printed at the end.

`timescale 1ns/1ns

module tri_buf6 (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = (2, 3, 4, 5, 6, 7);
  endspecify
endmodule

module tri_buf3 (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = (2, 3, 9);
  endspecify
endmodule

module test_specify_six_transition_delays;
  reg d, en;
  wire y6, y3;
  string log6 = "", log3 = "";

  tri_buf6 u6 (d, en, y6);
  tri_buf3 u3 (d, en, y3);

  always @(y6) if ($time >= 10) log6 = {log6, $sformatf(" %0d:%b", $time, y6)};
  always @(y3) if ($time >= 10) log3 = {log3, $sformatf(" %0d:%b", $time, y3)};

  initial begin
    d = 0;
    en = 1;
    #10 d = 1;      // 10: 0->1
    #10 d = 0;      // 20: 1->0
    #10 en = 0;     // 30: 0->z
    #10 d = 1;      // 40: y stays z
    #10 en = 1;     // 50: z->1
    #10 en = 0;     // 60: 1->z
    #10 d = 0;      // 70: y stays z
    #10 en = 1;     // 80: z->0
    #10 d = 1'bx;   // 90: 0->x
    #10 d = 1;      // 100: x->1
    #20 $display("y6:%s", log6);
    $display("y3:%s", log3);
  end
endmodule
