/*
:name: test_illegal_inline_constraint_super_unresolved
:description: a name qualified by super in an inline constraint that is not a member of the base of the object class is an error (IEEE 1800-2023 Section 18.7)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: super.lim in the inline constraint names lim, which is not a member of the base class of the object class scu_obj
:expected_stderr_regex: test_illegal_inline_constraint_super_unresolved\.sv:41:
*/
// IEEE 1800-2023 §18.7: in an inline constraint, names qualified by this or
// super bind to the class of the object handle used in the call of
// randomize() with, and it is an error if such a name does not resolve
// there; super starts the lookup in the base class of that class (§8.15).
// The module has a variable lim; neither scu_obj nor its base class
// scu_base has one. super.w names the member of scu_base and is legal;
// super.lim is the error.
// Icarus Verilog 13.0 does not support randomize() with, so its error does
// not count. The 5.052 release of Verilator rejects every use of super in an
// inline constraint written in a module, as if it were outside a class, so
// its errors do not count either.

class scu_base;
  rand bit [3:0] w;
endclass

class scu_obj extends scu_base;
  rand bit [3:0] x;
endclass

module test_illegal_inline_constraint_super_unresolved;
  scu_obj o = new;
  bit [3:0] lim = 4'd6;
  int r1, r2;

  initial begin
    r1 = o.randomize() with { super.w < lim; };
    r2 = o.randomize() with { x < super.lim; };   // illegal: lim is not in scu_base
    $display("%0d %0d", r1, r2);
  end
endmodule
