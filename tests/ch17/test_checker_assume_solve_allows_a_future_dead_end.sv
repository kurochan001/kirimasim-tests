/*
:name: test_checker_assume_solve_allows_a_future_dead_end
:description: Both current checker choices allow a later inevitable assumption failure
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_checker_assume_solve_allows_a_future_dead_end
:expected_stdout: @test_checker_assume_solve_allows_a_future_dead_end.expected
*/
`timescale 1ns/1ns

checker deferred_dead_end(input bit clock, input bit launch,
                          output int low_failures = 0, high_failures = 0);
  rand bit decision;

  // Both values avoid failure on the launch edge. Exactly one of the
  // properties starts an attempt that cannot be satisfied on the next edge.
  low: assume property (@(posedge clock) (launch && !decision) |=> 1'b0)
    else low_failures++;
  high: assume property (@(posedge clock) (launch && decision) |=> 1'b0)
    else high_failures++;
endchecker

module test_checker_assume_solve_allows_a_future_dead_end;
  bit clock, launch = 1;
  int low_failures, high_failures;
  deferred_dead_end u(clock, launch, low_failures, high_failures);

  initial begin
    #5 clock = 1;
    #1 $display("launch failures=%0d", low_failures + high_failures);
    #4 clock = 0;
    launch = 0;
    #2 $display("between failures=%0d", low_failures + high_failures);
    #3 clock = 1;
    #1 $display("next edge failures=%0d", low_failures + high_failures);
    #4 clock = 0;
    #5 clock = 1;
    #1 $display("after drain failures=%0d", low_failures + high_failures);
    $finish;
  end
endmodule
