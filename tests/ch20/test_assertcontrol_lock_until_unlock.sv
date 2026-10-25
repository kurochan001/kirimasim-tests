/*
:name: test_assertcontrol_lock_until_unlock
:description: assertions locked with $assertcontrol control_type 1 ignore later Off, On, FailOff and FailOn controls until control_type 2 unlocks them, and unlocking one of two locked assertion types frees only that type (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 16.14.1 16.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertcontrol_lock_until_unlock.expected
*/
// IEEE 1800-2023 §20.11, Table 20-5: control_type 1 (Lock) keeps every
// later $assertcontrol from changing the status of the selected assertions
// until control_type 2 (Unlock) removes the lock from the selected ones.
// Table 20-6: assertion_type 1 selects concurrent and 2 simple immediate
// assertions. $assertoff and $asserton are $assertcontrol(4, 15, 7) and
// $assertcontrol(3, 15, 7); 4 (Off) stops checking, 3 (On) starts it again,
// 9 (FailOff) stops the fail actions and 8 (FailOn) runs them again.
// x stays 0, so at every clock tick the concurrent assertion ac (16.14.1)
// and the simple immediate assertion ai (16.3) fail, and each fail action
// counts. Every phase has two ticks; then the counts are printed and
// cleared. An assertion that is checked with its fail action on counts 2,
// one that is off or whose fail action is off counts 0.
// Phase 2: the concurrent assertions are locked, so $assertoff stops ai only.
// Phase 3: $asserton starts ai again, and FailOff of all assertions leaves
// the locked ac alone.
// Phase 4: after FailOn the immediate assertions are locked as well, then
// only the concurrent ones are unlocked, and Off of all assertions now stops
// ac but not ai.
// Phase 5: the immediate assertions are unlocked, On restarts ac, and FailOff
// of the immediate assertions now takes effect on ai.
// The tool of release 5.052 that runs this test ignores a list of assertions
// given to a Lock (a lock of one concurrent assertion locks all of them), so
// the test selects by assertion type.

`timescale 1ns/1ns

module test_assertcontrol_lock_until_unlock;
  logic clk = 0, x = 0;
  int ac_f = 0, ai_f = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  ac: assert property (@(posedge clk) x) else ac_f++;

  always @(posedge clk) begin
    ai: assert (x) else ai_f++;
  end

  task automatic phase(string name);
    #20 $display("%0d: %s: ac %0d, ai %0d", $time, name, ac_f, ai_f);
    ac_f = 0;
    ai_f = 0;
  endtask

  initial begin
    phase("all on");
    $assertcontrol(1, 1);
    $assertoff;
    phase("concurrent locked, assertoff");
    $asserton;
    $assertcontrol(9);
    phase("concurrent locked, asserton, failoff");
    $assertcontrol(8);
    $assertcontrol(1, 2);
    $assertcontrol(2, 1);
    $assertcontrol(4);
    phase("concurrent unlocked, immediate locked, off");
    $assertcontrol(2, 2);
    $assertcontrol(3);
    $assertcontrol(9, 2);
    phase("immediate unlocked, on, failoff immediate");
    $finish;
  end
endmodule
