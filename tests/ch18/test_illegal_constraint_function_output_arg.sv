/*
:name: test_illegal_constraint_function_output_arg
:description: A function that appears in a constraint expression shall not have an output, inout or ref argument, so calling f_out(t) with an output formal in a constraint is an error while a const ref function is allowed (IEEE 1800-2023 Section 18.5.11)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constraint bad calls f_out, whose formal argument o is declared output
:expected_stderr_regex: test_illegal_constraint_function_output_arg\.sv:34:
*/
// IEEE 1800-2023 §18.5.11: functions that appear in constraint expressions
// shall not contain output, inout or ref arguments, although const ref is
// allowed. The constraint ok calls f_cr with a const ref argument and is
// legal. The constraint bad calls f_out with an output argument and is
// illegal, because the function could write the caller's state while the
// constraint is evaluated.

class c_fn;
  rand int x;
  int t;

  function automatic int f_cr(const ref int i);
    return i;
  endfunction

  function automatic int f_out(output int o);
    return o + 1;
  endfunction

  constraint ok { x > f_cr(t); }
  constraint bad { x == f_out(t); }   // illegal: output argument
endclass

module test_illegal_constraint_function_output_arg;
  c_fn o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
