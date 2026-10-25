/*
:name: test_illegal_constraint_mode_redefined
:description: a class that declares its own constraint_mode() method, overriding the built-in one, is an error (IEEE 1800-2023 Section 18.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class cmr_obj declares a task named constraint_mode, but the built-in constraint_mode() cannot be overridden
:expected_stderr_regex: test_illegal_constraint_mode_redefined\.sv:25:
*/
// IEEE 1800-2023 §18.9: constraint_mode() is a built-in method and cannot be
// overridden. cmr_obj declares a task constraint_mode with the prototype of
// the built-in task that enables or disables its constraint blocks, which is
// the error.
// Icarus Verilog 13.0 does not support constraint declarations, so its error
// does not count.

class cmr_obj;
  rand bit [3:0] x;
  constraint c { x < 8; }
  int calls;
  task constraint_mode(bit on_off);   // illegal: overrides the built-in method
    calls++;
  endtask
endclass

module test_illegal_constraint_mode_redefined;
  cmr_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
