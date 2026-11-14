/*
:name: test_unique_case_matching_expressions_in_one_item
:description: a unique or unique0 case item that lists several expressions matching the case expression is not an overlap, so no violation report is given and its statement runs once, while the same matches spread over two case items are reported and run only the first of them (IEEE 1800-2023 Section 12.5.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unique_case_matching_expressions_in_one_item.expected
:expected_stderr_regex: \A(?![\s\S]*test_unique_case_matching_expressions_in_one_item\.sv:56\b)(?![\s\S]*test_unique_case_matching_expressions_in_one_item\.sv:57\b)(?![\s\S]*test_unique_case_matching_expressions_in_one_item\.sv:58\b)(?=[\s\S]*test_unique_case_matching_expressions_in_one_item\.sv:59\b)(?=[\s\S]*test_unique_case_matching_expressions_in_one_item\.sv:60\b)(?=[\s\S]*test_unique_case_matching_expressions_in_one_item\.sv:61\b)(?=[\s\S]*test_unique_case_matching_expressions_in_one_item\.sv:62\b)
*/
// IEEE 1800-2023 §12.5.3: a unique-case or unique0-case is violated when
// more than one case item matches; a single case item with more than one
// matching expression is not a violation of uniqueness. Once one
// expression of an item matches, the others of that item need not be
// evaluated; the expressions here have no side effects, so the result does
// not depend on whether they are.
//
// s is 6; a and b equal it, c is 1, and za = 4'b01zz and zb = 4'bz11z
// match it under casez. The first, second and third item add 1, 10 and 100
// to w[n], so w[n] tells which items ran and how often:
//   w[1] unique case, items c / a, b: one item matches twice: 10, no report.
//   w[2] unique0 case, the same: 10, no report.
//   w[3] unique casez, items c / za, zb: 10, no report.
//   w[4] unique case, items c, a / b: the first item matches through a and
//        the second through b: two items, 1, report.
//   w[5] unique case, items c / a / b: two items, 10, report.
//   w[6] unique0 case, the same: 10, report.
//   w[7] unique casez, items c / za / zb: two items, 10, report.
// The regular expression requires a report naming the lines of w[4] to
// w[7] and rejects any naming those of w[1] to w[3]. An implementation that
// counts matching expressions instead of items reports the first three
// lines; one that runs an item once for each matching expression prints 20
// for them; one that ignores the overlap of separate items misses reports.
// The standard leaves the form of a report to the tool; like the other
// violation-report tests of the suite, the test expects the report to name
// the file and line of the case statement.
// Icarus Verilog 13.0 ignores unique and unique0 on a case statement and
// reports no overlap. Release 5.054 of the Verilator tool does not support
// a casez item held in a variable with z bits.

module test_unique_case_matching_expressions_in_one_item;
  logic [3:0] s, a, b, c, za, zb;
  int w [1:7];

  initial begin
    s = 4'd6;
    a = 4'd6;
    b = 4'd6;
    c = 4'd1;
    za = 4'b01zz;
    zb = 4'bz11z;

    unique case (s) c: w[1] += 1; a, b: w[1] += 10; endcase
    unique0 case (s) c: w[2] += 1; a, b: w[2] += 10; endcase
    unique casez (s) c: w[3] += 1; za, zb: w[3] += 10; endcase
    unique case (s) c, a: w[4] += 1; b: w[4] += 10; endcase
    unique case (s) c: w[5] += 1; a: w[5] += 10; b: w[5] += 100; endcase
    unique0 case (s) c: w[6] += 1; a: w[6] += 10; b: w[6] += 100; endcase
    unique casez (s) c: w[7] += 1; za: w[7] += 10; zb: w[7] += 100; endcase

    $display("one item:  unique %0d unique0 %0d unique casez %0d", w[1], w[2], w[3]);
    $display("two items: unique %0d %0d unique0 %0d unique casez %0d", w[4], w[5], w[6], w[7]);
  end
endmodule
