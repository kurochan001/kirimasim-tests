/*
:name: test_property_keeps_realtime_samples_in_one_assertion_context
:description: An assertion-local realtime sample is one clock period old while an Active-region sample of the same marker is two periods old
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.6 16.10 4.4.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_keeps_realtime_samples_in_one_assertion_context.expected
*/
`timescale 1ns/1ps

module test_property_keeps_realtime_samples_in_one_assertion_context;
  bit clk, marker, next_marker;
  realtime external_mark;
  int local_hits, external_one_period, external_two_periods;

  always @(posedge clk) begin
    marker = next_marker;
    if (marker) external_mark = $realtime;
  end

  property local_interval;
    realtime assertion_mark;
    @(posedge clk) (marker, assertion_mark = $realtime) ##1
                   ($realtime - assertion_mark == 10.0);
  endproperty

  cover property (local_interval) local_hits++;
  cover property (@(posedge clk) marker ##1 ($realtime - external_mark == 10.0))
      external_one_period++;
  cover property (@(posedge clk) marker ##1 ($realtime - external_mark == 20.0))
      external_two_periods++;

  initial begin
    for (int edge_number = 0; edge_number < 6; ++edge_number) begin
      next_marker = edge_number % 3 == 0;
      #5 clk = 1;
      #5 clk = 0;
    end
    $display("local=%0d external-one=%0d external-two=%0d",
             local_hits, external_one_period, external_two_periods);
  end
endmodule
