/*
:name: test_coverpoint_distinguishes_literal_unknowns_from_evaluated_unknowns
:description: Coverage preserves an explicit unknown literal, excludes an evaluated unknown, and expands wildcard bits
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.5.7 19.5.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_coverpoint_distinguishes_literal_unknowns_from_evaluated_unknowns.expected
:expected_stderr_regex: (?ms)\A(?=.*?^(?=[^\n]*(?i:warning))(?=[^\n]*(?:expression_bin|test_coverpoint_distinguishes_literal_unknowns_from_evaluated_unknowns\.sv:22:))[^\n]+)(?!.*?^(?=[^\n]*(?i:warning))(?=[^\n]*(?:literal_bin|test_coverpoint_distinguishes_literal_unknowns_from_evaluated_unknowns\.sv:21:))[^\n]+)
*/
module test_coverpoint_distinguishes_literal_unknowns_from_evaluated_unknowns;
  logic [3:0] literal_sample;
  logic [3:0] wildcard_sample;
  bit [15:0] matched_values;

  covergroup exact_values;
    point: coverpoint literal_sample {
      bins literal_bin = {4'b1x0z};
      bins expression_bin = {4'd2, (4'b1000 | 4'b0x00)};
    }
  endgroup
  covergroup mask_values;
    option.per_instance = 1;
    point: coverpoint wildcard_sample {
      wildcard bins masked = {4'b1?0?};
    }
  endgroup

  exact_values exact;
  mask_values mask;
  initial begin
    exact = new;
    literal_sample = 4'b1z0z; exact.sample();
    $display("different unknown kind=%.2f", exact.get_inst_coverage());
    literal_sample = 4'b1x00; exact.sample();
    $display("different unknown positions=%.2f", exact.get_inst_coverage());
    literal_sample = 4'b1x0z; exact.sample();
    $display("unknown sample=%.2f", exact.get_inst_coverage());
    literal_sample = 8; exact.sample();
    $display("coercion control=%.2f", exact.get_inst_coverage());
    literal_sample = 2; exact.sample();
    $display("known sample=%.2f", exact.get_inst_coverage());

    for (int value = 0; value < 16; value++) begin
      mask = new;
      wildcard_sample = 4'(value);
      mask.sample();
      matched_values[value] = mask.get_inst_coverage() == 100.0;
    end
    $display("wildcard matches=%04h", matched_values);
  end
endmodule
