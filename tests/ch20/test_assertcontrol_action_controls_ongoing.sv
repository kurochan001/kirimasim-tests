/*
:name: test_assertcontrol_action_controls_ongoing
:description: control types 6 through 11 leave the pass and fail actions of attempts already executing as they were and take effect on later attempts only, they do not change the violation reports of unique case statements, the assertion_type mask ORs its bits and defaults to 255, and each action task equals its $assertcontrol form (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 16.14.1 16.14.8 12.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertcontrol_action_controls_ongoing.expected
:expected_stderr_regex: \A(?=[\s\S]*test_assertcontrol_action_controls_ongoing\.sv:90:)(?=[\s\S]*test_assertcontrol_action_controls_ongoing\.sv:100:)(?=[\s\S]*test_assertcontrol_action_controls_ongoing\.sv:110:)(?=[\s\S]*test_assertcontrol_action_controls_ongoing\.sv:120:)(?=[\s\S]*test_assertcontrol_action_controls_ongoing\.sv:133:)(?=[\s\S]*test_assertcontrol_action_controls_ongoing\.sv:148:)
*/
// IEEE 1800-2023 §20.11, Table 20-5: 6 PassOn, 7 PassOff, 8 FailOn, 9
// FailOff, 10 NonvacuousOn and 11 VacuousOff. Each leaves an assertion that is
// already executing, including its pass or fail action, unaffected, so the
// state when the attempt starts decides its action; the control applies to
// attempts that start afterwards. None changes the violation report types.
// Table 20-6: assertion_type values are OR-ed and default to 255. Table 20-7:
// directive_type defaults to 7. The action tasks are the same as
// $assertcontrol(6 to 11, 31, 7, levels, list).
// The clock ticks at 5, 15, 25, ... and every tick starts one attempt of
// a_pass, which passes one tick later, one of a_fail, which fails one tick
// later, and one of a_vac, whose antecedent 1 ##1 0 never matches and which
// therefore succeeds vacuously one tick later (§16.14.8). A control comes one
// time unit after the tick that started the attempt in flight, so the action
// at the next tick shows the state at the start. a_now has three ticks in each
// phase: start and cond (nonvacuous pass, §16.12.7), neither (vacuous pass)
// and start without cond (failure).
// Icarus Verilog 13.0 has no concurrent assertions. The Verilator tool of
// release 5.052 applies the action controls to the attempt already executing
// instead of only to later attempts, and ignores control types 10 and 11, so
// no simulator here produces this output.

