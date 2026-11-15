/*
:name: test_illegal_always_latch_fork_join
:description: The always_comb restrictions apply to always_latch, so an always_latch procedure cannot contain a fork-join statement (IEEE 1800-2023 Section 9.2.2.3)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.3 9.2.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_latch procedure contains a fork-join statement
:expected_stderr_regex: test_illegal_always_latch_fork_join\.sv:32:
*/
// IEEE 1800-2023 §9.2.2.3: all of §9.2.2.2 applies to always_latch, which
// is the same construct as always_comb apart from the checks for latched
// behavior. §9.2.2.2.2: the statements of an always_comb shall not include
// statements that block, blocking timing or event controls, or fork-join
// statements. The first always_latch is an ordinary latch and is legal; the
// second one makes its assignment inside fork ... join, which has no timing
// control in it, and that line is the error. With begin ... end in place of
// fork ... join the design is legal and prints q=1 p=1.
// Icarus Verilog 13.0 reports the fork-join of the always_latch on the
// line of the error. The 5.054 release of Verilator accepts the design.

module test_illegal_always_latch_fork_join;
  logic en = 1'b1, d = 1'b1;
  logic q, p;

  always_latch if (en) q = d;

  always_latch begin
    if (en) fork p = d; join   // illegal: a fork-join in always_latch
  end

  initial #1 $display("q=%b p=%b", q, p);
endmodule
