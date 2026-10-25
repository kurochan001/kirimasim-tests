/*
:name: test_illegal_constraint_specifier_prototype_mismatch
:description: An override specifier on an external constraint block but not on its prototype is an error (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2 18.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the external constraint block of c_x is declared with :final, but its prototype is not
:expected_stderr_regex: test_illegal_constraint_specifier_prototype_mismatch\.sv:(26|31):
*/
// IEEE 1800-2023 §18.5.2: the initial, extends and final specifiers of a
// constraint given by a prototype and an external constraint block (18.5.1)
// appear on both or on neither; it is an error if only one of them has one.
// c_y has :final on both and is legal; the block of c_x has :final and its
// prototype has none. Neither constraint is replaced anywhere, so :final
// itself is allowed. A tool can report the error at the prototype or at the
// block.
// Icarus Verilog 13.0 does not support override specifiers, so the syntax error
// it reports does not count; Verilator 5.052 accepts the design.

class csp_obj;
  rand int v;
  extern constraint c_x;
  extern constraint :final c_y;
endclass

constraint :final csp_obj::c_y { v < 100; }
constraint :final csp_obj::c_x { v > 0; }   // illegal: no :final on the prototype

module test_illegal_constraint_specifier_prototype_mismatch;
  csp_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
