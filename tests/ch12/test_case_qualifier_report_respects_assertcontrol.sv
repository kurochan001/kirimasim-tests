/*
:name: test_case_qualifier_report_respects_assertcontrol
:description: Turning off only priority reports suppresses a priority case miss and preserves a unique case miss
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3.1 20.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_qualifier_report_respects_assertcontrol.expected
:expected_stderr_regex: (?ms)\A(?!.*?^(?=[^\n]*test_case_qualifier_report_respects_assertcontrol\.sv:21:)(?=[^\n]*(?i:warning|error|violation))(?=[^\n]*(?i:\b(priority|case)\b))[^\n]+)(?=.*?^(?=[^\n]*test_case_qualifier_report_respects_assertcontrol\.sv:22:)(?=[^\n]*(?i:warning|error|violation))(?=[^\n]*(?i:\b(unique|case)\b))[^\n]+)(?=.*?^(?=[^\n]*test_case_qualifier_report_respects_assertcontrol\.sv:26:)(?=[^\n]*(?i:warning|error|violation))(?=[^\n]*(?i:\b(priority|case)\b))[^\n]+)
*/
`timescale 1ns/1ns
module test_case_qualifier_report_respects_assertcontrol;
  int visits;
  initial begin
    int selector;
    $assertcontrol(4, 128);
    selector = 5;
    priority case (selector) 2: visits += 16; endcase // masked
    unique case (selector) 2: visits += 32; endcase // still on
    visits++;
    #1;
    $assertcontrol(3, 128);
    priority case (selector) 2: visits += 64; endcase // restored
    visits++;
    #1 $display("checks completed=%0d", visits);
  end
endmodule
