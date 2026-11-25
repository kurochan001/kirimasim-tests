/*
:name: test_negative_timing_copies_align_setup_and_hold
:description: negative setup and hold cases align the delayed check inputs with the shifted violation window
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.9.3 31.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_negative_timing_copies_align_setup_and_hold.expected
*/
// Enable negative timing checks as specified in §31.9.4.
`timescale 1ns/1ns
module negative_edge_probe #(parameter int SETUP = -5, HOLD = 12)
                            (input wire reference, data);
  wire delayed_reference, delayed_data;
  reg setuphold_notice = 0;
  time reference_at = 0, data_at = 0, setuphold_at = 0;

  specify
    $setuphold(posedge reference, posedge data, SETUP, HOLD, setuphold_notice, , ,
               delayed_reference, delayed_data);
  endspecify

  always @(posedge delayed_reference) reference_at = $time;
  always @(posedge delayed_data) data_at = $time;
  always @(setuphold_notice) if ($time != 0) begin
    if (setuphold_at != 0) $display("extra setuphold notification");
    setuphold_at = $time;
  end
  task automatic report(input string label);
    $display("%s ref=%0d data=%0d setuphold=%0d", label, reference_at, data_at, setuphold_at);
  endtask
endmodule

module test_negative_timing_copies_align_setup_and_hold;
  bit reference;
  bit [0:2] setup_data, hold_data;
  for (genvar idx = 0; idx < 3; idx++) begin : lanes
    negative_edge_probe setup_shift(reference, setup_data[idx]);
    negative_edge_probe #(12, -5) hold_shift(reference, hold_data[idx]);
  end

  initial begin
    // The negative-hold model's open window is (28, 35).
    #26 hold_data[0] = 1;
    #6 hold_data[1] = 1;
    #6 hold_data[2] = 1;
    #2 reference = 1;
    // The negative-setup model's open window is (45, 52).
    #2 setup_data[0] = 1;
    #6 setup_data[1] = 1;
    #6 setup_data[2] = 1;
    #10;
    lanes[0].hold_shift.report("hold before");
    lanes[1].hold_shift.report("hold inside");
    lanes[2].hold_shift.report("hold after");
    lanes[0].setup_shift.report("setup before");
    lanes[1].setup_shift.report("setup inside");
    lanes[2].setup_shift.report("setup after");
    $finish;
  end
endmodule
