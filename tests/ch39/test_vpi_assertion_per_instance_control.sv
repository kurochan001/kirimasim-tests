/*
:name: test_vpi_assertion_per_instance_control
:description: An assertion handle names one instance of an assertion, so disabling and enabling the assertion of one module instance leaves the same assertion of the other instance and its callbacks alone (IEEE 1800-2023 Sections 39.3.1 and 39.5.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.3.1 39.5.2 39.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_per_instance_control.c
:expected_stdout: @test_vpi_assertion_per_instance_control.expected
*/
// IEEE 1800-2023 §39.3.1: "assertion handles are handles to a specific
// instance of a specific assertion", so the two instances of ci_leaf have
// different handles for their a1, each with its own full name. §39.5.2:
// vpiAssertionDisable stops new attempts of the assertion it is given and
// vpiAssertionEnable starts them again, without touching the other instance.
// §39.4.2: cbAssertionDisable and cbAssertionEnable are called only for the
// assertion they were placed on. $vt_watch at time 1 finds both assertions by
// their full names, prints that their handles differ, and disables u1.a1, so
// only u2 passes at the edges at 5 and 15. $vt_enable at 16 enables u1.a1; at
// 25 both fail and at 35 both pass, since a is 0 from 16 to 26.

`timescale 1ns/1ns

module ci_leaf(input logic clk, input logic a, output int passes, output int fails);
  a1: assert property (@(posedge clk) a) passes++; else fails++;
endmodule

module test_vpi_assertion_per_instance_control;
  logic clk = 0, a = 0;
  int p1, f1, p2, f2;

  always #5 clk = ~clk;

  ci_leaf u1(.clk(clk), .a(a), .passes(p1), .fails(f1));
  ci_leaf u2(.clk(clk), .a(a), .passes(p2), .fails(f2));

  initial begin
    #1 $vt_watch;              // 1: finds both assertions, disables u1.a1
    a = 1;
    #15;                       // 16: edges at 5 and 15
    $display("after two edges: u1 pass %0d fail %0d, u2 pass %0d fail %0d",
             p1, f1, p2, f2);
    $vt_enable;                // 16: enables u1.a1
    a = 0;
    #10;                       // 26: edge at 25
    a = 1;
    #10;                       // 36: edge at 35
    $display("after two more edges: u1 pass %0d fail %0d, u2 pass %0d fail %0d",
             p1, f1, p2, f2);
    $vt_report;
    $finish;
  end
endmodule
