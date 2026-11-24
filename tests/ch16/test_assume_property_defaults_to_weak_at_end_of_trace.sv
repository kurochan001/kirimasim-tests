/*
:name: test_assume_property_defaults_to_weak_at_end_of_trace
:description: An unqualified assume uses weak semantics while an explicit strong assumption fails on the same incomplete trace
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.2 16.14.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assume_property_defaults_to_weak_at_end_of_trace.expected
*/
`timescale 1ns/1ns
module test_assume_property_defaults_to_weak_at_end_of_trace;
  bit clk, start, done;
  always #5 clk = ~clk;

  sequence completion;
    start ##[1:$] done;
  endsequence

  assume property (@(posedge clk) completion)
    $display("implicit completed");
  else
    $display("implicit failed");

  assume property (@(posedge clk) strong(completion))
    $display("strong completed");
  else
    $display("strong assumption failed");

  initial begin
    start = 1;
    done = 0;
    #7 $finish;
  end
endmodule
