/*
:name: test_unique_if_report_flush_on_event_or_wait_resume
:description: a procedure that resumes from an event control or a wait statement discards every violation report of its own unique, unique0 and priority if statements still pending in that time step, while a resumption from a delay control, reports of other procedures and reports made after the resumption are kept (IEEE 1800-2023 Section 12.4.2.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_if_report_flush_on_event_or_wait_resume.expected
:expected_stderr_regex: \A(?![\s\S]*test_unique_if_report_flush_on_event_or_wait_resume\.sv:62\b)(?![\s\S]*test_unique_if_report_flush_on_event_or_wait_resume\.sv:63\b)(?![\s\S]*test_unique_if_report_flush_on_event_or_wait_resume\.sv:64\b)(?![\s\S]*test_unique_if_report_flush_on_event_or_wait_resume\.sv:65\b)(?![\s\S]*test_unique_if_report_flush_on_event_or_wait_resume\.sv:72\b)(?=[\s\S]*test_unique_if_report_flush_on_event_or_wait_resume\.sv:75\b)(?=[\s\S]*test_unique_if_report_flush_on_event_or_wait_resume\.sv:80\b)(?=[\s\S]*test_unique_if_report_flush_on_event_or_wait_resume\.sv:87\b)
*/
// IEEE 1800-2023 §12.4.2.1: a unique, unique0 or priority if checks its
// conditions when it executes, but a violation found then only becomes a
// pending report, kept in a queue that belongs to the process executing the
// statement, until the Observed region of the time step. When a procedure
// that was suspended at an event control or a wait statement resumes, a
// flush point is reached: its queue is cleared and all its pending reports
// are dropped. The list of flush points does not include a delay control,
// and a flush point of one process leaves the queues of others alone.
//
// At t=1 u = v = 1 makes both conditions of a two-branch unique or unique0
// if true (an overlap), and n = m = 0 makes none true, which is a violation
// of unique and priority if without else (§12.4.2). go changes from 0 to 1
// in the NBA region of t=1, after every procedure below has reached its
// event control or wait statement, and before the Observed region.
//   p_ev:    four violations (unique overlap, unique0 overlap, unique and
//            priority no match), then @(go): all four are discarded.
//   p_wait:  one violation, then wait (go): discarded; after resuming, a
//            priority no-match violation: reported.
//   p_delay: one violation, then #0: a delay control, so reported.
//   p_none:  one violation and no suspension in the time step: reported.
// Each statement executes the branch of its first true condition only,
// which the printed values show; the times show that every procedure
// resumed at t=1. The regular expression requires a report naming the line
// of each reported statement and rejects any naming a discarded one. An
// implementation without flush points reports the lines of p_ev and the
// first one of p_wait; one with a single queue shared by all processes, or
// one that also flushes at a delay control, loses the reports of p_none or
// p_delay; one that stops reporting after a flush loses the second line of
// p_wait. The standard leaves the form of a report to the tool; like the
// other violation-report tests of the suite, the test expects the report
// to name the file and line of the if statement.
// Icarus Verilog 13.0 does not support unique and priority if. Release
// 5.054 of the Verilator tool reports a violation when the statement
// executes, so it also reports the discarded ones, gives no report for a
// priority if without a match, and runs no branch of a unique or unique0 if
// whose conditions overlap (r1=0).
`timescale 1ns/1ns

module test_unique_if_report_flush_on_event_or_wait_resume;
  bit u = 1, v = 1, n = 0, m = 0;
  logic go = 0;
  int r1, r2, r3, r4, rw1, rw2, rd, rn;
  int t_ev = -1, t_wt = -1, t_dl = -1;

  initial #1 go <= 1;

  initial begin : p_ev
    #1;
    unique if (u) r1 = 1; else if (v) r1 = 2;
    unique0 if (u) r2 = 1; else if (v) r2 = 2;
    unique if (n) r3 = 1; else if (m) r3 = 2;
    priority if (n) r4 = 1; else if (m) r4 = 2;
    @(go);
    t_ev = $time;
  end

  initial begin : p_wait
    #1;
    unique if (u) rw1 = 1; else if (v) rw1 = 2;
    wait (go);
    t_wt = $time;
    priority if (n) rw2 = 1; else if (m) rw2 = 2;
  end

  initial begin : p_delay
    #1;
    unique if (u) rd = 1; else if (v) rd = 2;
    #0;
    t_dl = $time;
  end

  initial begin : p_none
    #1;
    unique0 if (u) rn = 1; else if (v) rn = 2;
  end

  initial begin
    #3;
    $display("p_ev resumed at %0d: r1=%0d r2=%0d r3=%0d r4=%0d", t_ev, r1, r2, r3, r4);
    $display("p_wait resumed at %0d: rw1=%0d rw2=%0d", t_wt, rw1, rw2);
    $display("p_delay resumed at %0d: rd=%0d", t_dl, rd);
    $display("p_none: rn=%0d", rn);
  end
endmodule
