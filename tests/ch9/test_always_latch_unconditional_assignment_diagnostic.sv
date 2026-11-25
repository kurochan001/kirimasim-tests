/*
:name: test_always_latch_unconditional_assignment_diagnostic
:description: An unconditional always_latch assignment follows its source and can trigger a missing latch warning
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_always_latch_unconditional_assignment_diagnostic.expected
*/
module test_always_latch_unconditional_assignment_diagnostic;
  bit enable = 1, data = 1, tracked;
  always_latch tracked = data;

  initial begin
    #1;
    $display("at start=%b", tracked);
    enable = 0;
    data = 0;
    #1 $display("after source changed=%b", tracked);
  end
endmodule
