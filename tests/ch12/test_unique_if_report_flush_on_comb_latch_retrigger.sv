/*
:name: test_unique_if_report_flush_on_comb_latch_retrigger
:description: an always_comb or always_latch procedure that a change of one of its inputs starts again discards the pending violation reports of its unique, unique0 and priority if statements, so a zero-delay glitch through an NBA or a #0 update gives no report, while a violation that stays or that the new run finds again is reported (IEEE 1800-2023 Section 12.4.2.1)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_if_report_flush_on_comb_latch_retrigger.expected
:expected_stderr_regex: \A(?![\s\S]*test_unique_if_report_flush_on_comb_latch_retrigger\.sv:60\b)(?![\s\S]*test_unique_if_report_flush_on_comb_latch_retrigger\.sv:64\b)(?![\s\S]*test_unique_if_report_flush_on_comb_latch_retrigger\.sv:69\b)(?![\s\S]*test_unique_if_report_flush_on_comb_latch_retrigger\.sv:74\b)(?=[\s\S]*test_unique_if_report_flush_on_comb_latch_retrigger\.sv:78\b)(?=[\s\S]*test_unique_if_report_flush_on_comb_latch_retrigger\.sv:82\b)
*/
// IEEE 1800-2023 §12.4.2.1: the violation checks of unique, unique0 and
// priority if shall not give false reports for zero-delay glitches in the
// active region set, which holds the Active, Inactive and NBA regions
// (§4.4.1). A violation becomes a pending report of the executing process,
// reported in the Observed region; an always_comb or always_latch procedure
// that runs again because one of the signals it depends on changed reaches
// a flush point, which discards the pending reports of that procedure.
//
// na follows !a through a nonblocking assignment and nb follows !b one #0
// later, so after a changes at t=1, na keeps its old value until the NBA
// region, and after b changes at t=2, nb keeps it until the Inactive region.
// In that window the procedures run with a = na = 1 (or b = nb = 1):
//   c_nba (unique if, both true), c_prio (priority if, none true) and
//   l_nba (always_latch, unique0 if, both true) fail and run again when na
//   changes, now without a violation: no report.
//   c_inact (unique if) fails at t=2 and runs again when nb changes: no
//   report.
//   c_stay (unique if on a and k = 1) fails at t=1 and reads neither na nor
//   nb, so nothing starts it again: reported.
//   c_again (unique if on a and na || k) fails, runs again when na changes
//   and fails again; the second report is not flushed: reported.
// At time 0 every condition pair has exactly one true condition. The values
// printed at t=3 show the branch each procedure took in its last run. The
// regular expression requires a report naming the lines of c_stay and
// c_again and rejects any naming the other four. An implementation that
// reports at once, or does not flush when an always_comb or always_latch
// runs again, reports the glitches; one that flushes the reports of all
// processes loses c_stay; one that stops reporting after a flush loses
// c_again. The standard leaves the form of a report to the tool; like the
// other violation-report tests of the suite, the test expects the report
// to name the file and line of the if statement.
// Icarus Verilog 13.0 does not support unique and priority if. Release
// 5.054 of the Verilator tool reports a violation when the statement
// executes, so it reports the glitches of c_nba, l_nba and c_inact, and it
// prints z4=2 z5=2 z6=2.
`timescale 1ns/1ns

module test_unique_if_report_flush_on_comb_latch_retrigger;
  logic a = 0, na = 1;
  logic b = 0, nb = 1;
  logic en = 1, k = 1;
  int z1, z2, z3, z4, z5, z6;

  always @(a) na <= !a;

  always_comb begin : c_nba
    unique if (a) z1 = 1; else if (na) z1 = 2;
  end

  always_comb begin : c_prio
    priority if (a && !na) z2 = 1; else if (!a && na) z2 = 2;
  end

  always_latch begin : l_nba
    if (en) begin
      unique0 if (a) z3 = 1; else if (na) z3 = 2;
    end
  end

  always_comb begin : c_inact
    unique if (b) z4 = 1; else if (nb) z4 = 2;
  end

  always_comb begin : c_stay
    unique if (a) z5 = 1; else if (k) z5 = 2;
  end

  always_comb begin : c_again
    unique if (a) z6 = 1; else if (na || k) z6 = 2;
  end

  initial begin
    #1 a = 1;
    #1 b = 1;
    #0 nb = 0;
    #1 $display("z1=%0d z2=%0d z3=%0d z4=%0d z5=%0d z6=%0d", z1, z2, z3, z4, z5, z6);
  end
endmodule
