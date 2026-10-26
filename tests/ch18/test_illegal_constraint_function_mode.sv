/*
:name: test_illegal_constraint_function_mode
:description: A function that appears in a constraint shall not modify random or constraint modes, so a function that calls rand_mode on a random variable is an error (IEEE 1800-2023 Section 18.5.11)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constraint c_bad calls fpm_obj::f_mode, which changes the rand_mode of x
:expected_stderr_regex: test_illegal_constraint_function_mode\.sv:(26|31):
*/
// IEEE 1800-2023 §18.5.11: functions that appear in constraint expressions
// shall not modify random or constraint modes. f_mode calls rand_mode(0) on
// the random variable x; the constraint c_ok is legal, and c_bad calls
// f_mode and is illegal. A tool can report the error at the call or at the
// constraint.
// Icarus Verilog 13.0 does not support constraints, and Verilator 5.052
// accepts the design, so their results do not count.

class fpm_obj;
  rand int x;

  function automatic int f_mode();
    x.rand_mode(0);   // illegal: changes a random mode
    return 1;
  endfunction

  constraint c_ok { x > 0; }
  constraint c_bad { f_mode() == 1; }   // illegal: function changes a mode
endclass

module test_illegal_constraint_function_mode;
  fpm_obj o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
