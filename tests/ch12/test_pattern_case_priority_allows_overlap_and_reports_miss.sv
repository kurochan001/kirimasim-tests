/*
:name: test_pattern_case_priority_allows_overlap_and_reports_miss
:description: A priority pattern case takes the first match and reports a case with no match
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.6.1 12.5.3 12.5.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pattern_case_priority_allows_overlap_and_reports_miss.expected
:expected_stderr_regex: (?ms)\A(?!.*?^(?=[^\n]*test_pattern_case_priority_allows_overlap_and_reports_miss\.sv:21:)(?=[^\n]*(?i:warning|violation|error))(?=[^\n]*(?i:\b(?:priority|unique|case)\b))[^\n]+)(?=.*?^(?=[^\n]*test_pattern_case_priority_allows_overlap_and_reports_miss\.sv:29:)(?=[^\n]*(?i:warning|violation|error))(?=[^\n]*(?i:\b(?:priority|unique|case)\b))[^\n]+)
*/
`timescale 1ns/1ns
module test_pattern_case_priority_allows_overlap_and_reports_miss;
  bit [2:0] opcode;
  int selected;

  initial begin
    #1 opcode = 5;
    priority case (opcode) matches // overlap is allowed
      3'd5: selected = 50;
      .other &&& (other > 4): selected = other + 80;
    endcase
    $display("overlap selected=%0d", selected);

    #1 opcode = 2;
    selected = -1;
    priority case (opcode) matches // miss is reported
      3'd5: selected = 50;
      .other &&& (other > 4): selected = other + 80;
    endcase
    $display("miss selected=%0d", selected);
  end
endmodule
