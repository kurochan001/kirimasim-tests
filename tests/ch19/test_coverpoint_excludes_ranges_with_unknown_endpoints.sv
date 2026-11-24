/*
:name: test_coverpoint_excludes_ranges_with_unknown_endpoints
:description: Coverage warns about unknown range endpoints and samples only the valid entries of each bin
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.7 19.5.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_coverpoint_excludes_ranges_with_unknown_endpoints.expected
:expected_stderr_regex: (?ims)\A(?=.*?^(?=[^\n]*warning)(?=[^\n]*(?:\blower\b|test_coverpoint_excludes_ranges_with_unknown_endpoints\.sv:18:))(?=[^\n]*(?:unknown|x\s*[/]\s*z|\bx\b|\bz\b|indeterminate))[^\n]+)(?=.*?^(?=[^\n]*warning)(?=[^\n]*(?:\bupper\b|test_coverpoint_excludes_ranges_with_unknown_endpoints\.sv:19:))(?=[^\n]*(?:unknown|x\s*[/]\s*z|\bx\b|\bz\b|indeterminate))[^\n]+)
*/
module test_coverpoint_excludes_ranges_with_unknown_endpoints;
  logic [2:0] sample_value;
  covergroup monitor;
    ranges: coverpoint sample_value {
      bins lower = {3'd1, [3'b0x0:3'd3]};
      bins upper = {3'd6, [3'd4:3'b1z0]};
    }
    control: coverpoint sample_value {
      wildcard bins wildcard_select = {3'b0x0};
    }
  endgroup
  monitor recorder;

  initial begin
    recorder = new;
    sample_value = 2; recorder.sample();
    $display("value2 ranges=%.2f wildcard=%.2f", recorder.ranges.get_inst_coverage(),
             recorder.control.get_inst_coverage());
    sample_value = 4; recorder.sample();
    $display("value4 ranges=%.2f", recorder.ranges.get_inst_coverage());
    sample_value = 1; recorder.sample();
    $display("value1 ranges=%.2f", recorder.ranges.get_inst_coverage());
    sample_value = 6; recorder.sample();
    $display("value6 ranges=%.2f", recorder.ranges.get_inst_coverage());
  end
endmodule
