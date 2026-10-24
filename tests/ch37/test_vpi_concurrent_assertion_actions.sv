/*
:name: test_vpi_concurrent_assertion_actions
:description: an assert and an assume give their pass statement through vpiStmt and their fail statement through vpiElseStmt, a cover property its pass statement, and a restrict property, which has no action block, gives neither; a restrict property is not evaluated in simulation, so assertion callbacks placed on it never come, while those on an assume of the same property do (IEEE 1800-2023 Section 37.50)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.50 39.4.2 16.14.1 16.14.2 16.14.3 16.14.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_concurrent_assertion_actions.c
:expected_stdout: @test_vpi_concurrent_assertion_actions.expected
*/
// IEEE 1800-2023 §37.50: a concurrent assertion leads to its pass statement
// with vpiStmt, where the kind supports one, and an assert or an assume to its
// fail statement with vpiElseStmt; here each action is an assignment to a
// counter of its own, told apart by the left-hand side. A restrict property
// has no pass and no fail action (detail 2, 16.14.4), so both relations give
// NULL; it is not simulated and gives no run-time information, so the
// callbacks cbAssertionStart, cbAssertionSuccess and cbAssertionFailure
// (39.4.2), placed at 0 on r_rs and on the assume m_am of the same property,
// come only for m_am: an attempt starts at each clock tick, 5, 15 and 25, and
// succeeds at 5 and 25, where a is 1, and fails at 15, where a is 0. The
// action blocks run as the attempts end (16.14.1 to 16.14.3), which the
// counters show at 30. The callbacks are counted, since their order within a
// time step is not fixed.

`timescale 1ns/1ns

module test_vpi_concurrent_assertion_actions;
  logic clk = 1'b0, a = 1'b1;
  int a_ok = 0, a_bad = 0, m_ok = 0, m_bad = 0, c_hit = 0;

  always #5 clk = ~clk;

  a_as: assert property (@(posedge clk) a) a_ok = a_ok + 1; else a_bad = a_bad + 1;
  m_am: assume property (@(posedge clk) a) m_ok = m_ok + 1; else m_bad = m_bad + 1;
  c_cv: cover property (@(posedge clk) a) c_hit = c_hit + 1;
  r_rs: restrict property (@(posedge clk) a);

  initial begin
    $vt_actions;
    #10 a = 1'b0;
    #10 a = 1'b1;
    #10 $vt_report;
    $display("assert: pass %0d, fail %0d; assume: pass %0d, fail %0d; cover: %0d",
             a_ok, a_bad, m_ok, m_bad, c_hit);
    $finish;
  end
endmodule
