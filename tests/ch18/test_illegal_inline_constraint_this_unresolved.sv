/*
:name: test_illegal_inline_constraint_this_unresolved
:description: a name qualified by this in an inline constraint that is not a member of the object class is an error (IEEE 1800-2023 Section 18.7)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: this.lim in the inline constraint names lim, which is not a member of the object class tcu_obj
:expected_stderr_regex: test_illegal_inline_constraint_this_unresolved\.sv:35:
*/
// IEEE 1800-2023 §18.7: in an inline constraint, a name qualified by this
// binds to the class of the object handle used in the call of randomize()
// with, and it is an error if it does not resolve there; it is not looked up
// in the scope of the call. An unqualified name that is not a member of the
// object class is resolved in the scope of the call instead. The module has
// a variable lim; the class tcu_obj does not. this.x and the unqualified lim
// are legal; this.lim is the error.
// Icarus Verilog 13.0 does not support randomize() with, so its error does
// not count.

class tcu_obj;
  rand bit [3:0] x;
endclass

module test_illegal_inline_constraint_this_unresolved;
  tcu_obj o = new;
  bit [3:0] lim = 4'd6;
  int r1, r2;

  initial begin
    r1 = o.randomize() with { this.x < lim; };
    r2 = o.randomize() with { x < this.lim; };   // illegal: lim is not in tcu_obj
    $display("%0d %0d", r1, r2);
  end
endmodule
