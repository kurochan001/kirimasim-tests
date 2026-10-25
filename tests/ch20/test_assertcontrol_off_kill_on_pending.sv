/*
:name: test_assertcontrol_off_kill_on_pending
:description: Off lets a running assertion attempt and queued deferred reports mature but starts no new attempt, Kill aborts the attempt and flushes the queued reports, On starts checking and violation reporting again, and none of the three changes an expect statement (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 16.4 16.14.1 12.5.3 16.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertcontrol_off_kill_on_pending.expected
:expected_stderr_regex: \A(?=[\s\S]*test_assertcontrol_off_kill_on_pending\.sv:120:)(?=[\s\S]*test_assertcontrol_off_kill_on_pending\.sv:124:)(?=[\s\S]*test_assertcontrol_off_kill_on_pending\.sv:130:)(?=[\s\S]*test_assertcontrol_off_kill_on_pending\.sv:142:)(?![\s\S]*test_assertcontrol_off_kill_on_pending\.sv:122:)(?![\s\S]*test_assertcontrol_off_kill_on_pending\.sv:126:)(?![\s\S]*test_assertcontrol_off_kill_on_pending\.sv:128:)(?![\s\S]*test_assertcontrol_off_kill_on_pending\.sv:135:)
*/
// IEEE 1800-2023 §20.11, Table 20-5: 3 is On, 4 Off and 5 Kill. Off stops
// checking and starts no new attempts, but attempts already executing run on
// and their pass or fail actions still run; currently queued deferred reports
// are not flushed and may mature. Kill aborts attempts already executing and
// flushes queued deferred reports that have not matured. Both stop checking
// until On, which also re-enables violation reporting. None of the three
// affects expect statements. §16.4: the action block of assert #0 runs in the
// Reactive region and that of assert final in the Postponed region of the
// same time step, so a control called after the assertion statement but in the
// Active region decides whether that action runs. §12.5.3: a unique case whose
// items do not match issues a violation report. §16.17: an expect statement
// fails at the clock event when its property fails.
// The clock ticks at 5, 15, 25, ...; go is 1 from time 0 and done is 0, so
// a_long needs done one tick after each start and fails there. Off at 7 lets
// the attempt started at 5 fail at 15 and keeps the tick at 15 from starting
// another; Kill at 27 discards the attempt started at 25, and the tick at 35
// fails nothing. On at 37 lets the attempt started at 45 fail at 55. Then a
// queued observed and a queued final deferred assertion show that Off lets
// their actions run and Kill flushes them, and that neither starts a new one
// until On. Off and On turn the violation reports of unique case statements
// off and on, Kill suppresses them until On, and each of the three leaves an
// expect statement alone. The no-mask Off and On at 70 and 86 show that 255
// selects the violation report types, and assertion_type 16 turns the pass
// action of an expect off and on. The concurrent assertion has a fail action,
// so a failure prints nothing by itself (16.14.1).
// Icarus Verilog 13.0 has no concurrent assertions. The Verilator tool of
// release 5.052 aborts a running attempt on Off, does not flush queued
// deferred reports on Kill, does not support expect, and rejects
// assertion_type 32, so no simulator here produces this output.

