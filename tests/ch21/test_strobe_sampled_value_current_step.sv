/*
:name: test_strobe_sampled_value_current_step
:description: $strobe of $sampled prints the value from the Preponed region of the current time step, while the variable itself is shown with its value at the end of the step (IEEE 1800-2023 Section 21.2.2)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.2 16.9.3 16.5.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_strobe_sampled_value_current_step.expected
*/
// IEEE 1800-2023 §21.2.2: $strobe prints at the end of the time step, but
// $sampled in its arguments gives the value of the Preponed region of the
// current time step, not of the next one. §16.9.3, §16.5.1: $sampled returns
// the sampled value, which at a time after 0 is the value of the variable in
// the Preponed region of that time step.
// cnt is 0 until it is set to 1 by a blocking assignment at time 10 and to 2
// by a nonblocking one at time 20, and stays 2 at time 30. Each strobe shows
// the value at the end of its time step and the value before the step.
// Icarus Verilog 13.0 does not support $sampled in procedural code.

module test_strobe_sampled_value_current_step;
  int cnt = 0;

  initial begin
    #10;
    cnt = 1;
    $strobe("t10 cnt=%0d sampled=%0d", cnt, $sampled(cnt));
    #10;
    cnt <= 2;
    $strobe("t20 cnt=%0d sampled=%0d", cnt, $sampled(cnt));
    #10;
    $strobe("t30 cnt=%0d sampled=%0d", cnt, $sampled(cnt));
  end
endmodule
