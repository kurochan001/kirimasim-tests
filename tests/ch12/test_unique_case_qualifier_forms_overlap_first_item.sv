/*
:name: test_unique_case_qualifier_forms_overlap_first_item
:description: case, casez and casex each take the unique, unique0 and priority qualifiers; when two case items match, all nine forms execute only the textually first matching item, unique and unique0 give a violation report and priority gives none, and no report is given when the matching rules of the case kind leave only one item matching (IEEE 1800-2023 Section 12.5.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unique_case_qualifier_forms_overlap_first_item.expected
:expected_stderr_regex: \A(?=[\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:60\b)(?=[\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:61\b)(?![\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:62\b)(?=[\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:63\b)(?=[\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:64\b)(?![\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:65\b)(?=[\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:66\b)(?=[\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:67\b)(?![\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:68\b)(?![\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:70\b)(?![\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:71\b)(?![\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:72\b)(?![\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:73\b)(?![\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:74\b)(?![\s\S]*test_unique_case_qualifier_forms_overlap_first_item\.sv:75\b)
*/
// IEEE 1800-2023 §12.5.3: case, casez and casex can each be qualified by
// unique, unique0 or priority. A priority-case acts on its first matching
// item only. A unique-case or unique0-case asserts that its items do not
// overlap: if more than one item matches the case expression, a violation
// is reported and only the statement of the matching item that comes first
// in the text is executed. Whether an item matches follows the rules of the
// case kind (§12.5, §12.5.1): exact four-state equality for case, z bits as
// don't-care for casez, x and z bits for casex.
//
// s is 4'b0110. ia and id equal s; iz = 4'b0z1z matches s only where z is a
// don't-care, ix = 4'b0x1x only where x is one; i0 and ie match nothing.
// Each item adds 1, 10 or 100 to w[n] for the first, second or third item,
// so w[n] tells which items ran and how often. Every case statement below
// has a non-matching first item and a match at the second item:
//   overlap lines (w[1] to w[9]): the third item matches as well, with id,
//     ia or iz for case, casez or casex. All print 10. unique and unique0
//     report a violation; priority does not.
//   single-match lines (w[10] to w[15]): under the rules of the case kind
//     the third item does not match (iz for case, ix for casez, ie for
//     casex). All print 10 and nothing is reported.
// The regular expression requires a report naming each unique and unique0
// overlap line and rejects any naming a priority line or a single-match
// line. An implementation that runs the last matching item prints 100 and
// one that runs every match 110 on the overlap lines; one that does not
// check for overlap misses reports; one that treats priority like unique,
// or applies wildcard matching to the wrong case kind, reports where none
// is due. The standard leaves the form of a report to the tool; like the
// other violation-report tests of the suite, the test expects the report
// to name the file and line of the case statement.
// Icarus Verilog 13.0 ignores unique and unique0 on a case statement and
// reports no overlap. Release 5.054 of the Verilator tool does not support
// a casez or casex item held in a variable with x or z bits.

module test_unique_case_qualifier_forms_overlap_first_item;
  logic [3:0] s, i0, ia, id, iz, ix, ie;
  int w [1:15];

  initial begin
    s = 4'b0110;
    i0 = 4'b1111;
    ia = 4'b0110;
    id = 4'b0110;
    iz = 4'b0z1z;
    ix = 4'b0x1x;
    ie = 4'b0101;

    unique case (s) i0: w[1] += 1; ia: w[1] += 10; id: w[1] += 100; endcase
    unique0 case (s) i0: w[2] += 1; ia: w[2] += 10; id: w[2] += 100; endcase
    priority case (s) i0: w[3] += 1; ia: w[3] += 10; id: w[3] += 100; endcase
    unique casez (s) i0: w[4] += 1; iz: w[4] += 10; ia: w[4] += 100; endcase
    unique0 casez (s) i0: w[5] += 1; iz: w[5] += 10; ia: w[5] += 100; endcase
    priority casez (s) i0: w[6] += 1; iz: w[6] += 10; ia: w[6] += 100; endcase
    unique casex (s) i0: w[7] += 1; ix: w[7] += 10; iz: w[7] += 100; endcase
    unique0 casex (s) i0: w[8] += 1; ix: w[8] += 10; iz: w[8] += 100; endcase
    priority casex (s) i0: w[9] += 1; ix: w[9] += 10; iz: w[9] += 100; endcase

    unique case (s) i0: w[10] += 1; ia: w[10] += 10; iz: w[10] += 100; endcase
    unique0 case (s) i0: w[11] += 1; ia: w[11] += 10; iz: w[11] += 100; endcase
    unique casez (s) i0: w[12] += 1; iz: w[12] += 10; ix: w[12] += 100; endcase
    unique0 casez (s) i0: w[13] += 1; iz: w[13] += 10; ix: w[13] += 100; endcase
    unique casex (s) i0: w[14] += 1; ix: w[14] += 10; ie: w[14] += 100; endcase
    unique0 casex (s) i0: w[15] += 1; ix: w[15] += 10; ie: w[15] += 100; endcase

    $display("overlap case:  unique %0d unique0 %0d priority %0d", w[1], w[2], w[3]);
    $display("overlap casez: unique %0d unique0 %0d priority %0d", w[4], w[5], w[6]);
    $display("overlap casex: unique %0d unique0 %0d priority %0d", w[7], w[8], w[9]);
    $display("single case:  unique %0d unique0 %0d", w[10], w[11]);
    $display("single casez: unique %0d unique0 %0d", w[12], w[13]);
    $display("single casex: unique %0d unique0 %0d", w[14], w[15]);
  end
endmodule
