/*
:name: test_illegal_assertion_function_output_argument
:description: a function in an expression of a concurrent assertion cannot have an output argument (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: p_bad calls the function f_output, whose argument is output logic
:expected_stderr_regex: test_illegal_assertion_function_output_argument\.sv:37:
*/
// IEEE 1800-2023 §16.6: functions that appear in expressions of concurrent
// assertions shall not have output, inout or ref arguments; const ref is
// allowed. p_in and p_cr call automatic functions with an input and a const
// ref argument, which is legal; p_bad calls f_output, whose argument x is
// output logic.
// f_output does not assign x, but an output argument is copied to its actual
// when the function returns (13.5), which is why such functions are excluded.
// Icarus Verilog 13.0 does not support these assertions, and Verilator 5.052
// reports this line as unsupported, which does not count.

module test_illegal_assertion_function_output_argument;
  logic clk = 0, a = 1, t;
  function automatic bit f_in(input logic x);
    return x;
  endfunction
  function automatic bit f_cr(const ref logic x);
    return x;
  endfunction
  function automatic bit f_output(output logic x, input logic y);
    return y;
  endfunction
  p_in: assert property (@(posedge clk) f_in(a));
  p_cr: assert property (@(posedge clk) f_cr(a));
  p_bad: assert property (@(posedge clk) f_output(t, a));   // illegal
endmodule
