/*
:name: test_unique_case_no_match_report_and_default
:description: a unique or priority case, casez or casex in which no case item matches gives a violation report and executes nothing, a default item takes the unmatched value without a report, and a unique0 case gives no report when nothing matches (IEEE 1800-2023 Section 12.5.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unique_case_no_match_report_and_default.expected
:expected_stderr_regex: \A(?=[\s\S]*test_unique_case_no_match_report_and_default\.sv:59\b)(?=[\s\S]*test_unique_case_no_match_report_and_default\.sv:60\b)(?![\s\S]*test_unique_case_no_match_report_and_default\.sv:61\b)(?![\s\S]*test_unique_case_no_match_report_and_default\.sv:62\b)(?![\s\S]*test_unique_case_no_match_report_and_default\.sv:63\b)(?![\s\S]*test_unique_case_no_match_report_and_default\.sv:64\b)(?![\s\S]*test_unique_case_no_match_report_and_default\.sv:65\b)(?=[\s\S]*test_unique_case_no_match_report_and_default\.sv:66\b)(?=[\s\S]*test_unique_case_no_match_report_and_default\.sv:67\b)(?![\s\S]*test_unique_case_no_match_report_and_default\.sv:68\b)
*/
// IEEE 1800-2023 §12.5.3: when no case item of a unique-case or
// priority-case matches the case expression, a violation report is issued;
// it may come at compile time when the violation can be found then, and
// otherwise during the run. §12.5 counts the default as a case item, whose
// statement runs when every comparison fails, so a case with a default
// always has an item for the value and no such report is due. A
// unique0-case shall not issue a report when no item matches.
//
// s is 5 and the item expressions are variables; k0 = 0, k1 = 1 and k5 = 5,
// kz = 3'b0zz (casez) and kx = 3'b0xx (casex) do not match 5 under the
// rules of their case kind, since the top bit differs. Each item writes its
// own value into w[n], and a default item writes 9:
//   w[1] unique case, no match, no default: report, nothing runs (0).
//   w[2] priority case, the same: report, 0.
//   w[3] unique0 case, the same: no report, 0.
//   w[4] unique case with default: the default runs (9), no report.
//   w[5] priority case with default: 9, no report.
//   w[6] unique0 case with default: 9, no report.
//   w[7] unique case whose second item matches: 2, no report.
//   w[8] priority casez, no match: report, 0.
//   w[9] unique casex, no match: report, 0.
//   w[10] unique0 casez, no match: no report, 0.
// The regular expression requires a report naming the lines of w[1], w[2],
// w[8] and w[9] and rejects any naming the other lines. An implementation
// that reports no-match for unique0, or ignores a default item, reports
// where none is due; one without the no-match check misses reports; one
// that runs an item when none matches changes the printed 0. The standard
// leaves the form and the time of a report to the tool; like the other
// violation-report tests of the suite, the test expects the report to name
// the file and line of the case statement.
// Release 5.054 of the Verilator tool does not support a casez or casex
// item held in a variable with x or z bits.

module test_unique_case_no_match_report_and_default;
  logic [2:0] s, k0, k1, k5, kz, kx;
  int w [1:10];

  initial begin
    s = 3'd5;
    k0 = 3'd0;
    k1 = 3'd1;
    k5 = 3'd5;
    kz = 3'b0zz;
    kx = 3'b0xx;

    unique case (s) k0: w[1] = 1; k1: w[1] = 2; endcase
    priority case (s) k0: w[2] = 1; k1: w[2] = 2; endcase
    unique0 case (s) k0: w[3] = 1; k1: w[3] = 2; endcase
    unique case (s) k0: w[4] = 1; k1: w[4] = 2; default: w[4] = 9; endcase
    priority case (s) k0: w[5] = 1; k1: w[5] = 2; default: w[5] = 9; endcase
    unique0 case (s) k0: w[6] = 1; k1: w[6] = 2; default: w[6] = 9; endcase
    unique case (s) k0: w[7] = 1; k5: w[7] = 2; endcase
    priority casez (s) k0: w[8] = 1; kz: w[8] = 2; endcase
    unique casex (s) k1: w[9] = 1; kx: w[9] = 2; endcase
    unique0 casez (s) k1: w[10] = 1; kz: w[10] = 2; endcase

    $display("no match:     unique %0d priority %0d unique0 %0d", w[1], w[2], w[3]);
    $display("default:      unique %0d priority %0d unique0 %0d", w[4], w[5], w[6]);
    $display("match:        unique %0d", w[7]);
    $display("wildcard:     priority casez %0d unique casex %0d unique0 casez %0d",
             w[8], w[9], w[10]);
  end
endmodule
