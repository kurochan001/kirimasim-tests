/*
:name: test_specify_path_delay_value_forms
:description: The delays of a module path can be one, two, three, six or twelve constant expressions of literals and specparams, each of them possibly a min:typ:max expression, written with or without parentheses around the list (IEEE 1800-2023 Section 30.5)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5 30.5.1 30.5.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_path_delay_value_forms.expected
*/
// IEEE 1800-2023 §30.5, Syntax 30-6: the delay value of a module path is a
// list of one, two, three, six or twelve path delay expressions, with or
// without parentheses around it, and each expression is a constant
// min:typ:max expression of literals and specparams. The cells f1, f2, f3 and
// f6 write their lists without parentheses: f1 the single min:typ:max
// expression 4:4:4, f2 two literals, f3 three literals and f6 six specparams.
// The cell f12 writes twelve expressions in parentheses, mixing literals,
// specparams and the min:typ:max expression 10:10:10. Each min:typ:max
// expression has three equal values, so the result does not depend on which
// of them the tool selects.
//
// §30.5.1, Table 30-2 and §30.5.2 then give the delay of every transition:
// f1 4 for all; f2 (3, 6) rise 3, fall 6, 0->z and z->1 3, 1->z and z->0 6,
// 0->x and x->1 3, 1->x, x->0 and x->z 6, z->x 3; f3 (2, 5, 8) 0->1 and z->1
// 2, 1->0 and z->0 5, 0->z and 1->z 8, 0->x 2, x->1 2, 1->x 5, x->0 5, x->z 8,
// z->x 2; f6 (4, 2, 7, 3, 9, 6) 0->x 4, x->1 4, 1->x 2, x->0 6, x->z 9, z->x
// 3; f12 the twelve delays 9 to 4, then 3, 2, 1, 10, 11 and 12.
//
// A bufif1 drives each output, so that the output can be 0, 1, x (data x) and
// z (enable 0). The stimulus makes each of the twelve transitions at least
// once, 20 time units apart, which is longer than any delay, so no pulse is
// filtered. The changes of each output from time 20 on are recorded and
// printed at the end.
//
// Icarus Verilog 13.0 rejects a list of path delays without parentheses as a
// syntax error.

`timescale 1ns/1ns

module vf_cell1 (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = 4:4:4;
  endspecify
endmodule

module vf_cell2 (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = 3, 6;
  endspecify
endmodule

module vf_cell3 (input d, en, output y);
  bufif1 (y, d, en);
  specify
    (d, en *> y) = 2, 5, 8;
  endspecify
endmodule

module vf_cell6 (input d, en, output y);
  bufif1 (y, d, en);
  specify
    specparam t01 = 4, t10 = 2, t0z = 7, tz1 = 3, t1z = 9, tz0 = 6;
    (d, en *> y) = t01, t10, t0z, tz1, t1z, tz0;
  endspecify
endmodule

module vf_cell12 (input d, en, output y);
  bufif1 (y, d, en);
  specify
    specparam tz1 = 6, tx1 = 2, tzx = 12;
    (d, en *> y) = (9, 8, 7, tz1, 5, 4, 3, tx1, 1, 10:10:10, 11, tzx);
  endspecify
endmodule

module test_specify_path_delay_value_forms;
  reg d, en;
  wire y1, y2, y3, y6, y12;
  string log1 = "", log2 = "", log3 = "", log6 = "", log12 = "";

  vf_cell1 u1 (d, en, y1);
  vf_cell2 u2 (d, en, y2);
  vf_cell3 u3 (d, en, y3);
  vf_cell6 u6 (d, en, y6);
  vf_cell12 u12 (d, en, y12);

  always @(y1) if ($time >= 20) log1 = {log1, $sformatf(" %0d:%b", $time, y1)};
  always @(y2) if ($time >= 20) log2 = {log2, $sformatf(" %0d:%b", $time, y2)};
  always @(y3) if ($time >= 20) log3 = {log3, $sformatf(" %0d:%b", $time, y3)};
  always @(y6) if ($time >= 20) log6 = {log6, $sformatf(" %0d:%b", $time, y6)};
  always @(y12) if ($time >= 20) log12 = {log12, $sformatf(" %0d:%b", $time, y12)};

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
    $display("y2:%s", log2);
    $display("y3:%s", log3);
    $display("y6:%s", log6);
    $display("y12:%s", log12);
  end
endmodule
