/*
:name: test_assertcontrol_lock_expect_and_violation_reports
:description: $assertcontrol Lock (1) of expect statements (assertion_type 16) and of unique violation reports (32) keeps later FailOff, Off and On controls from changing them until Unlock (2) (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 12.5.3 12.4.2.1 16.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertcontrol_lock_expect_and_violation_reports.expected
:expected_stderr_regex: \A(?=[\s\S]*test_assertcontrol_lock_expect_and_violation_reports\.sv:49:)(?=[\s\S]*test_assertcontrol_lock_expect_and_violation_reports\.sv:53:)(?![\s\S]*test_assertcontrol_lock_expect_and_violation_reports\.sv:57:)(?![\s\S]*test_assertcontrol_lock_expect_and_violation_reports\.sv:61:)(?=[\s\S]*test_assertcontrol_lock_expect_and_violation_reports\.sv:65:)
*/
// IEEE 1800-2023 §20.11: control_type 1 (Lock) keeps every later
// $assertcontrol from changing the status of the selected assertions,
// expect statements and violation reports until control_type 2 (Unlock).
// assertion_type 16 selects expect statements and 32 the violation reports of
// unique case and if statements (Table 20-6). 4 (Off) turns violation
// reports off and 3 (On) on again; 9 (FailOff) stops the fail actions of
// expect statements and 8 (FailOn) runs them again.
// §12.5.3, §12.4.2.1: a unique case statement in which no item matches
// gives a violation report in the Observed region of the time step. Each
// such statement below is on its own line and in its own time step, and the
// regular expression requires a report from the lines where the reports are
// on and none from the lines where they are off: Off under the lock does not
// stop the report of line 53, Off after the unlock stops that of line 57,
// On under a new lock does not restart the report of line 61, and On after
// the unlock restarts that of line 65.
// The expect statement (§16.17) fails at each use, and its fail action
// counts; FailOff under the lock does not stop it, FailOff after the unlock
// does, and FailOn runs it again.
// Neither simulator runs this test: Icarus Verilog 13.0 and release 5.052 of
// the Verilator tool do not support expect.

`timescale 1ns/1ns

module test_assertcontrol_lock_expect_and_violation_reports;
  logic clk = 0, p = 0, q = 0, z = 0;
  int ex_f = 0;

  always #5 clk = ~clk;

  task automatic try_expect(string name);
    expect (@(posedge clk) z) else ex_f++;
    $display("%s: expect fail actions %0d", name, ex_f);
  endtask

  initial begin
    unique case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(1, 32);
    $assertcontrol(4, 32);
    unique case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(2, 32);
    $assertcontrol(4, 32);
    unique case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(1, 32);
    $assertcontrol(3, 32);
    unique case (1'b1) p: ; q: ; endcase
    #1;
    $assertcontrol(2, 32);
    $assertcontrol(3, 32);
    unique case (1'b1) p: ; q: ; endcase
    #1;
    try_expect("on");
    $assertcontrol(1, 16);
    $assertcontrol(9, 16);
    try_expect("locked, failoff");
    $assertcontrol(2, 16);
    $assertcontrol(9, 16);
    try_expect("unlocked, failoff");
    $assertcontrol(8, 16);
    try_expect("failon");
    $finish;
  end
endmodule
