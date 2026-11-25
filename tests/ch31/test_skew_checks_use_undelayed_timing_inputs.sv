/*
:name: test_skew_checks_use_undelayed_timing_inputs
:description: skew notifiers stay on original edges when a negative setup check reverses the delayed edge order
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.4.1 31.4.2 31.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_skew_checks_use_undelayed_timing_inputs.expected
*/
// Enable negative timing checks as specified in §31.9.4.
`timescale 1ns/1ns
module skew_input_probe #(parameter int SETUP_LIMIT = -8)
                        (input wire reference, data);
  wire delayed_reference, delayed_data;
  reg skew_notice = 0, time_notice = 0, full_notice = 0;
  time skew_at = 0, time_at = 0, full_at = 0;
  time delayed_reference_at = 0, delayed_data_at = 0;

  always @(skew_notice) if (skew_notice == 1) skew_at = $time;
  always @(time_notice) if (time_notice == 1) time_at = $time;
  always @(full_notice) if (full_notice == 1) full_at = $time;
  always @(posedge delayed_reference) delayed_reference_at = $time;
  always @(posedge delayed_data) delayed_data_at = $time;

  specify
    $setuphold(posedge reference, posedge data, SETUP_LIMIT, 12, , , ,
               delayed_reference, delayed_data);
    $skew(posedge reference, posedge data, 3, skew_notice);
    $timeskew(posedge reference, posedge data, 3, time_notice, 1, 0);
    $fullskew(posedge reference, posedge data, 3, 30, full_notice, 1, 0);
  endspecify

  task automatic report(input string label);
    $display("%s copies=%0d,%0d skew=%0d timeskew=%0d fullskew=%0d",
             label, delayed_reference_at, delayed_data_at, skew_at, time_at, full_at);
  endtask
endmodule

module test_skew_checks_use_undelayed_timing_inputs;
  bit reference, data;
  skew_input_probe shifted(reference, data);
  skew_input_probe #(0) control(reference, data);

  initial begin
    // At the original inputs the forward gap is 4. At the delayed copies
    // the order reverses, and the reverse limit of $fullskew is 30.
    #20 reference = 1;
    #4 data = 1;
    #40;
    shifted.report("negative setup");
    control.report("zero setup");
    $finish;
  end
endmodule
