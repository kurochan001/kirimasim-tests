/*
:name: test_assertcontrol_directive_type_ignored_for_expect_and_violations
:description: the directive_type argument of $assertcontrol is checked only for assertions, so directive_type 2 (cover) or 4 (assume) still lets a control act on expect statements and on unique violation reports, while it leaves an assert directive alone (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 12.5.3 12.4.2.1 16.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertcontrol_directive_type_ignored_for_expect_and_violations.expected
:expected_stderr_regex: \A(?=[\s\S]*test_assertcontrol_directive_type_ignored_for_expect_and_violations\.sv:50:)(?![\s\S]*test_assertcontrol_directive_type_ignored_for_expect_and_violations\.sv:53:)(?=[\s\S]*test_assertcontrol_directive_type_ignored_for_expect_and_violations\.sv:56:)
*/
// IEEE 1800-2023 §20.11: directive_type (Table 20-7: 1 assert, 2 cover,
// 4 assume) is checked only for assertions; expect statements (assertion_type
// 16) and unique violation reports (assertion_type 32) are selected by
// assertion_type alone. control_type 4 (Off) turns violation reports off and
// 3 (On) on again; 9 (FailOff) and 8 (FailOn) stop and run the fail actions
// of assertions and expect statements.
// §12.5.3, §12.4.2.1: a unique case statement in which no item matches gives
// a violation report in the Observed region of its time step. Off with
// directive_type 4 (assume) turns off the report of line 53, and On with
// directive_type 2 (cover) turns on that of line 56; the regular expression
// requires reports from lines 50 and 56 and none from line 53.
// The simple immediate assertion ai is an assert directive and the expect
// statement (§16.17) is not an assertion; both fail at each use and their
// fail actions count. $assertcontrol(9, 18, 2) selects simple immediate
// assertions and expect statements (2|16) with directive_type cover: it stops
// the fail action of the expect statement but not that of the assert
// directive ai. $assertcontrol(8, 18, 4) runs that of the expect statement
// again.
// Neither simulator runs this test: Icarus Verilog 13.0 and release 5.052 of
// the Verilator tool do not support expect.

`timescale 1ns/1ns

module test_assertcontrol_directive_type_ignored_for_expect_and_violations;
  logic clk = 0, p = 0, q = 0, z = 0;
  int ai_f = 0, ex_f = 0;

  always #5 clk = ~clk;

  task automatic fail_both(string name);
    ai: assert (z) else ai_f++;
    expect (@(posedge clk) z) else ex_f++;
    $display("%s: immediate %0d, expect %0d", name, ai_f, ex_f);
  endtask

  initial begin
    unique case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(4, 32, 4);
    unique case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(3, 32, 2);
    unique case (1'b1) p: ; q: ; endcase
    #1;
    fail_both("all on");
    $assertcontrol(9, 18, 2);
    fail_both("failoff 18 directive 2");
    $assertcontrol(8, 18, 4);
    fail_both("failon 18 directive 4");
    $finish;
  end
endmodule
