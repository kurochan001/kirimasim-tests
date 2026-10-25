/*
:name: test_illegal_constraint_mode_unknown_block
:description: calling constraint_mode() on a constraint block that does not exist in the class hierarchy is a compile error (IEEE 1800-2023 Section 18.9)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call names the constraint block c_hi, which neither cmu_obj nor its base class declares
:expected_stderr_regex: test_illegal_constraint_mode_unknown_block\.sv:39:
*/
// IEEE 1800-2023 §18.9: object.constraint_identifier.constraint_mode()
// names a constraint block of the class of the object or of one of its base
// classes, and a compiler error shall be issued if the named block does not
// exist within the class hierarchy. c_base is declared in the base class
// and c_lo in cmu_obj, so both calls on them are legal. No class declares
// c_hi, so its call is the error.
// Icarus Verilog 13.0 does not support constraint declarations, so its error
// does not count.

class cmu_base;
  rand bit [3:0] x;
  constraint c_base { x > 1; }
endclass

class cmu_obj extends cmu_base;
  constraint c_lo { x < 8; }
endclass

module test_illegal_constraint_mode_unknown_block;
  cmu_obj o = new;

  initial begin
    o.c_base.constraint_mode(0);
    o.c_lo.constraint_mode(1);
    $display("%0d", o.c_base.constraint_mode());
    o.c_hi.constraint_mode(0);   // illegal: no block c_hi in the hierarchy
  end
endmodule
