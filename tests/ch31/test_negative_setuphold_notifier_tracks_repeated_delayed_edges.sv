/*
:name: test_negative_setuphold_notifier_tracks_repeated_delayed_edges
:description: A negative setuphold notifier follows two delayed violating samples and skips the sample before the shifted window
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.3 31.9.1 31.9.4 31.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_negative_setuphold_notifier_tracks_repeated_delayed_edges.expected
*/
`timescale 1ns/1ns
module shifted_setuphold_probe(input wire reference, observed_data, guard);
  wire delayed_reference, delayed_data, delayed_guard;
  reg notice = 0;
  time data_edges[3], notices[3];
  int data_count = 0, notice_count = 0;

  always @(posedge delayed_data) begin
    if (data_count < 3) data_edges[data_count] = $time;
    data_count++;
  end
  always @(notice) begin
    if ($time != 0) begin
      if (notice_count < 3) notices[notice_count] = $time;
      notice_count++;
    end
  end

  specify
    $setuphold(posedge reference, posedge observed_data, -5, 12, notice, , ,
               delayed_reference, delayed_data);
    $setuphold(posedge guard, posedge reference, 10, 3, , , ,
               delayed_guard, delayed_reference);
    $setuphold(posedge guard, posedge observed_data, 10, -3, , , ,
               delayed_guard, delayed_data);
  endspecify
endmodule

module test_negative_setuphold_notifier_tracks_repeated_delayed_edges;
  bit reference, observed_data, guard;
  shifted_setuphold_probe monitor(reference, observed_data, guard);

  initial begin
    #40 reference = 1;
    #8 observed_data = 1;
    #22;
    $display("first data=%0d notices=%0d delayed=%b aligned=%b", monitor.data_count,
             monitor.notice_count, monitor.data_edges[0] > 48,
             monitor.notices[0] == monitor.data_edges[0]);
    #10;
    reference = 0;
    observed_data = 0;

    #20 reference = 1;
    #4 observed_data = 1;
    #16;
    $display("before window data=%0d notices=%0d", monitor.data_count, monitor.notice_count);
    #10;
    reference = 0;
    observed_data = 0;

    #30 reference = 1;
    #10 observed_data = 1;
    #22;
    $display("last data=%0d notices=%0d delayed=%b aligned=%b", monitor.data_count,
             monitor.notice_count, monitor.data_edges[2] > 170,
             monitor.notices[1] == monitor.data_edges[2]);
    $finish(0);
  end
endmodule
