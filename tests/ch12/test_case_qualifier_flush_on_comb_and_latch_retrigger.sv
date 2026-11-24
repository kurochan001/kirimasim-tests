/*
:name: test_case_qualifier_flush_on_comb_and_latch_retrigger
:description: Combinational and latch retriggers clear pending case reports before the Observed region
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3.1 12.4.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_qualifier_flush_on_comb_and_latch_retrigger.expected
:expected_stderr_regex: (?ms)\A(?!.*?^(?=[^\n]*test_case_qualifier_flush_on_comb_and_latch_retrigger\.sv:24:)(?=[^\n]*(?i:warning|error|violation))(?=[^\n]*(?i:\b(unique0?|priority|case)\b))[^\n]+)(?!.*?^(?=[^\n]*test_case_qualifier_flush_on_comb_and_latch_retrigger\.sv:33:)(?=[^\n]*(?i:warning|error|violation))(?=[^\n]*(?i:\b(unique0?|priority|case)\b))[^\n]+)(?=.*?^(?=[^\n]*test_case_qualifier_flush_on_comb_and_latch_retrigger\.sv:43:)(?=[^\n]*(?i:warning|error|violation))(?=[^\n]*(?i:\b(unique0?|priority|case)\b))[^\n]+)
*/
`timescale 1ns/1ns
module test_case_qualifier_flush_on_comb_and_latch_retrigger;
  bit selected;
  bit complement = 1;
  bit enabled = 1;
  int latch_selector, stable_selector;
  int comb_result, latch_result, stable_result;

  always_comb begin : combinational
    comb_result = 0;
    unique0 case (1'b1)
      selected: comb_result = 14;
      complement: comb_result = 15;
    endcase
    if (selected && complement) $display("combinational overlap was evaluated");
  end

  always_latch begin : latched
    if (enabled) begin
      priority case (latch_selector)
        0: latch_result = 40;
        1: latch_result = 41;
      endcase
      if (latch_selector == 7) $display("latch miss was evaluated");
    end
  end

  always_comb begin : retained
    stable_result = 0;
    unique case (stable_selector)
      0: stable_result = 70;
      1: stable_result = 71;
    endcase
  end

  initial begin
    #5 selected = 1;
    complement <= 0;
    #2 latch_selector = 7;
    latch_selector <= 1;
    stable_selector = 8;
    #1 enabled = 0;
    latch_selector = 0;
    #1 $display("settled comb=%0d latch=%0d stable=%0d", comb_result, latch_result, stable_result);
  end
endmodule