`timescale 1ns/1ns

module test_assertcontrol_off_kill_on_pending;
  logic clk = 0, go = 0, done = 0;
  logic p = 0, q = 0, z = 0;
  int long_fails = 0, obs_fails = 0, expect_fails = 0, expect_passes = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_long: assert property (@(posedge clk) go |=> done) else long_fails++;

  task automatic obs_fail();
    obs_fails++;
  endtask

  task automatic final_fail();
    $display("final deferred failure");
  endtask

  task automatic expect_fail();
    expect_fails++;
  endtask

  task automatic expect_pass();
    expect_passes++;
  endtask

  initial begin
    // Off leaves the attempt in flight alone and starts no new attempt.
    go = 1;
    #7 $assertcontrol(4, 1);              // 7: Off concurrent assertions
    #9;                                   // 16
    $display("16: off during attempt: total fails %0d", long_fails);
    #1 $assertcontrol(3, 1);              // 17: On concurrent assertions
    #8;                                   // 25: a new attempt starts
    // Kill discards that attempt and starts no new one.
    #2 $assertcontrol(5, 1);              // 27: Kill concurrent assertions
    #9;                                   // 36
    $display("36: kill during attempt: total fails %0d", long_fails);
    #1 $assertcontrol(3, 1);              // 37: On concurrent assertions
    #8;                                   // 45: a new attempt starts
    #11;                                  // 56: it fails at 55
    $display("56: on: total fails %0d", long_fails);

    // Off does not flush reports queued in the same step; no further report
    // is queued while it is off. On enables the queue again.
    ob1: assert #0 (1'b0) else obs_fail();
    fi1: assert final (1'b0) else final_fail();
    $assertcontrol(4, 12);                // 56: Off observed and final deferred
    #1;                                   // 57
    $display("57: off after queue: observed %0d", obs_fails);
    ob2: assert #0 (1'b0) else obs_fail();
    fi2: assert final (1'b0) else final_fail();
    #1;                                   // 58
    $display("58: off before queue: observed %0d", obs_fails);
    $assertcontrol(3, 12);                // 58: On deferred assertions
    ob3: assert #0 (1'b0) else obs_fail();
    fi3: assert final (1'b0) else final_fail();
    #1;                                   // 59
    $display("59: on: observed %0d", obs_fails);

    // Kill flushes reports queued in the same step and stops new ones.
    ob4: assert #0 (1'b0) else obs_fail();
    fi4: assert final (1'b0) else final_fail();
    $assertcontrol(5, 12);                // 59: Kill observed and final deferred
    #1;                                   // 60
    $display("60: kill after queue: observed %0d", obs_fails);
    ob5: assert #0 (1'b0) else obs_fail();
    fi5: assert final (1'b0) else final_fail();
    #1;                                   // 61
    $display("61: kill before queue: observed %0d", obs_fails);
    $assertcontrol(3, 12);                // 61: On deferred assertions

    // Off, On and Kill on the violation reports of unique case statements.
    #1 $assertcontrol(3, 32);             // 62: On violation reports
    #1;                                   // 63
    unique case (1'b1) p: ; q: ; endcase
    #1 $assertcontrol(4, 32);             // 64: Off unique violation reports
    unique case (1'b1) p: ; q: ; endcase
    #1 $assertcontrol(3, 32);             // 65: On unique violation reports
    unique case (1'b1) p: ; q: ; endcase
    #1 $assertcontrol(5, 32);             // 66: Kill unique violation reports
    unique case (1'b1) p: ; q: ; endcase
    #1;                                   // 67
    unique case (1'b1) p: ; q: ; endcase
    #1 $assertcontrol(3, 32);             // 68: On unique violation reports
    unique case (1'b1) p: ; q: ; endcase

    // Off and Kill leave an expect statement alone; On does not change one
    // that is waiting for its clock event.
    #2 $assertcontrol(4);                 // 70: Off all assertions
    unique case (1'b1) p: ; q: ; endcase
    expect (@(posedge clk) z) else expect_fail();
    $display("75: off: expect fail actions %0d", expect_fails);
    #1 $assertcontrol(5);                 // 76: Kill all assertions
    expect (@(posedge clk) z) else expect_fail();
    $display("85: kill: expect fail actions %0d", expect_fails);
    #1 $assertcontrol(3);                 // 86: On all assertions
    unique case (1'b1) p: ; q: ; endcase
    fork
      expect (@(posedge clk) z) else expect_fail();
      #4 $assertcontrol(3);               // 90: On while the expect waits
    join
    $display("95: on during expect: expect fail actions %0d", expect_fails);
    // assertion_type 16 selects expect statements for the action controls.
    #1 $assertcontrol(7, 16);             // 96: PassOff expect statements
    expect (@(posedge clk) 1'b1) expect_pass();
    $display("105: passoff expect: pass actions %0d", expect_passes);
    $assertcontrol(6, 16);                // 106: PassOn expect statements
    expect (@(posedge clk) 1'b1) expect_pass();
    $display("115: passon expect: pass actions %0d", expect_passes);
    $finish;
  end
endmodule
