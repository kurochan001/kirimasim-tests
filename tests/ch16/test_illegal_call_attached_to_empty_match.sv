/*
:name: test_illegal_call_attached_to_empty_match
:description: a subroutine call cannot be attached to a sequence that admits an empty match (IEEE 1800-2023 Section 16.11)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call note() in a_bad is attached to b[*0:2], which admits an empty match
:expected_stderr_regex: test_illegal_call_attached_to_empty_match\.sv:29:
*/
// IEEE 1800-2023 §16.11: tasks, void functions and system tasks can be called
// at the end of a nonempty match of a sequence, and it shall be an error to
// attach a subroutine call, or any sequence match item, to a sequence that
// admits an empty match. In a_ok note() is attached to a ##1 b[*0:2], whose
// matches are at least one cycle long; in a_bad it is attached to b[*0:2].
// Icarus Verilog 13.0 does not support concurrent assertions, and the 5.052
// release of Verilator stops with an internal error; neither counts.

module test_illegal_call_attached_to_empty_match;
  logic clk = 0, a = 0, b = 0, c = 0;
  int d = 0;
  function void note();
    $display("match");
  endfunction
  a_ok: assert property (@(posedge clk) (a ##1 b[*0:2], note()) |-> c);
  a_bad: assert property (@(posedge clk) a |-> ##1 (b[*0:2], note()) ##1 c);   // illegal
endmodule
