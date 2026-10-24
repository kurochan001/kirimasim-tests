/*
:name: test_illegal_assertion_function_side_effect
:description: a function in an expression of a concurrent assertion cannot have a side effect (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a_bad calls the automatic function f_side, which increments the module variable hits
:expected_stderr_regex: test_illegal_assertion_function_side_effect\.sv:32:
*/
// IEEE 1800-2023 §16.6: functions that appear in expressions of concurrent
// assertions shall be automatic or preserve no state information, and shall
// have no side effects. f_read only reads the module variable hits, so a_ok
// is legal; f_side is automatic but increments hits, and a_bad calls it.
// Icarus Verilog 13.0 does not support concurrent assertions, and Verilator
// 5.052 accepts the design.

module test_illegal_assertion_function_side_effect;
  logic clk = 0, a = 0;
  int hits;
  function automatic bit f_read(bit x);
    return x || hits > 0;
  endfunction
  function automatic bit f_side(bit x);
    hits++;
    return x;
  endfunction
  a_ok: assert property (@(posedge clk) f_read(a));
  a_bad: assert property (@(posedge clk) f_side(a));   // illegal
endmodule
