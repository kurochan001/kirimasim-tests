/*
:name: test_preponed_sample_observed_before_action
:description: A concurrent assertion samples before an NBA update but its pass action sees the updated live value (IEEE 1800-2023 Section 4.4.2.1)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.1 4.4.2.5 16.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_preponed_sample_observed_before_action.expected
*/
// IEEE 1800-2023 4.4.2.1 4.4.2.5 16.5.1: The property uses the preponed value,
// is evaluated after NBA, and schedules its action after the new live value is
// available.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not reproduce the clause-derived output.

`timescale 1ns/1ns
module test_preponed_sample_observed_before_action;
  bit clk, data;
  always #5 clk = ~clk;
  always @(posedge clk) data <= 1;
  a1: assert property (@(posedge clk) data == 0)
    $display("sampled=%0d live=%0d", $sampled(data), data);
  initial #6 $finish;
endmodule
