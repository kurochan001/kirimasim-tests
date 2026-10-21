/*
:name: test_checker_output_actual
:description: A checker output is passed to an actual variable by a continuous assignment in the Reactive region, so a procedure of the module on the same clock edge sees the value from the previous edge (IEEE 1800-2023 Section 17.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.3 17.7.3 17.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_output_actual.expected
*/
// IEEE 1800-2023 §17.3: the actual argument of a checker output shall be a
// variable_lvalue or a net_lvalue, and the checker instance is treated as if
// there were continuous assignments, executed in the Reactive region, from the
// output formals to their actuals. §17.7.3: the always_ff procedure of the
// checker also runs in the Reactive region and updates its variable in the
// Re-NBA region. So a module procedure that reads the actual on the same
// rising edge reads the value from the previous edge: seen lags the output q
// by one edge. The actual of q is bit 1 of the module vector qv, and the
// checker variable behind q starts at 0, so the first value is not unknown.

`timescale 1ns/1ns

checker chk_delay_output(input logic d, input logic clk, output logic q);
  logic delay = 1'b0;
  always_ff @(posedge clk) delay <= d;
  assign q = delay;
endchecker

module test_checker_output_actual;
  logic clk = 0, d = 0;
  logic [1:0] qv = 2'b00;
  logic seen = 0;

  always #5 clk = ~clk;

  chk_delay_output c(.d(d), .clk(clk), .q(qv[1]));

  always_ff @(posedge clk) seen <= qv[1];

  initial begin
    #1 d = 1;
    #5 $display("%0d: q=%b seen=%b", $time, qv[1], seen);
    d = 0;
    #10 $display("%0d: q=%b seen=%b", $time, qv[1], seen);
    d = 1;
    #10 $display("%0d: q=%b seen=%b", $time, qv[1], seen);
    $finish;
  end
endmodule
