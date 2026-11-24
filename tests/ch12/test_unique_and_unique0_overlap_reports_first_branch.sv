/*
:name: test_unique_and_unique0_overlap_reports_first_branch
:description: Unique and unique0 report overlap and execute the first true statement
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_and_unique0_overlap_reports_first_branch.expected
:expected_stderr_regex: (?ms)\A(?=.*?^(?=[^\n]*test_unique_and_unique0_overlap_reports_first_branch\.sv:21(?:\D|$))(?=[^\n]*(?i:multiple|more than one|condition[^\n]*overlap|no match|no condition|violation))[^\n]+)(?=.*?^(?=[^\n]*test_unique_and_unique0_overlap_reports_first_branch\.sv:26(?:\D|$))(?=[^\n]*(?i:multiple|more than one|condition[^\n]*overlap|no match|no condition|violation))[^\n]+)
*/
`timescale 1ns/1ns
module test_unique_and_unique0_overlap_reports_first_branch;
  int selector = 2;
  int unique_branch, unique0_branch;

  initial begin
    #1;
    unique if (selector > 0) unique_branch = 11;
    else if (selector > 1) unique_branch = 12;
    else unique_branch = 19;

    #1;
    unique0 if (selector > 0) unique0_branch = 21;
    else if (selector > 1) unique0_branch = 22;

    #1 $display("unique=%0d unique0=%0d", unique_branch, unique0_branch);
    $finish;
  end
endmodule
