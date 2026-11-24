/*
:name: test_default_transition_bin_ignores_a_pending_nonconsecutive_match
:description: A nonconsecutive transition remains pending across skipped samples before its bin is covered
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 19.5.2 19.8 19.11.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_transition_bin_ignores_a_pending_nonconsecutive_match.expected
*/
module test_default_transition_bin_ignores_a_pending_nonconsecutive_match;
  bit [3:0] sample_value;
  covergroup monitor;
    transitions: coverpoint sample_value {
      bins wait_path = (1 => 3[->1]);
      bins unmatched_transition = default sequence;
    }
  endgroup
  monitor recorder;

  initial begin
    recorder = new;
    sample_value = 1; recorder.sample();
    sample_value = 2; recorder.sample();
    sample_value = 0; recorder.sample();
    $display("before match=%.2f", recorder.get_inst_coverage());
    sample_value = 3; recorder.sample();
    $display("after match=%.2f", recorder.get_inst_coverage());
  end
endmodule
