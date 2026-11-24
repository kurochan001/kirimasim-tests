/*
:name: test_sampled_value_functions_accept_empty_trailing_clock_arguments
:description: Explicit empty clocking arguments select the inferred clock for sampled expressions and gated past values
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.12 16.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sampled_value_functions_accept_empty_trailing_clock_arguments.expected
*/
`timescale 1ns/1ns

module test_sampled_value_functions_accept_empty_trailing_clock_arguments;
  bit clk, enable_sample, inhibit_sample;
  bit [3:0] left, right;
  wire sum_lsb = left[0] ^ right[0];

  always #5 clk = !clk;

  always @(posedge clk) begin
    if ($time >= 15)
      $display("t=%0d value=%0d history=%0d gated=%0d edges=%b%b%b%b same=%b",
               $time, $sampled(left + right), $past(left + right, , , ),
               $past(left + right, 1, enable_sample && !inhibit_sample, ),
               $rose(sum_lsb, ), $fell(sum_lsb, ),
               $stable(left + right, ), $changed(left + right, ),
               $past(left + right, , , ) === $past(left + right) &&
               $past(left + right, 1, enable_sample && !inhibit_sample, ) ===
                   $past(left + right, 1, enable_sample && !inhibit_sample, @(posedge clk)) &&
               $rose(sum_lsb, ) === $rose(sum_lsb, @(posedge clk)) &&
               $fell(sum_lsb, ) === $fell(sum_lsb, @(posedge clk)) &&
               $stable(left + right, ) === $stable(left + right, @(posedge clk)) &&
               $changed(left + right, ) === $changed(left + right, @(posedge clk)));
  end

  initial begin
    left = 1; right = 0; enable_sample = 1;
    #10 left = 0; right = 2; inhibit_sample = 1;
    #10 left = 1; right = 1; inhibit_sample = 0;
    #10 left = 2; right = 1; enable_sample = 0;
    #10 left = 0; right = 0; enable_sample = 1;
    #10 $finish;
  end
endmodule
