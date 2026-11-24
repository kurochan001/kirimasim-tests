/*
:name: test_default_coverpoint_bins_count_only_other_values
:description: An illegal default value bin reports an outside sample after ordinary values are accepted
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5 19.5.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_default_coverpoint_bins_count_only_other_values.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*\boutside_values\b)[^\n]+
*/
`timescale 1ns/1ns
module test_default_coverpoint_bins_count_only_other_values;
  bit [2:0] value;
  covergroup monitor;
    values: coverpoint value {
      bins known_value = {1, 2};
      illegal_bins outside_values = default;
    }
  endgroup
  monitor recorder;

  initial begin
    recorder = new;
    value = 1; recorder.sample();
    value = 2; recorder.sample();
    $display("known values accepted");
    #1 value = 5; recorder.sample();
    #1 $finish(0);
  end
endmodule
