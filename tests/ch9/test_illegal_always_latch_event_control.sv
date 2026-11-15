/*
:name: test_illegal_always_latch_event_control
:description: The always_comb restrictions apply to always_latch, so an always_latch procedure cannot contain an event control (IEEE 1800-2023 Section 9.2.2.3)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.2.3 9.2.2.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_latch procedure waits with the event control @(posedge d)
:expected_stderr_regex: test_illegal_always_latch_event_control\.sv:32:
*/
// IEEE 1800-2023 §9.2.2.3: all of §9.2.2.2 applies to always_latch, which
// is the same construct as always_comb apart from the checks for latched
// behavior. §9.2.2.2.2: the statements of an always_comb shall not include
// statements that block, blocking timing or event controls, or fork-join.
// The first always_latch is an ordinary latch and is legal; the second one
// waits with @(posedge d) before its assignment, and that line is the
// error. Without the event control the design is legal and prints q=1 p=1.
// Icarus Verilog 13.0 reports on the line of the error that an event
// control is not allowed in an always_latch; the 5.054 release of Verilator
// accepts the design.

module test_illegal_always_latch_event_control;
  logic en = 1'b1, d = 1'b1;
  logic q, p;

  always_latch if (en) q = d;

  always_latch begin
    if (en) @(posedge d) p = d;   // illegal: an event control in always_latch
  end

  initial #1 $display("q=%b p=%b", q, p);
endmodule
