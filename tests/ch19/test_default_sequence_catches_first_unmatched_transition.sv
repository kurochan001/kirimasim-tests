/*
:name: test_default_sequence_catches_first_unmatched_transition
:description: An illegal default sequence reports an unmatched transition after a known sequence
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 19.5.2 19.5.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_sequence_catches_first_unmatched_transition.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*\bunmatched_path\b)[^\n]+
*/
`timescale 1ns/1ns
module test_default_sequence_catches_first_unmatched_transition;
  bit [2:0] value;
  covergroup monitor;
    transitions: coverpoint value {
      bins known_path = (1 => 2);
      illegal_bins unmatched_path = default sequence;
    }
  endgroup
  monitor recorder;

  initial begin
    recorder = new;
    value = 1; recorder.sample();
    value = 2; recorder.sample();
    $display("known sequence accepted");
    #1 value = 5; recorder.sample();
    #1 $finish(0);
  end
endmodule
