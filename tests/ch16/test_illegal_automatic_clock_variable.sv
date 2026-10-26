/*
:name: test_illegal_automatic_clock_variable
:description: An automatic variable shall not occur in a clocking event, so a procedural concurrent assertion clocked by the automatic loop variable of a for statement is an error (IEEE 1800-2023 Section 16.14.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.14.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the clocking event posedge i of p_bad uses the automatic loop variable i
:expected_stderr_regex: test_illegal_automatic_clock_variable\.sv:30:
*/
// IEEE 1800-2023 §16.14.6: a concurrent assertion may be embedded in
// procedural code, where it is a procedural concurrent assertion. It shall be
// illegal to use automatic variables in clocking events. The module-level
// p_ok is clocked by the static variable clk and is legal. In the always
// procedure, i is the automatic loop variable of the for statement, so
// @(posedge i) in p_bad is illegal: the pending assertion instance would
// outlive the loop iteration that created i.

module test_illegal_automatic_clock_variable;
  logic clk = 0;
  logic a = 1;

  p_ok: assert property (@(posedge clk) a);

  always @(posedge clk) begin
    for (int i = 0; i < 1; i++) begin
      assert property (@(posedge i) a);   // illegal: automatic i in clock
    end
  end
endmodule
