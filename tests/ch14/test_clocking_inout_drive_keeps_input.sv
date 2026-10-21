/*
:name: test_clocking_inout_drive_keeps_input
:description: A synchronous drive of an inout clockvar changes its signal but not the input of the clocking block, which keeps the sampled value until the next clocking event (IEEE 1800-2023 Section 14.16.1)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16.1 14.3 14.13 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_inout_drive_keeps_input.expected
*/
// IEEE 1800-2023 §14.3: an inout clockvar reads as its input clockvar and is
// written as its output clockvar. §14.16.1: a drive of an inout clockvar does
// not change the clocking block input, since reading it gives the last
// sampled value (14.13). The drive at the first edge updates data in that time
// step (14.16), while cb.data stays at the value sampled at that edge until
// the next edge samples the driven value.

module test_clocking_inout_drive_keeps_input;
  logic clk = 0;
  logic data = 0;
  clocking cb @(posedge clk);
    inout data;
  endclocking

  always #5 clk = ~clk;

  initial begin
    @(cb);
    cb.data <= 1;
    $display("after drive: cb.data=%b", cb.data);
    #1 $display("one unit later: data=%b cb.data=%b", data, cb.data);
    @(cb);
    $display("next edge: cb.data=%b", cb.data);
    $finish;
  end
endmodule
