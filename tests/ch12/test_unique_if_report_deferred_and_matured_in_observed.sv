/*
:name: test_unique_if_report_deferred_and_matured_in_observed
:description: a unique or priority if checks the values it sees when it executes, keeps a violation pending until the Observed region, where assertion control can still flush it, and once the report matures there a later flush point, even in the same time step, no longer removes it and it is reported once (IEEE 1800-2023 Section 12.4.2.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_if_report_deferred_and_matured_in_observed.expected
:expected_stderr_regex: \A(?=[\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:64\b)(?![\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:64\b[\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:64\b)(?![\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:67\b)(?![\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:70\b)(?=[\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:71\b)(?=[\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:74\b)(?![\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:82\b)(?=[\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:89\b)(?=[\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:96\b)(?![\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:96\b[\s\S]*test_unique_if_report_deferred_and_matured_in_observed\.sv:96\b)
*/
// IEEE 1800-2023 §12.4.2.1: a unique, unique0 or priority if checks its
// conditions at the time it executes, but the report of a violation waits,
// pending in the queue of the executing process, until the Observed region
// of the same time step, and the assertion control tasks can control it
// (§20.11: control type 5, Kill, flushes the pending reports of the chosen
// types that have not matured, and 3, On, enables reporting again; type 32
// is unique and 128 priority). In the Observed region each pending report
// matures: it can no longer be flushed, it is reported, and it leaves the
// queue. A procedure resuming from an event control is a flush point.
//
// s_exec, t=1: A fails with pa = qa = 1, and qa is then cleared; B passes
//   with qb = 0, and qb is then set. The checks use the values at
//   execution, so A is reported and B is not.
// s_exec, t=2: C (unique, both true) and D (priority, none true) fail; then
//   Kill for type 32 flushes C, not D, and On re-enables unique reports
//   before E (unique, both true) fails. C is not reported; D and E are.
//   s_exec suspends only at delay controls, so it has no flush point, and A
//   must not be reported again in the Observed region of t=2 or later.
// t=3: F, G and H fail (unique, both true), each in its own procedure, which
//   then waits on an event control. go changes in the NBA region of t=3,
//   before the Observed region, so s_nba resumes and F is discarded. The
//   nested program triggers react from the Reactive region of t=3 (§24.3.1),
//   which comes after the Observed region (§4.5), so s_react resumes in that
//   time step after G matured; s_late resumes at t=4. G and H are reported,
//   H exactly once.
// The printed values show which branch ran; the times show when each
// procedure resumed. The regular expression requires a report naming the
// lines of A, D, E, G and H, exactly one for A and H, and rejects any naming
// B, C or F. An implementation that checks the values of the Observed
// region swaps A and B; one that reports at once also reports C and F; one
// that waits for the end of the time step loses G; one that keeps a matured
// report in the queue repeats A or H. The standard leaves the form of a
// report to the tool; like the other violation-report tests of the suite,
// the test expects the report to name the file and line of the if
// statement.
// Icarus Verilog 13.0 does not support unique and priority if, and release
// 5.054 of the Verilator tool does not support a program declared inside a
// module.
`timescale 1ns/1ns

module test_unique_if_report_deferred_and_matured_in_observed;
  bit pa, qa, pb, qb, n;
  logic go = 0;
  event react, late;
  int r [1:8];
  int t_nba = -1, t_react = -1, t_late = -1;

  initial begin : s_exec
    #1;
    pa = 1; qa = 1;
    unique if (pa) r[1] = 1; else if (qa) r[1] = 2;
    qa = 0;
    pb = 1; qb = 0;
    unique if (pb) r[2] = 1; else if (qb) r[2] = 2;
    qb = 1;
    #1;
    unique if (pa) r[3] = 1; else if (pb) r[3] = 2;
    priority if (qa) r[4] = 1; else if (n) r[4] = 2;
    $assertcontrol(5, 32);
    $assertcontrol(3, 32);
    unique if (pa) r[5] = 1; else if (pb) r[5] = 2;
  end

  initial #3 go <= 1;
  initial #4 -> late;

  initial begin : s_nba
    #3;
    unique if (pa) r[6] = 1; else if (qb) r[6] = 2;
    @(go);
    t_nba = $time;
  end

  initial begin : s_react
    #3;
    unique if (pa) r[7] = 1; else if (pb) r[7] = 2;
    @(react);
    t_react = $time;
  end

  initial begin : s_late
    #3;
    unique if (pb) r[8] = 1; else if (qb) r[8] = 2;
    @(late);
    t_late = $time;
    #2;
  end

  program prg;
    initial begin
      #3 -> react;
      #4;
    end
  endprogram

  initial begin
    #6;
    $display("t=1: r1=%0d r2=%0d", r[1], r[2]);
    $display("t=2: r3=%0d r4=%0d r5=%0d", r[3], r[4], r[5]);
    $display("t=3: r6=%0d r7=%0d r8=%0d", r[6], r[7], r[8]);
    $display("resumed: s_nba at %0d, s_react at %0d, s_late at %0d", t_nba, t_react, t_late);
  end
endmodule
