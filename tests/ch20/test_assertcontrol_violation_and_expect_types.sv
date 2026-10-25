/*
:name: test_assertcontrol_violation_and_expect_types
:description: assertion_type 16 of $assertcontrol selects expect statements and 32, 64 and 128 the violation reports of unique, unique0 and priority case statements; $assertoff, whose assertion_type is 15, leaves violation reports alone while $assertcontrol(4) without a type turns them off, and $assertfailoff, whose type is 31, also covers expect statements (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 12.5.3 12.4.2.1 16.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertcontrol_violation_and_expect_types.expected
:expected_stderr_regex: \A(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:50:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:52:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:54:)(?![\s\S]*test_assertcontrol_violation_and_expect_types\.sv:58:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:60:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:62:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:67:)(?![\s\S]*test_assertcontrol_violation_and_expect_types\.sv:69:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:71:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:76:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:78:)(?![\s\S]*test_assertcontrol_violation_and_expect_types\.sv:80:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:85:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:87:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:89:)(?![\s\S]*test_assertcontrol_violation_and_expect_types\.sv:94:)(?![\s\S]*test_assertcontrol_violation_and_expect_types\.sv:96:)(?![\s\S]*test_assertcontrol_violation_and_expect_types\.sv:98:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:102:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:104:)(?=[\s\S]*test_assertcontrol_violation_and_expect_types\.sv:106:)
*/
// IEEE 1800-2023 §20.11, Table 20-6: assertion_type 16 selects expect
// statements, 32 unique, 64 unique0 and 128 priority violation reports.
// control_type 4 (Off) turns off the violation reports of the selected
// types and 3 (On) turns them on again; 9 (FailOff) and 8 (FailOn) act on
// the fail actions of assertions and expect statements but not on violation
// reports. $assertoff is $assertcontrol(4, 15, 7), so it does not select
// violation reports, and $assertfailoff and $assertfailon are
// $assertcontrol(9, 31, 7) and $assertcontrol(8, 31, 7), which select expect
// statements. §12.5.3, §12.4.2.1: a unique case with no matching item, a
// unique0 case with two matching items and a priority case with no matching
// item each give a violation report in the Observed region of the step.
// Every group of three case statements below has its own lines, one unit of
// time apart, and the regular expression requires a report at the lines
// whose type is on and none at the lines whose type is off. The expect
// statement fails at each use; its fail action and that of a simple
// immediate assertion count failures, which the test prints.
// Neither simulator runs this test: Icarus Verilog 13.0 does not support
// expect, and release 5.052 of the Verilator tool supports neither expect
// nor these assertion types.
`timescale 1ns/1ns

module test_assertcontrol_violation_and_expect_types;
  logic clk = 0;
  logic p, q, z = 0;
  int si_f = 0, ex_f = 0;

  always #5 clk = ~clk;

  task automatic fail_both(string name);
    a_si: assert (z) else si_f++;
    expect (@(posedge clk) z) else ex_f++;
    $display("%s: immediate %0d expect %0d", name, si_f, ex_f);
  endtask

  initial begin
    p = 0; q = 0;
    unique case (1'b1) p: ; q: ; endcase
    p = 1; q = 1;
    unique0 case (1'b1) p: ; q: ; endcase
    p = 0; q = 0;
    priority case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(4, 32);
    p = 0; q = 0;
    unique case (1'b1) p: ; q: ; endcase
    p = 1; q = 1;
    unique0 case (1'b1) p: ; q: ; endcase
    p = 0; q = 0;
    priority case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(3, 32);
    $assertcontrol(4, 64);
    p = 0; q = 0;
    unique case (1'b1) p: ; q: ; endcase
    p = 1; q = 1;
    unique0 case (1'b1) p: ; q: ; endcase
    p = 0; q = 0;
    priority case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(3, 64);
    $assertcontrol(4, 128);
    p = 0; q = 0;
    unique case (1'b1) p: ; q: ; endcase
    p = 1; q = 1;
    unique0 case (1'b1) p: ; q: ; endcase
    p = 0; q = 0;
    priority case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(3, 128);
    $assertoff;
    p = 0; q = 0;
    unique case (1'b1) p: ; q: ; endcase
    p = 1; q = 1;
    unique0 case (1'b1) p: ; q: ; endcase
    p = 0; q = 0;
    priority case (1'b1) p: ; q: ; endcase
    #1;
    $asserton;
    $assertcontrol(4);
    p = 0; q = 0;
    unique case (1'b1) p: ; q: ; endcase
    p = 1; q = 1;
    unique0 case (1'b1) p: ; q: ; endcase
    p = 0; q = 0;
    priority case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(3);
    p = 0; q = 0;
    unique case (1'b1) p: ; q: ; endcase
    p = 1; q = 1;
    unique0 case (1'b1) p: ; q: ; endcase
    p = 0; q = 0;
    priority case (1'b1) p: ; q: ; endcase
    #1;
    #10;
    fail_both("both on");
    $assertcontrol(9, 16);
    fail_both("failoff 16");
    $assertcontrol(8, 16);
    $assertcontrol(9, 15);
    fail_both("failoff 15");
    $assertcontrol(8);
    $assertfailoff;
    fail_both("assertfailoff");
    $assertfailon;
    fail_both("assertfailon");
    $finish;
  end
endmodule
