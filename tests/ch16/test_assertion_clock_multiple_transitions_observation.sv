/*
:name: test_assertion_clock_multiple_transitions_observation
:description: A clean assertion clock and a same-slot glitch are exercised separately
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_clock_multiple_transitions_observation.expected
*/
`timescale 1ns/1ns
module test_assertion_clock_multiple_transitions_observation;
  bit clk = 0;
  bit data = 1;
  int passes = 0, failures = 0;
  a: assert property (@(posedge clk) data)
    passes++;
  else failures++;

  initial begin
    #1 clk = 1;
    if ($test$plusargs("observe_glitch")) begin
      #0 clk = 0;
      #0 clk = 1;
      $display("same slot edges emitted t=%0d", $time);
    end
    #1 clk = 0;
    #1 clk = 1;
    #1 $display("assertion passes=%0d failures=%0d", passes, failures);
    $finish(0);
  end
endmodule
