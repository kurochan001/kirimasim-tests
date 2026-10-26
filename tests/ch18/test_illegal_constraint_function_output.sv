/*
:name: test_illegal_constraint_function_output
:description: A function called in a constraint expression shall not have an output, inout or ref argument, so calling a function with an output formal is an error while a function with a const ref formal is allowed (IEEE 1800-2023 Sections 18.5 and 18.5.11)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5 18.5.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constraint c_bad calls flo_obj::f_out, whose formal argument o is declared output
:expected_stderr_regex: test_illegal_constraint_function_output\.sv:36:
*/
// IEEE 1800-2023 §18.5 says that the functions that may appear in constraint
// expressions obey the restrictions of §18.5.11, which excludes output, inout
// and ref arguments (const ref is allowed). The constraint c_ok calls f_cr
// with a const ref argument and is legal; c_bad calls f_out with an output
// argument and is illegal.
// Icarus Verilog 13.0 does not support constraints, and Verilator 5.052
// accepts the design, so their results do not count.

class flo_obj;
  rand int x;
  int t;

  function automatic int f_cr(const ref int i);
    return i;
  endfunction

  function automatic int f_out(output int o);
    o = 1;
    return o;
  endfunction

  constraint c_ok { x > f_cr(t); }
  constraint c_bad { x == f_out(t); }   // illegal: output argument
endclass

module test_illegal_constraint_function_output;
  flo_obj o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
