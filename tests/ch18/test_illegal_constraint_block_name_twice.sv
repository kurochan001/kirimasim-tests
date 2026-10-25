/*
:name: test_illegal_constraint_block_name_twice
:description: two constraint blocks of one class with the same name are an error (IEEE 1800-2023 Section 18.5)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class cbn_obj declares two constraint blocks named lim
:expected_stderr_regex: test_illegal_constraint_block_name_twice\.sv:30:
*/
// IEEE 1800-2023 §18.5: constraint blocks are members of their class, like
// its variables and methods, and the names of the constraint blocks of a
// class shall be unique within it. cbn_base and cbn_obj each declare a block
// named lim; that is legal, since they are different classes, and the block
// of cbn_obj overrides the one it inherits. cbn_obj then declares a second
// block named lim, which is the error.
// Icarus Verilog 13.0 does not support constraint declarations, so its error
// does not count.

class cbn_base;
  rand bit [3:0] x;
  constraint lim { x > 2; }
endclass

class cbn_obj extends cbn_base;
  constraint lim { x > 4; }
  constraint lim { x < 9; }   // illegal: a second block named lim
endclass

module test_illegal_constraint_block_name_twice;
  cbn_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
