/*
:name: test_illegal_constraint_specifier_block_mismatch
:description: An override specifier on a constraint prototype but not on its external block is an error (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2 18.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the prototype of c_a is declared with :extends, but its external constraint block is not
:expected_stderr_regex: test_illegal_constraint_specifier_block_mismatch\.sv:(31|35):
*/
// IEEE 1800-2023 §18.5.2: when a constraint is given by a prototype and an
// external constraint block (18.5.1), the initial, extends and final
// specifiers are written on both of them or on neither, and it is an error if
// only one has a specifier. c_b has :extends on both and is legal; the
// prototype of c_a has :extends and its block has none. Both constraints do
// replace a constraint of csb_base, so :extends itself is allowed. A tool can
// report the error at the prototype or at the block.
// Icarus Verilog 13.0 does not support override specifiers, so the syntax error
// it reports does not count; Verilator 5.052 accepts the design.

class csb_base;
  rand int v;
  constraint c_a { v > 0; }
  constraint c_b { v < 100; }
endclass

class csb_derived extends csb_base;
  extern constraint :extends c_a;
  extern constraint :extends c_b;
endclass

constraint csb_derived::c_a { v > 5; }   // illegal: no :extends here
constraint :extends csb_derived::c_b { v < 50; }

module test_illegal_constraint_specifier_block_mismatch;
  csb_derived o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
