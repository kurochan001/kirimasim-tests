/*
:name: test_specify_state_dependent_path_declarations
:description: A state-dependent path declaration puts a simple or an edge-sensitive path under if (module_path_expression), and ifnone gives the simple path used when no condition is true; the delay applies only while the condition is true (IEEE 1800-2023 Section 30.4.4)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.4 30.4.4.1 30.4.4.2 30.4.4.4 A.7.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_state_dependent_path_declarations.expected
*/
// IEEE 1800-2023 §30.4.4, Syntax 30-5 and A.7.2: a state-dependent path
// declaration is if (module_path_expression) followed by a simple or an
// edge-sensitive path declaration, or ifnone followed by a simple path
// declaration. §30.4.4.1: the condition is evaluated when the path source
// changes; the delay applies when it is true, and a condition of x counts as
// true. §30.4.4.2: the ifnone path is the one used when no if condition of the
// same source and destination is true.
//
// The cell sd_simple has if (sel) (a => y) = 2 and ifnone (a => y) = 6. With
// sel = 1 a rise of a reaches y 2 later; with sel = 0 a fall of a reaches y 6
// later. The cell sd_edge has if (sel) (posedge clk => (q +: d)) = 3, so a
// rising edge of clk loads q 3 later while sel is 1, and immediately while
// sel is 0.
//
// The 5.052 release of Verilator ignores module path delays, so it does not
// produce this output.

`timescale 1ns/1ns

module sd_simple (input wire a, input wire sel, output wire y);
  buf g (y, a);
  specify
    if (sel) (a => y) = 2;
    ifnone (a => y) = 6;
  endspecify
endmodule

module sd_edge (input wire clk, input wire d, input wire sel, output wire q);
  reg qi = 1'b0;
  always @(posedge clk) qi <= d;
  buf g (q, qi);
  specify
    if (sel) (posedge clk => (q +: d)) = 3;
  endspecify
endmodule

module test_specify_state_dependent_path_declarations;
  reg a = 1'b0, sel = 1'b1;
  wire y;
  reg clk = 1'b0, d = 1'b1, esel = 1'b1;
  wire q;
  string log_y = "", log_q = "";

  sd_simple u_simple (.a(a), .sel(sel), .y(y));
  sd_edge u_edge (.clk(clk), .d(d), .sel(esel), .q(q));

  always @(y) if ($time >= 10) log_y = {log_y, $sformatf(" %0t:%b", $time, y)};
  always @(q) if ($time >= 10) log_q = {log_q, $sformatf(" %0t:%b", $time, q)};

  initial begin
    #10 a = 1'b1;      // sel 1: y at 12
    #5  sel = 1'b0;
    #5  a = 1'b0;      // 20: ifnone, y at 26
    #10 a = 1'b1;      // 30: ifnone, y at 36
    #5  sel = 1'b1;
    #5  a = 1'b0;      // 40: y at 42

    #0  clk = 1'b0;
    #5  clk = 1'b1;    // 45: esel 1, q at 48
    #5  clk = 1'b0;
    #5  esel = 1'b0;
    #0  d = 1'b0;
    #5  clk = 1'b1;    // 60: esel 0, q at once
    #5  clk = 1'b0;
    #5  esel = 1'b1; d = 1'b1;
    #5  clk = 1'b1;    // 75: q at 78
    #5  clk = 1'b0;
    #10;
    $display("simple y:%s", log_y);
    $display("edge q:%s", log_q);
    $finish;
  end
endmodule
