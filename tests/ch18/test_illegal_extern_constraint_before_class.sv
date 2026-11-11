/*
:name: test_illegal_extern_constraint_before_class
:description: An external constraint block that comes before the declaration of its class is an error (IEEE 1800-2023 Section 18.5.1)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the external constraint block for ecb_obj::c_pos appears before the declaration of ecb_obj
:expected_stderr_regex: test_illegal_extern_constraint_before_class\.sv:27:
*/
// IEEE 1800-2023 §18.5.1: an external constraint block has to be in the same
// scope as the declaration of its class and after that declaration. Here the
// class is only declared forward with typedef class (8.27) before the block,
// and its declaration follows the block, so the block is in the right scope
// but in the wrong place. The prototype c_pos is in the implicit form, so
// without a valid block it would only be an empty constraint (no error); the
// misplaced block is the only error.
// Icarus Verilog 13.0 does not support external constraint blocks, so the
// syntax error it reports on that line does not count; Verilator 5.052 stops
// with an internal error.

typedef class ecb_obj;

constraint ecb_obj::c_pos { v > 0; }   // illegal: before the class declaration

class ecb_obj;
  rand int v;
  constraint c_pos;
endclass

module test_illegal_extern_constraint_before_class;
  ecb_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