`timescale 1ns/1ns

module test_assertcontrol_action_controls_ongoing;
  logic clk = 0, start = 0, cond = 0, p = 0, q = 0;
  int pass_cnt = 0, fail_cnt = 0, vac_pass = 0, vac_fail = 0;
  int passes = 0, fails = 0, imm = 0, obs = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_pass: assert property (@(posedge clk) 1'b1 |=> 1'b1) pass_cnt++;
  a_fail: assert property (@(posedge clk) 1'b1 |=> 1'b0) else fail_cnt++;
  a_vac: assert property (@(posedge clk) 1'b1 ##1 1'b0 |-> 1'b1) vac_pass++; else vac_fail++;
  a_now: assert property (@(posedge clk) start |-> cond) passes++; else fails++;

  task automatic next_tick();
    @(posedge clk);
    #1;
  endtask

  task automatic now_phase();
    start = 1; cond = 1;
    next_tick();
    start = 0; cond = 0;
    next_tick();
    start = 1; cond = 0;
    next_tick();
    start = 0;
  endtask

  task automatic imm_fail();
    imm++;
  endtask

  task automatic obs_fail();
    obs++;
  endtask

  task automatic restore();
    $assertcontrol(3);
    $assertcontrol(6);
    $assertcontrol(8);
  endtask

  task automatic report(string name, int p, int f);
    $display("%s: passes %0d, failures %0d", name, p, f);
  endtask

  initial begin
    // 7 PassOff: the attempt started at 5 runs its pass action; the one
    // started at 15 does not.
    next_tick();                          // 6
    pass_cnt = 0;
    $assertcontrol(7);
    next_tick();                          // 16
    report("7 in flight", pass_cnt, 0);
    unique case (1'b1) p: ; q: ; endcase
    next_tick();                          // 26
    report("7 new", pass_cnt, 0);

    // 6 PassOn: the attempt started at 25 started with the pass action off,
    // so its pass action still does not run; the next one runs.
    pass_cnt = 0;
    $assertcontrol(6);
    next_tick();                          // 36
    report("6 in flight", pass_cnt, 0);
    unique case (1'b1) p: ; q: ; endcase
    next_tick();                          // 46
    report("6 new", pass_cnt, 0);

    // 9 FailOff: the attempt started at 45 runs its fail action; the one
    // started at 55 does not.
    fail_cnt = 0;
    $assertcontrol(9);
    next_tick();                          // 56
    report("9 in flight", 0, fail_cnt);
    unique case (1'b1) p: ; q: ; endcase
    next_tick();                          // 66
    report("9 new", 0, fail_cnt);

    // 8 FailOn: the attempt started at 65 started with the fail action off,
    // so its fail action still does not run; the next one runs.
    fail_cnt = 0;
    $assertcontrol(8);
    next_tick();                          // 76
    report("8 in flight", 0, fail_cnt);
    unique case (1'b1) p: ; q: ; endcase
    next_tick();                          // 86
    report("8 new", 0, fail_cnt);

    // 10 NonvacuousOn: the attempt started at 95 started with the pass action
    // off, so its nonvacuous pass action does not run; the next one does, and
    // the vacuous pass action stays off.
    $assertcontrol(7);
    next_tick();                          // 96
    pass_cnt = 0;
    $assertcontrol(10);
    next_tick();                          // 106
    report("10 in flight", pass_cnt, 0);
    unique case (1'b1) p: ; q: ; endcase
    next_tick();                          // 116
    report("10 new", pass_cnt, 0);
    vac_pass = 0;
    next_tick();                          // 126
    report("10 vacuous stays off", vac_pass, 0);

    // 11 VacuousOff: the attempt started at 135 runs its vacuous pass action;
    // the one started at 145 does not, and a nonvacuous pass still runs.
    $assertcontrol(6);
    next_tick();                          // 136
    vac_pass = 0;
    $assertcontrol(11);
    next_tick();                          // 146
    report("11 in flight", vac_pass, 0);
    unique case (1'b1) p: ; q: ; endcase
    next_tick();                          // 156
    report("11 new", vac_pass, 0);
    pass_cnt = 0;
    next_tick();                          // 166
    report("11 nonvacuous stays on", pass_cnt, 0);

    // assertion_type 3 is concurrent|simple immediate, 1 is concurrent, and
    // without the argument all types are selected; a deferred assertion of
    // type 4 is not selected by 3 or 1.
    restore();
    $assertcontrol(8);
    fails = 0; imm = 0; obs = 0;
    $assertcontrol(9, 3);
    start = 1; cond = 0;
    next_tick();                          // 176
    start = 0;
    ia1: assert (1'b0) else imm_fail();
    da1: assert #0 (1'b0) else obs_fail();
    #1;                                   // 177
    $display("mask 3: concurrent %0d, simple %0d, observed %0d", fails, imm, obs);
    $assertcontrol(8);
    fails = 0; imm = 0; obs = 0;
    $assertcontrol(9, 1);
    start = 1; cond = 0;
    next_tick();                          // 186
    start = 0;
    ia2: assert (1'b0) else imm_fail();
    da2: assert #0 (1'b0) else obs_fail();
    #1;                                   // 187
    $display("mask 1: concurrent %0d, simple %0d, observed %0d", fails, imm, obs);
    $assertcontrol(8);
    fails = 0; imm = 0; obs = 0;
    $assertcontrol(9);
    start = 1; cond = 0;
    next_tick();                          // 196
    start = 0;
    ia3: assert (1'b0) else imm_fail();
    da3: assert #0 (1'b0) else obs_fail();
    #1;                                   // 197
    $display("no mask: concurrent %0d, simple %0d, observed %0d", fails, imm, obs);
    $assertcontrol(8);

    // Each action task with a levels argument and a list is the same as the
    // $assertcontrol form of 20.11 with the same arguments.
    restore();
    $assertpassoff(0, a_now); passes = 0; fails = 0;
    now_phase();
    report("passoff shorthand", passes, fails);
    restore();
    $assertcontrol(7, 31, 7, 0, a_now); passes = 0; fails = 0;
    now_phase();
    report("passoff control", passes, fails);

    restore();
    $assertpassoff(0, a_now);
    $assertpasson(0, a_now); passes = 0; fails = 0;
    now_phase();
    report("passon shorthand", passes, fails);
    restore();
    $assertpassoff(0, a_now);
    $assertcontrol(6, 31, 7, 0, a_now); passes = 0; fails = 0;
    now_phase();
    report("passon control", passes, fails);

    restore();
    $assertfailoff(0, a_now); passes = 0; fails = 0;
    now_phase();
    report("failoff shorthand", passes, fails);
    restore();
    $assertcontrol(9, 31, 7, 0, a_now); passes = 0; fails = 0;
    now_phase();
    report("failoff control", passes, fails);

    restore();
    $assertfailoff(0, a_now);
    $assertfailon(0, a_now); passes = 0; fails = 0;
    now_phase();
    report("failon shorthand", passes, fails);
    restore();
    $assertfailoff(0, a_now);
    $assertcontrol(8, 31, 7, 0, a_now); passes = 0; fails = 0;
    now_phase();
    report("failon control", passes, fails);

    restore();
    $assertpassoff(0, a_now);
    $assertnonvacuouson(0, a_now); passes = 0; fails = 0;
    now_phase();
    report("nonvacuouson shorthand", passes, fails);
    restore();
    $assertpassoff(0, a_now);
    $assertcontrol(10, 31, 7, 0, a_now); passes = 0; fails = 0;
    now_phase();
    report("nonvacuouson control", passes, fails);

    restore();
    $assertvacuousoff(0, a_now); passes = 0; fails = 0;
    now_phase();
    report("vacuousoff shorthand", passes, fails);
    restore();
    $assertcontrol(11, 31, 7, 0, a_now); passes = 0; fails = 0;
    now_phase();
    report("vacuousoff control", passes, fails);

    restore();
    $assertoff(0, a_now); passes = 0; fails = 0;
    now_phase();
    report("off shorthand", passes, fails);
    restore();
    $assertcontrol(4, 15, 7, 0, a_now); passes = 0; fails = 0;
    now_phase();
    report("off control", passes, fails);

    restore();
    $assertoff(0, a_now);
    $asserton(0, a_now); passes = 0; fails = 0;
    now_phase();
    report("on shorthand", passes, fails);
    restore();
    $assertoff(0, a_now);
    $assertcontrol(3, 15, 7, 0, a_now); passes = 0; fails = 0;
    now_phase();
    report("on control", passes, fails);

    restore();
    next_tick();
    pass_cnt = 0;
    $assertkill(0, a_pass);
    next_tick();
    report("kill shorthand", pass_cnt, 0);
    restore();
    next_tick();
    pass_cnt = 0;
    $assertcontrol(5, 15, 7, 0, a_pass);
    next_tick();
    report("kill control", pass_cnt, 0);

    restore();
    $finish;
  end
endmodule
