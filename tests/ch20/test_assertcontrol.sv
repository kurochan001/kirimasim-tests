/*
:name: test_assertcontrol
:description: $assertcontrol turns off concurrent assert directives while assumes go on, turns off the fail action of simple immediate assertions, and locks one assertion against $assertoff, which otherwise stops every assertion until $asserton (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 16.14.1 16.14.2 16.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertcontrol.expected
*/
// IEEE 1800-2023 §20.11: x stays 0, so at each clock tick the concurrent
// assertion ac and the concurrent assumption am fail, and so does the simple
// immediate assertion ai in the always procedure; each fail action counts
// (16.14.1, 16.14.2, 16.3). Every phase has two ticks, after which the counts
// are printed and cleared. Control types are 1 Lock, 2 Unlock, 3 On, 4 Off, 8
// FailOn and 9 FailOff; assertion type 1 is concurrent and 2 simple immediate;
// directive type 1 is assert. $assertcontrol(4, 1, 1) stops concurrent asserts
// but not assumes; $assertcontrol(9, 2) stops the fail action of ai, though ai
// is still checked. After ac is locked, $assertoff, the same as
// $assertcontrol(4, 15, 7), stops am and ai but not ac. $assertcontrol(2, ...)
// unlocks ac and $asserton starts everything again.

`timescale 1ns/1ns

module test_assertcontrol;
  logic clk = 0, x = 0;
  int fails = 0, assume_fails = 0, imm_fails = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  ac: assert property (@(posedge clk) x) else fails++;
  am: assume property (@(posedge clk) x) else assume_fails++;

  always @(posedge clk) begin
    ai: assert (x) else imm_fails++;
  end

  task automatic phase(string name);
    #20 $display("%0d: %s: assert failures %0d, assume failures %0d, immediate failures %0d",
                 $time, name, fails, assume_fails, imm_fails);
    fails = 0;
    assume_fails = 0;
    imm_fails = 0;
  endtask

  initial begin
    phase("all on");
    $assertcontrol(4, 1, 1);
    phase("concurrent asserts off");
    $assertcontrol(3, 1, 1);
    $assertcontrol(9, 2);
    phase("immediate fail action off");
    $assertcontrol(8, 2);
    $assertcontrol(1, 1, 7, 0, ac);
    $assertoff;
    phase("ac locked, others off");
    $assertcontrol(2, 1, 7, 0, ac);
    $asserton;
    phase("all on again");
    $finish;
  end
endmodule
