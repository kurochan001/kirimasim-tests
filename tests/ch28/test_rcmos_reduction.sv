/*
:name: test_rcmos_reduction
:description: An rcmos switch passes its input with the strength reduced as Table 28-8 says while either of its controls lets it conduct (IEEE 1800-2023 Section 28.14)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.14 28.9 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_rcmos_reduction.expected
*/
// IEEE 1800-2023 §28.9: a cmos switch conducts while its n-control is 1 or its
// p-control is 0, and is off when both say off; §28.14: the resistive form,
// rcmos, reduces strong to pull and pull to weak. The input is a strong 0 and
// then a pull 1, through the switch to an otherwise undriven net.

`timescale 1ns/1ns

module test_rcmos_reduction;
  logic v, sel, nc, pc;
  wire in, out;

  assign (strong0, strong1) in = sel ? 1'bz : v;
  assign (pull0, pull1) in = sel ? v : 1'bz;
  rcmos sw(out, in, nc, pc);

  task show;
    #1 $display("nc=%b pc=%b: in=%v out=%v", nc, pc, in, out);
  endtask

  initial begin
    v = 1'b0; sel = 1'b0;
    nc = 1'b1; pc = 1'b1;
    show;
    nc = 1'b0; pc = 1'b0;
    show;
    nc = 1'b0; pc = 1'b1;
    show;
    v = 1'b1; sel = 1'b1;
    nc = 1'b1; pc = 1'b0;
    show;
  end
endmodule
