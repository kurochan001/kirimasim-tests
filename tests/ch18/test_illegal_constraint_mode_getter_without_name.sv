/*
:name: test_illegal_constraint_mode_getter_without_name
:description: the constraint name of constraint_mode() can be omitted only in the void setter form, so a call without an argument and without a constraint name is an error (IEEE 1800-2023 Section 18.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.9
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: o.constraint_mode() is called without an argument and names no constraint block, which only the void form with an argument may do
:expected_stderr_regex: test_illegal_constraint_mode_getter_without_name\.sv:39:
*/
// IEEE 1800-2023 §18.9: constraint_mode() has a void setter form with a bit
// argument, in which the constraint name is optional, and an int getter form
// without an argument, in which the constraint name is written. The name may
// be left out only when the method is called as a void function, and the call
// then applies to all the constraints of the object.
// The setter without a name, o.constraint_mode(0), and the getter on the
// named block c_lo are legal; a call without an argument and without a name
// is the only error.
// The 5.054 release of Verilator runs the design without that call and
// rejects the call, saying that constraint_mode() cannot be called as a
// function there. Icarus Verilog 13.0 does not support constraint
// declarations, so its error does not count.

class cgn_obj;
  rand bit [3:0] x;
  constraint c_lo { x < 4'd8; }
endclass

module test_illegal_constraint_mode_getter_without_name;
  cgn_obj o = new;
  int m;

  initial begin
    o.constraint_mode(0);
    m = o.c_lo.constraint_mode();
    m = m + o.constraint_mode();   // illegal
    $display("m=%0d", m);
  end
endmodule
