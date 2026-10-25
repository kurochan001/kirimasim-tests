/*
:name: test_illegal_constraint_block_and_prototype
:description: A constraint block with the name of a constraint prototype of the same class is an error (IEEE 1800-2023 Section 18.5.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class declares the prototype c_pos and also a constraint block named c_pos
:expected_stderr_regex: test_illegal_constraint_block_and_prototype\.sv:(24|25):
*/
// IEEE 1800-2023 §18.5.1: it is an error if a constraint block with the name
// of a constraint prototype appears in the same class declaration. cbp_obj
// declares the implicit prototype c_pos and a block c_pos; a tool can report
// the error at either. Without the block, the implicit prototype would only
// be an empty constraint (no error).
// Icarus Verilog 13.0 does not support constraint prototypes, and Verilator
// 5.052 accepts the design.

class cbp_obj;
  rand int v;
  constraint c_pos;
  constraint c_pos { v > 0; }   // illegal: same name as the prototype
endclass

module test_illegal_constraint_block_and_prototype;
  cbp_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
