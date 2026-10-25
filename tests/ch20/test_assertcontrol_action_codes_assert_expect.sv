/*
:name: test_assertcontrol_action_codes_assert_expect
:description: $assertcontrol with control_type 7 (PassOff), 6 (PassOn), 9 (FailOff), 8 (FailOn), 11 (VacuousOff), 10 (NonvacuousOn), 4 (Off), 5 (Kill) and 3 (On) acts on the pass and fail actions of an assertion and of an expect statement, while Off and Kill leave the expect statement alone (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 16.17 16.14.8 16.12.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertcontrol_action_codes_assert_expect.expected
*/
// IEEE 1800-2023 §20.11, Table 20-5: control_type 3 is On, 4 Off, 5 Kill, 6
// PassOn, 7 PassOff, 8 FailOn, 9 FailOff, 10 NonvacuousOn and 11 VacuousOff.
// Without an assertion_type all assertions and expect statements are
// selected. PassOff stops the pass action for vacuous and nonvacuous
// successes; PassOn enables both again; NonvacuousOn enables it for
// nonvacuous successes only; VacuousOff stops it for vacuous successes until
// PassOn; FailOff and FailOn stop and allow the fail action. Off stops new
// attempts of assertions, Kill also aborts running ones, and On restarts
// them; these three do not affect expect statements.
// a_now asserts start |-> b (§16.12.7) at every tick, and a process runs an
// expect statement (§16.17) of the same property again and again, so it
// also evaluates once per tick. Each phase has one tick with start and b
// (nonvacuous pass), one without start (vacuous pass, §16.14.8) and one with
// start but not b (failure), and prints the passes and failures counted by
// the actions of the assertion and of the expect statement. a_later checks
// go |=> ##1 done, which fails two ticks after go; a control is called
// between go and that failure.
// Neither simulator runs this test: Icarus Verilog 13.0 does not support
// concurrent assertions and release 5.052 of the Verilator tool does not
// support expect.

`timescale 1ns/1ns

module test_assertcontrol_action_codes_assert_expect;
  logic clk = 0, start = 0, b = 0, go = 0, done = 0;
  int ap, af, ep, ef, later_fails;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_now: assert property (@(posedge clk) start |-> b) ap++; else af++;
  a_later: assert property (@(posedge clk) go |=> ##1 done) else later_fails++;

  initial forever begin
    expect (@(posedge clk) start |-> b) ep++; else ef++;
  end

  task automatic phase(string name);
    ap = 0;
    af = 0;
    ep = 0;
    ef = 0;
    start = 1; b = 1; #10;
    start = 0; b = 0; #10;
    start = 1; b = 0; #10;
    start = 0;
    $display("%s: assert %0d/%0d expect %0d/%0d", name, ap, af, ep, ef);
  endtask

  task automatic later_phase(string name, int code);
    later_fails = 0;
    go = 1; #10;
    go = 0; #2;
    if (code == 4) $assertcontrol(4);
    if (code == 5) $assertcontrol(5);
    #28;
    $display("%s: a_later failures %0d", name, later_fails);
    $assertcontrol(3);
  endtask

  initial begin
    phase("default");
    $assertcontrol(7);
    phase("7");
    $assertcontrol(6);
    $assertcontrol(9);
    phase("6 9");
    $assertcontrol(8);
    $assertcontrol(11);
    phase("8 11");
    $assertcontrol(6);
    $assertcontrol(7);
    $assertcontrol(10);
    phase("6 7 10");
    $assertcontrol(6);
    phase("6");
    $assertcontrol(4);
    phase("4");
    $assertcontrol(3);
    phase("3");
    $assertcontrol(5);
    phase("5");
    $assertcontrol(3);
    phase("3 again");
    later_phase("no control", 0);
    later_phase("4 after go", 4);
    later_phase("5 after go", 5);
    $finish;
  end
endmodule
