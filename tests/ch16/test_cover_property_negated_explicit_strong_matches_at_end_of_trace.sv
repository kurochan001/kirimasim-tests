/*
:name: test_cover_property_negated_explicit_strong_matches_at_end_of_trace
:description: A negated strong sequence matches when the required sequence remains incomplete at simulation end
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.2 16.12.3 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cover_property_negated_explicit_strong_matches_at_end_of_trace.expected
*/
`timescale 1ns/1ns
module test_cover_property_negated_explicit_strong_matches_at_end_of_trace;
  bit clk, start, done;
  always #5 clk = ~clk;

  sequence completion;
    start ##[1:$] done;
  endsequence

  strong_negative: cover property (@(posedge clk) not strong(completion))
    $display("strong cover matched");

  initial begin
    start = 1;
    done = 0;
    #7 $finish;
  end
endmodule
