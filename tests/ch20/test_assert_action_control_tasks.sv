/*
:name: test_assert_action_control_tasks
:description: $assertpassoff, $assertfailoff, $assertvacuousoff and $assertnonvacuouson stop or allow the pass and fail actions of assertions, vacuous passes separately, until the matching on task; $assertoff lets running attempts finish while $assertkill aborts them, and both stop new attempts until $asserton (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 16.14.1 16.14.8 16.12.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assert_action_control_tasks.expected
*/
// IEEE 1800-2023 §20.11: $assertpassoff stops the pass action for vacuous and
// nonvacuous success until $assertpasson; $assertnonvacuouson then allows it
// again for nonvacuous success only. $assertvacuousoff stops it for vacuous
// success until $assertpasson. $assertfailoff stops the fail action until
// $assertfailon. $assertoff stops new attempts but lets running ones finish;
// $assertkill also aborts the running ones; $asserton restarts checking.
// a_now checks start |-> b (§16.12.7) at each tick: a tick with start and b is
// a nonvacuous pass, one without start a vacuous pass (§16.14.8), and one with
// start but no b a failure; its pass and fail actions (§16.14.1) count. Each
// of its phases has one tick of each kind. a_later checks go |=> ##1 done,
// which fails two ticks after go since done never comes; the control task is
// called between go and the failure.

`timescale 1ns/1ns

module test_assert_action_control_tasks;
  logic clk = 0, start = 0, b = 0, go = 0, done = 0;
  int passes = 0, fails = 0, later_fails = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_now: assert property (@(posedge clk) start |-> b) passes++; else fails++;
  a_later: assert property (@(posedge clk) go |=> ##1 done) else later_fails++;

  // One tick each with a nonvacuous pass, a vacuous pass and a failure.
  task automatic phase(string name);
    start = 1; b = 1; #10;
    start = 0; b = 0; #10;
    start = 1; b = 0; #10;
    start = 0;
    $display("%s: passes %0d, failures %0d", name, passes, fails);
    passes = 0;
    fails = 0;
  endtask

  // go at one tick; the control runs 7 later, before the failure 20 after go.
  task automatic later_phase(string name, int control);
    go = 1; #10;
    go = 0; #2;
    case (control)
      1: $assertoff;
      2: $assertkill;
      default: ;
    endcase
    #28;
    $display("%s: a_later failures %0d", name, later_fails);
    later_fails = 0;
    $asserton;
  endtask

  initial begin
    phase("default");
    $assertpassoff;
    phase("$assertpassoff");
    $assertpasson;
    $assertfailoff;
    phase("$assertpasson, $assertfailoff");
    $assertfailon;
    $assertvacuousoff;
    phase("$assertfailon, $assertvacuousoff");
    $assertpasson;
    $assertpassoff;
    $assertnonvacuouson;
    phase("$assertpassoff, $assertnonvacuouson");
    $assertpasson;
    phase("$assertpasson");
    later_phase("no control", 0);
    later_phase("$assertoff after go", 1);
    later_phase("$assertkill after go", 2);
    $finish;
  end
endmodule
