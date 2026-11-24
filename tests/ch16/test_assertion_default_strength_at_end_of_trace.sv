/*
:name: test_assertion_default_strength_at_end_of_trace
:description: Implicit weak assertion remains pending while a strong sequence requires a match
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertion_default_strength_at_end_of_trace.expected
*/
`timescale 1ns/1ns
module test_assertion_default_strength_at_end_of_trace;
  bit clock;
  bit start, done;
  always #5 clock = ~clock;

  sequence completion;
    start ##[1:$] done;
  endsequence

  assert property (@(posedge clock) completion)
    $display("weak completed");
  else
    $display("weak failed");
  assert property (@(posedge clock) strong(completion))
    $display("strong completed");
  else
    $display("strong failed");

  initial begin
    start = 1;
    done = 0;
    #7 $finish;
  end
endmodule
