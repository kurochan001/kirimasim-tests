/*
:name: test_unique_and_priority_report_when_no_branch_matches
:description: Unique and priority report misses without an else and preserve both branch sentinels
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_and_priority_report_when_no_branch_matches.expected
:expected_stderr_regex: (?ms)\A(?=.*?^(?=[^\n]*test_unique_and_priority_report_when_no_branch_matches\.sv:22(?:\D|$))(?=[^\n]*(?i:multiple|more than one|condition[^\n]*overlap|no match|no condition|violation))[^\n]+)(?=.*?^(?=[^\n]*test_unique_and_priority_report_when_no_branch_matches\.sv:26(?:\D|$))(?=[^\n]*(?i:multiple|more than one|condition[^\n]*overlap|no match|no condition|violation))[^\n]+)
*/
`timescale 1ns/1ns
module test_unique_and_priority_report_when_no_branch_matches;
  int selector = 0;
  int unique_branch = -1;
  int priority_branch = -1;

  initial begin
    #1;
    unique if (selector == 1) unique_branch = 11;
    else if (selector == 2) unique_branch = 12;

    #1;
    priority if (selector == 1) priority_branch = 21;
    else if (selector == 2) priority_branch = 22;

    #1 $display("unique=%0d priority=%0d", unique_branch, priority_branch);
    $finish;
  end
endmodule
