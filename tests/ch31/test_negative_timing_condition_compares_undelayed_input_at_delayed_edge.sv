/*
:name: test_negative_timing_condition_compares_undelayed_input_at_delayed_edge
:description: Timestamp conditions are read at the delayed edge without delaying the condition itself
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.3 31.9.1 31.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_negative_timing_condition_compares_undelayed_input_at_delayed_edge.expected
*/
`timescale 1ns/1ns
module timing_gate(input wire clock, data, timestamp_on);
  wire d_clock, d_data;
  reg notifier = 0;
  specify
    $setuphold(posedge clock, posedge data, -6, 14, notifier,
               timestamp_on, , d_clock, d_data);
  endspecify
endmodule

module test_negative_timing_condition_compares_undelayed_input_at_delayed_edge;
  bit clock, data;
  bit enables_later, disables_later = 1;
  timing_gate enable_after_raw(clock, data, enables_later);
  timing_gate disable_after_raw(clock, data, disables_later);
  timing_gate enable_all(clock, data, 1'b1);

  initial begin
    #20 clock = 1;
    #1 $display("raw clock=%b delayed=%b", clock, enable_all.d_clock);
    #1 enables_later = 1;
    disables_later = 0;
    #6 $display("later clock=%b delayed=%b", clock, enable_all.d_clock);
    #1 data = 1;
    #4 $display("enabled_late=%b disabled_late=%b always=%b",
                enable_after_raw.notifier, disable_after_raw.notifier, enable_all.notifier);
  end
endmodule
