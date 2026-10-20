/*
:name: test_clocking_input_skew_fractional
:description: A clocking block input skew, also a fractional one, samples a module's input port that many time units before the clock event (IEEE 1800-2023 Section 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 14.3 3.14.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_input_skew_fractional.expected
*/
// IEEE 1800-2023 §14.4: with an input skew, a clocking block samples the
// signal that many time units before its clock event, in the time unit of
// its scope (3.14.2.2). Here the time unit is 1ns with a precision of 1ps,
// the clock rises at 50 and 150, and the input port d changes from 0 to 1 at
// 147.3: an input skew of 3 samples d at 147.0 and gets 0, an input skew of
// 2.5 samples it at 147.5 and gets 1.

module skew_sampler (input logic d, input logic clk);
  timeunit 1ns;
  timeprecision 1ps;
  logic s3, s25;

  clocking c3 @(posedge clk);
    input #3 d;
  endclocking

  clocking c25 @(posedge clk);
    input #2.5 d;
  endclocking

  initial begin
    @(c3);
    @(c3);
    s3 = c3.d;
  end

  initial begin
    @(c25);
    @(c25);
    s25 = c25.d;
  end
endmodule

module test_clocking_input_skew_fractional;
  timeunit 1ns;
  timeprecision 1ps;
  logic clk = 0, d = 0;

  always #50 clk = ~clk;
  skew_sampler k (d, clk);

  initial #147.3 d = 1;
  initial begin
    #200 $display("at the clock event at 150: skew 3 sampled %b, skew 2.5 sampled %b", k.s3,
                  k.s25);
    $finish;
  end
endmodule
