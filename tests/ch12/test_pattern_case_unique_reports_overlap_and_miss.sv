/*
:name: test_pattern_case_unique_reports_overlap_and_miss
:description: A unique pattern case reports both overlap and no match and accepts an exact match
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6.1 12.5.3 12.5.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pattern_case_unique_reports_overlap_and_miss.expected
:expected_stderr_regex: (?ms)\A(?!.*?^(?=[^\n]*test_pattern_case_unique_reports_overlap_and_miss\.sv:21:)(?=[^\n]*(?i:warning|violation|error))(?=[^\n]*(?i:\b(?:priority|unique|case)\b))[^\n]+)(?=.*?^(?=[^\n]*test_pattern_case_unique_reports_overlap_and_miss\.sv:27:)(?=[^\n]*(?i:warning|violation|error))(?=[^\n]*(?i:\b(?:priority|unique|case)\b))[^\n]+)(?=.*?^(?=[^\n]*test_pattern_case_unique_reports_overlap_and_miss\.sv:33:)(?=[^\n]*(?i:warning|violation|error))(?=[^\n]*(?i:\b(?:priority|unique|case)\b))[^\n]+)
*/
`timescale 1ns/1ns
module test_pattern_case_unique_reports_overlap_and_miss;
  bit [2:0] opcode;
  int visits;

  initial begin
    #1 opcode = 1;
    unique case (opcode) matches // exactly one match
      3'd1: visits++;
      .other &&& (other > 4): visits++;
    endcase

    #1 opcode = 5;
    unique case (opcode) matches // overlap is reported
      3'd5: visits++;
      .other &&& (other > 4): visits++;
    endcase

    #1 opcode = 2;
    unique case (opcode) matches // miss is reported
      3'd5: visits++;
      .other &&& (other > 4): visits++;
    endcase
    #1 $display("selected items=%0d", visits);
  end
endmodule
