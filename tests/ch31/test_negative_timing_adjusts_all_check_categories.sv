/*
:name: test_negative_timing_adjusts_all_check_categories
:description: compare nine timing checks on internally delayed inputs with equivalent checks on explicitly shifted waveforms
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.1 31.9.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_negative_timing_adjusts_all_check_categories.expected
*/
// Enable negative timing checks as specified in §31.9.4.
`timescale 1ns/1ns
module adjusted_timing_probe #(parameter bit SHIFTED_INPUTS = 0)
                             (input wire reference, sample, ref_anchor, data_anchor);
  // The two negative setup limits give delays of 8 on reference and 5
  // on sample. Their difference adds 3 to the setup-like limit and takes
  // 3 off the hold-like limit. It also turns the (-3, 3) level window into
  // the high interval of the delayed reference.
  localparam int REF_SETUP = SHIFTED_INPUTS ? 0 : -8;
  localparam int DATA_SETUP = SHIFTED_INPUTS ? 0 : -5;
  localparam int BEFORE = SHIFTED_INPUTS ? 7 : 4;
  localparam int AFTER = SHIFTED_INPUTS ? 6 : 9;
  localparam int OPEN_OFFSET = SHIFTED_INPUTS ? 0 : -3;
  localparam int CLOSE_OFFSET = SHIFTED_INPUTS ? 0 : 3;

  wire delayed_reference, delayed_sample, delayed_ref_anchor, delayed_data_anchor;
  reg n_setup = 0, n_hold = 0, n_setuphold = 0;
  reg n_recovery = 0, n_removal = 0, n_recrem = 0;
  reg n_width = 0, n_period = 0, n_nochange = 0;
  time setup_at = 0, hold_at = 0, setuphold_at = 0;
  time recovery_at = 0, removal_at = 0, recrem_at = 0;
  time width_at = 0, period_at = 0, nochange_at = 0;
  time first_reference = 0, first_sample = 0;

  specify
    $setuphold(posedge reference, posedge ref_anchor, REF_SETUP, 20, , , ,
               delayed_reference, delayed_ref_anchor);
    $setuphold(posedge sample, posedge data_anchor, DATA_SETUP, 20, , , ,
               delayed_sample, delayed_data_anchor);
    $setup(posedge sample, posedge reference, BEFORE, n_setup);
    $hold(posedge reference, posedge sample, AFTER, n_hold);
    $setuphold(posedge reference, posedge sample, BEFORE, AFTER, n_setuphold);
    $recovery(posedge sample, posedge reference, BEFORE, n_recovery);
    $removal(posedge sample, posedge reference, AFTER, n_removal);
    $recrem(posedge sample, posedge reference, BEFORE, AFTER, n_recrem);
    $width(posedge reference, 12, 0, n_width);
    $period(posedge reference, 30, n_period);
    $nochange(posedge reference, posedge sample, OPEN_OFFSET, CLOSE_OFFSET, n_nochange);
  endspecify

  always @(posedge delayed_reference) if (first_reference == 0) first_reference = $time;
  always @(posedge delayed_sample) if (first_sample == 0) first_sample = $time;
  always @(n_setup) record("setup", setup_at);
  always @(n_hold) record("hold", hold_at);
  always @(n_setuphold) record("setuphold", setuphold_at);
  always @(n_recovery) record("recovery", recovery_at);
  always @(n_removal) record("removal", removal_at);
  always @(n_recrem) record("recrem", recrem_at);
  always @(n_width) record("width", width_at);
  always @(n_period) record("period", period_at);
  always @(n_nochange) record("nochange", nochange_at);

  task automatic record(input string check, inout time notified_at);
    if ($time >= 17) begin
      if (notified_at != 0)
        $display("extra %s notification at %0d", check, $time);
      notified_at = $time;
    end
  endtask

  task automatic report(input string label);
    $write("%s first=%0d,%0d setup=%0d hold=%0d setuphold=%0d",
           label, first_reference, first_sample, setup_at, hold_at, setuphold_at);
    $display(" recovery=%0d removal=%0d recrem=%0d width=%0d period=%0d nochange=%0d",
             recovery_at, removal_at, recrem_at, width_at, period_at, nochange_at);
  endtask
endmodule

module test_negative_timing_adjusts_all_check_categories;
  bit reference;
  bit [0:3] sample;
  wire shifted_reference;

  assign #8 shifted_reference = reference;
  for (genvar idx = 0; idx < 4; idx++) begin : lanes
    wire shifted_sample;
    assign #5 shifted_sample = sample[idx];
    adjusted_timing_probe native_check(reference, sample[idx], 1'b0, 1'b0);
    adjusted_timing_probe #(1) shifted_check(shifted_reference, shifted_sample, 1'b0, 1'b0);
  end

  initial begin
    #17 sample[0] = 1; // Raw setup/recovery window (16, 20).
    #7 sample[1] = 1;  // Raw hold/removal window (20, 29) and level window (23, 33).
    #7 sample[2] = 1;  // Only the level window.
    #3 sample[3] = 1;  // Outside all sample windows.
  end

  initial begin
    #20 reference = 1;
    #10 reference = 0;
    #15 reference = 1;
    #20;
    lanes[0].native_check.report("native 17");
    lanes[0].shifted_check.report("shifted 17");
    lanes[1].native_check.report("native 24");
    lanes[1].shifted_check.report("shifted 24");
    lanes[2].native_check.report("native 31");
    lanes[2].shifted_check.report("shifted 31");
    lanes[3].native_check.report("native 34");
    lanes[3].shifted_check.report("shifted 34");
    $finish;
  end
endmodule
