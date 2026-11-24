/*
:name: test_default_bins_with_failed_and_pending_transition_paths
:description: Default bins leave counted coverage unchanged across failed and pending transition paths
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 19.5.2 19.8 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_bins_with_failed_and_pending_transition_paths.expected
*/
module test_default_bins_with_failed_and_pending_transition_paths;
  bit [3:0] sample_value;
  covergroup monitor;
    values: coverpoint sample_value {
      bins expected_values = {1, 2, 5, 6, 8, 10};
      bins unmatched_value = default;
    }
    transitions: coverpoint sample_value {
      bins long_path = (1 => 2 => 3);
      bins short_paths = (5 => 6, 8);
      bins wait_path = (8 => 10[->1]);
      bins unmatched_transition = default sequence;
    }
  endgroup
  monitor recorder;

  initial begin
    bit [3:0] samples [9];
    samples = '{1, 2, 5, 6, 5, 8, 0, 0, 10};
    recorder = new;
    foreach (samples[i]) begin
      sample_value = samples[i];
      recorder.sample();
    end
    $display("value coverage=%.2f transition coverage=%.2f",
             recorder.values.get_inst_coverage(), recorder.transitions.get_inst_coverage());
  end
endmodule
