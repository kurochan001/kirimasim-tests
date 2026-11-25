/*
:name: test_always_comb_incomplete_assignment_diagnostic
:description: An incomplete always_comb assignment retains its value and can trigger a latch inference warning
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_always_comb_incomplete_assignment_diagnostic.expected
*/
module test_always_comb_incomplete_assignment_diagnostic;
  bit enable = 1, data = 1, retained;
  always_comb if (enable) retained = data;

  initial begin
    #1;
    $display("enabled=%b", retained);
    enable = 0;
    data = 0;
    #1 $display("retained=%b", retained);
  end
endmodule
