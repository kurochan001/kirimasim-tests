/*
:name: test_checker_reactive_triggered
:description: an always_ff procedure of a checker runs in the Reactive region, after the Observed region has set s.triggered, so it can count the end points of a sequence, while the same procedure in a module runs in the Active region and never sees them (IEEE 1800-2023 Section 17.7.3)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.3 17.5 16.13.6 4.4.2.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_reactive_triggered.expected
*/
// IEEE 1800-2023 §17.7.3: procedures of a checker that are sensitive to
// changes, such as clocking events, are scheduled in the Reactive region, and
// nonblocking assignments to checker variables update in the Re-NBA region,
// so always_ff @(posedge clk) a <= s.triggered captures the end point of s in
// the same time step. §16.13.6: triggered is set in the Observed region
// (§4.4.2.5) and its sampled value is its current value, so the sampling of
// §17.5 does not change it. A module always_ff on the same edge runs in the
// Active region, before the Observed region, and always reads 0. s is
// a ##1 b, which ends at the clock edges at 15 and 45.

`timescale 1ns/1ns

checker count_ends(logic clk, logic a, logic b);
  sequence s;
    @(posedge clk) a ##1 b;
  endsequence
  int ends = 0;
  always_ff @(posedge clk) ends <= ends + s.triggered;
  final $display("checker: %0d end points", ends);
endchecker

module test_checker_reactive_triggered;
  logic clk = 0, a = 0, b = 0;
  int module_ends = 0;

  always #5 clk = ~clk;   // rising edges at 5, 15, 25, ...

  sequence s;
    @(posedge clk) a ##1 b;
  endsequence

  always_ff @(posedge clk) module_ends <= module_ends + s.triggered;

  count_ends c(clk, a, b);

  initial begin
    a = 1; #10;
    a = 0; b = 1; #10;
    b = 0; #10;
    a = 1; #10;
    a = 0; b = 1; #10;
    b = 0; #10;
    $display("module: %0d end points", module_ends);
    $finish;
  end
endmodule
