/*
:name: test_negative_timing_notifiers_follow_delayed_violating_edges
:description: Negative setuphold and recrem notifiers change at the delayed violating edge when both original inputs acquire delays
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.3 31.9.1 31.9.4 31.3.3 31.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_negative_timing_notifiers_follow_delayed_violating_edges.expected
*/
// A second check with an inactive reference imposes a delay on the main
// check's earlier input. Compare the notifier with the observed delayed edge.
`timescale 1ns/1ns
module shifted_notifier_probe #(parameter bit BEFORE = 0)
                                (input wire reference, sample, guard);
  localparam int LEFT = BEFORE ? 12 : -5;
  localparam int RIGHT = BEFORE ? -5 : 12;
  localparam int REF_GUARD_HOLD = BEFORE ? -3 : 3;
  localparam int DATA_GUARD_HOLD = BEFORE ? 3 : -3;
  wire delayed_reference, delayed_sample, delayed_guard;
  reg sh = 0, rr = 0;
  time reference_time = 0, sample_time = 0, sh_time = 0, rr_time = 0;

  always @(sh) if (sh == 1) sh_time = $time;
  always @(rr) if (rr == 1) rr_time = $time;
  always @(posedge delayed_reference) reference_time = $time;
  always @(posedge delayed_sample) sample_time = $time;

  specify
    $setuphold(posedge reference, posedge sample, LEFT, RIGHT, sh, , ,
               delayed_reference, delayed_sample);
    $recrem(posedge reference, posedge sample, LEFT, RIGHT, rr, , ,
            delayed_reference, delayed_sample);
    $setuphold(posedge guard, posedge reference, 10, REF_GUARD_HOLD, , , ,
               delayed_guard, delayed_reference);
    $setuphold(posedge guard, posedge sample, 10, DATA_GUARD_HOLD, , , ,
               delayed_guard, delayed_sample);
  endspecify
endmodule

module test_negative_timing_notifiers_follow_delayed_violating_edges;
  bit reference, early_sample, late_sample, guard;
  shifted_notifier_probe #(1) before_ref(reference, early_sample, guard);
  shifted_notifier_probe #(0) after_ref(reference, late_sample, guard);

  task automatic show(input string label_text, input time original_ref, original_data,
                      delayed_ref, delayed_data, notified, input bit compare_ref);
    time violating_time;
    violating_time = compare_ref ? delayed_ref : delayed_data;
    $display("%s both delayed=%0d edge aligned=%0d late=%0d", label_text,
             delayed_ref > original_ref && delayed_data > original_data,
             notified == violating_time && notified != 0,
             notified > (compare_ref ? original_ref : original_data));
  endtask

  initial begin
    #32 early_sample = 1;
    #8 reference = 1;
    #8 late_sample = 1;
    #22;
    show("before setuphold", 40, 32, before_ref.reference_time,
         before_ref.sample_time, before_ref.sh_time, 1);
    show("before recrem", 40, 32, before_ref.reference_time,
         before_ref.sample_time, before_ref.rr_time, 1);
    show("after setuphold", 40, 48, after_ref.reference_time,
         after_ref.sample_time, after_ref.sh_time, 0);
    show("after recrem", 40, 48, after_ref.reference_time,
         after_ref.sample_time, after_ref.rr_time, 0);
    $finish(0);
  end
endmodule
