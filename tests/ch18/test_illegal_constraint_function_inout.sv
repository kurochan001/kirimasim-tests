/*
:name: test_illegal_constraint_function_inout
:description: A function called in a constraint expression shall not have an inout argument, so calling a function with an inout formal is an error (IEEE 1800-2023 Sections 18.5 and 18.5.11)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5 18.5.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constraint c_bad calls fio_obj::f_io, whose formal argument io is declared inout
:expected_stderr_regex: test_illegal_constraint_function_inout\.sv:35:
*/
// IEEE 1800-2023 §18.5: functions in constraint expressions obey §18.5.11,
// which excludes output, inout and ref arguments (const ref is allowed). The
// constraint c_ok calls f_cr with a const ref argument and is legal; c_bad
// calls f_io with an inout argument and is illegal.
// Icarus Verilog 13.0 does not support constraints, and Verilator 5.052
// accepts the design, so their results do not count.

class fio_obj;
  rand int x;
  int t;

  function automatic int f_cr(const ref int i);
    return i;
  endfunction

  function automatic int f_io(inout int io);
    io = io + 1;
    return io;
  endfunction

  constraint c_ok { x > f_cr(t); }
  constraint c_bad { x == f_io(t); }   // illegal: inout argument
endclass

module test_illegal_constraint_function_inout;
  fio_obj o = new;

  initial begin
    $display("randomize=%0d", o.randomize());
  end
endmodule
