/*
:name: test_always_ff_level_event_diagnostic
:description: A level sensitive always_ff assignment follows its source and can trigger a sequential logic warning
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_always_ff_level_event_diagnostic.expected
*/
module test_always_ff_level_event_diagnostic;
  bit data, clock, tracked;
  always_ff @* tracked = data;

  initial begin
    #1 data = 1;
    #1;
    $display("high source=%b", tracked);
    clock = 1;
    data = 0;
    #1 $display("low source=%b", tracked);
  end
endmodule
