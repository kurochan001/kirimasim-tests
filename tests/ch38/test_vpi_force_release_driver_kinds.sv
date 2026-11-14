/*
:name: test_vpi_force_release_driver_kinds
:description: vpi_put_value with vpiForceFlag and vpiReleaseFlag acts as the procedural force and release on a variable assigned procedurally, a variable with a continuous assignment, a variable with an active procedural assign, and nets driven by a continuous assignment, a gate and a module output (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 10.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_force_release_driver_kinds.c
:expected_stdout: @test_vpi_force_release_driver_kinds.expected
*/
// IEEE 1800-2023 §38.34: vpi_put_value with vpiForceFlag forces the objects
// that a procedural force can force, and with vpiReleaseFlag releases them,
// with the same effect as the procedural force and release (10.6.2). A
// forced variable keeps the forced value over procedural assignments,
// continuous assignments and procedural assign statements. When it is
// released, a variable that has no continuous assignment and no active
// procedural assign keeps its value until its next procedural assignment,
// and one that has either gets that assignment back, which is evaluated
// again. A forced net keeps the forced value over all its drivers, gate and
// module outputs included, and when it is released it takes at once the
// value of its drivers.
//
// The variable v is assigned procedurally, cv has a continuous assignment
// from src, and pv an active procedural assign from src2 made at time 0. The
// net n is driven by a continuous assignment, g by an and gate, and mo by
// the output of the instance u. At 10 the application forces each of them to
// a value no driver gives, and at 14 it releases them, in cbAfterDelay
// callbacks registered at the start of the simulation. The design changes
// all the sources at 12 and again at 16, when it also assigns v, and prints
// the objects at 11, 13, 15 and 17. The 5.054 release of Verilator stops at
// the first force with an error that the signal is not forceable.

`timescale 1ns/1ns

module test_vpi_force_release_driver_kinds_buf (output wire [7:0] y, input wire [7:0] a);
  assign y = a;
endmodule

module test_vpi_force_release_driver_kinds;
  logic [7:0] v, src, src2, drv, a8;
  logic [7:0] cv, pv;
  logic ga, gb;
  wire [7:0] n, mo;
  wire g;

  assign cv = src;
  assign n = drv;
  and ag (g, ga, gb);
  test_vpi_force_release_driver_kinds_buf u (.y(mo), .a(a8));

  task automatic show(input int t);
    $display("%0d: v=%0d cv=%0d pv=%0d n=%0d g=%b mo=%0d", t, v, cv, pv, n, g, mo);
  endtask

  initial begin
    v = 1;
    src = 2;
    src2 = 3;
    drv = 4;
    ga = 0;
    gb = 1;
    a8 = 5;
    assign pv = src2;
    #11 show(11);
    #1 v = 7;
    src = 8;
    src2 = 9;
    drv = 10;
    gb = 0;
    a8 = 11;
    #1 show(13);
    #2 show(15);
    #1 v = 12;
    src = 13;
    src2 = 15;
    drv = 14;
    a8 = 16;
    #1 show(17);
    $finish;
  end
endmodule
