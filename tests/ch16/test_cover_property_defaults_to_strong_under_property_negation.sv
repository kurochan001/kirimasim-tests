/*
:name: test_cover_property_defaults_to_strong_under_property_negation
:description: A cover of a negated unqualified sequence matches when the sequence is incomplete at the end of simulation
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.2 16.12.3 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cover_property_defaults_to_strong_under_property_negation.expected
*/
`timescale 1ns/1ns
module test_cover_property_defaults_to_strong_under_property_negation;
  bit clk, start, done;
  always #5 clk = ~clk;

  sequence completion;
    start ##[1:$] done;
  endsequence

  implicit_negative: cover property (@(posedge clk) not completion)
    $display("implicit cover matched");

  weak_negative: cover property (@(posedge clk) not weak(completion))
    $display("weak cover matched");

  initial begin
    start = 1;
    done = 0;
    #7 $finish;
  end
endmodule
