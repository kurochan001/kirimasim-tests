/*
:name: test_illegal_constraint_function_state
:description: A function that appears in a constraint shall be automatic or preserve no state and have no side effects, so a function that increments a static counter is an error (IEEE 1800-2023 Section 18.5.11)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constraint c_bad calls fps_obj::f, which changes the static variable calls
:expected_stderr_regex: test_illegal_constraint_function_state\.sv:31:
*/
// IEEE 1800-2023 §18.5.11: functions that appear in constraint expressions
// shall be automatic or preserve no state and have no side effects. f_state
// increments the static variable calls and so keeps state; the constraint
// c_ok does not use it and is legal, while c_bad calls it and is illegal.
// Icarus Verilog 13.0 does not support constraints, and Verilator 5.052
// accepts the design, so their results do not count.

class fps_obj;
  rand int x;
  static int calls = 0;

  function int f_state();
    calls = calls + 1;
    return 1;
  endfunction

  constraint c_ok { x > 0; }
  constraint c_bad { f_state() == 1; }   // illegal: function keeps state
endclass

module test_illegal_constraint_function_state;
  fps_obj o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
