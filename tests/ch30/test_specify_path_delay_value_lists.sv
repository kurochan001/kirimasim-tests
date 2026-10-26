/*
:name: test_specify_path_delay_value_lists
:description: A module path delay value is a list of path delay expressions with or without the parentheses, one expression giving every transition, two giving rise and fall, three giving rise, fall and z, and each expression a constant mintypmax expression (IEEE 1800-2023 Sections 30.5, 30.5.1 and 30.5.2)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.5 30.5.1 30.5.2 A.7.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_path_delay_value_lists.expected
*/
// IEEE 1800-2023 §30.5, Syntax 30-6 and A.7.4: the delay of a module path is
// a list of path delay expressions, either alone or in parentheses, with one,
// two, three, six or twelve expressions. Each expression is a constant
// min:typ:max expression (A.7.4, path_delay_expression). §30.5.1, Table 30-2:
// with one expression every transition takes that delay; with two, the first
// is the rise delay and the second the fall delay, and transitions to and from
// z use the rise or fall delay; with three, the third is the delay of every
// transition to or from z.
//
// The cells d_one, d_onep and d_mtm write the same delay 4 as a single
// expression without parentheses, a single expression in parentheses and the
// min:typ:max expression 4:4:4; each has the same delay for every transition.
// The cell d_two writes (3, 6): a rise takes 3 and a fall 6, and the changes
// to and from z take the rise and fall delays. The cell d_three writes
// (2, 5, 8): a rise takes 2, a fall 5 and a change to or from z 8. Each cell
// drives its output through a bufif1, so that en = 0 makes it z, and each
// output logs its changes.
//
// Icarus Verilog 13.0 accepts a list of two or more path delays only in
// parentheses. Verilator 5.052 ignores module path delays.

`timescale 1ns/1ns

module pd_one (input wire d, input wire en, output wire y);
  bufif1 g (y, d, en);
  specify
    (d, en *> y) = 4;
  endspecify
endmodule

module pd_onep (input wire d, input wire en, output wire y);
  bufif1 g (y, d, en);
  specify
    (d, en *> y) = (4);
  endspecify
endmodule

module pd_mtm (input wire d, input wire en, output wire y);
  bufif1 g (y, d, en);
  specify
    (d, en *> y) = (4:4:4);
  endspecify
endmodule

module pd_two (input wire d, input wire en, output wire y);
  bufif1 g (y, d, en);
  specify
    (d, en *> y) = (3, 6);
  endspecify
endmodule

module pd_three (input wire d, input wire en, output wire y);
  bufif1 g (y, d, en);
  specparam tr = 2, tf = 5;
  specify
    (d, en *> y) = (tr, tf, 8);
  endspecify
endmodule

module test_specify_path_delay_value_lists;
  reg d = 1'b0, en = 1'b1;
  wire y_one, y_onep, y_mtm, y_two, y_three;
  string log_one = "", log_onep = "", log_mtm = "", log_two = "", log_three = "";

  pd_one u_one (d, en, y_one);
  pd_onep u_onep (d, en, y_onep);
  pd_mtm u_mtm (d, en, y_mtm);
  pd_two u_two (d, en, y_two);
  pd_three u_three (d, en, y_three);

  always @(y_one) if ($time >= 10) log_one = {log_one, $sformatf(" %0t:%b", $time, y_one)};
  always @(y_onep) if ($time >= 10) log_onep = {log_onep, $sformatf(" %0t:%b", $time, y_onep)};
  always @(y_mtm) if ($time >= 10) log_mtm = {log_mtm, $sformatf(" %0t:%b", $time, y_mtm)};
  always @(y_two) if ($time >= 10) log_two = {log_two, $sformatf(" %0t:%b", $time, y_two)};
  always @(y_three) if ($time >= 10) log_three = {log_three, $sformatf(" %0t:%b", $time, y_three)};

  initial begin
    #10 d = 1'b1;      // 0 -> 1
    #20 d = 1'b0;      // 30: 1 -> 0
    #20 en = 1'b0;     // 50: 0 -> z
    #20 en = 1'b1; d = 1'b1;   // 70: z -> 1
    #20;
    $display("one:%s", log_one);
    $display("onep:%s", log_onep);
    $display("mtm:%s", log_mtm);
    $display("two:%s", log_two);
    $display("three:%s", log_three);
    $finish;
  end
endmodule
