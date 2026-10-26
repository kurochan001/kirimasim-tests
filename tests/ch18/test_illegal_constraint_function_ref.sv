/*
:name: test_illegal_constraint_function_ref
:description: A function called in a constraint expression shall not have a ref argument, so calling a function with a ref formal is an error while const ref is allowed (IEEE 1800-2023 Sections 18.5 and 18.5.11)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5 18.5.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constraint c_bad calls frf_obj::f_ref, whose formal argument r is declared ref
:expected_stderr_regex: test_illegal_constraint_function_ref\.sv:34:
*/
// IEEE 1800-2023 §18.5: functions in constraint expressions obey §18.5.11,
// which excludes output, inout and ref arguments; const ref is allowed. The
// constraint c_ok calls f_cr with a const ref argument and is legal; c_bad
// calls f_ref with a ref argument and is illegal.
// Icarus Verilog 13.0 does not support constraints, and Verilator 5.052
// accepts the design, so their results do not count.

class frf_obj;
  rand int x;
  int t;

  function automatic int f_cr(const ref int i);
    return i;
  endfunction

  function automatic int f_ref(ref int r);
    return r;
  endfunction

  constraint c_ok { x > f_cr(t); }
  constraint c_bad { x == f_ref(t); }   // illegal: ref argument
endclass

module test_illegal_constraint_function_ref;
  frf_obj o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
